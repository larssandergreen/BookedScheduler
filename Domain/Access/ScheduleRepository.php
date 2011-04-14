<?php
require_once(ROOT_DIR . 'Domain/ScheduleLayout.php');
require_once(ROOT_DIR . 'Domain/Schedule.php');
require_once(ROOT_DIR . 'Domain/SchedulePeriod.php');
require_once(ROOT_DIR . 'lib/Database/Commands/namespace.php');

interface IScheduleRepository
{
	/**
	 * Gets all schedules
	 * @return array list of Schedule objects
	 */
	public function GetAll();
	
	/**
	 * @param int $scheduleId
	 * @return Schedule
	 */
	public function LoadById($scheduleId);

	/**
	 * @param Schedule $schedule
	 */
	public function Update(Schedule $schedule);
	
	/**
	 * @param Schedule $schedule
	 * @param int $copyLayoutFromScheduleId
	 */
	public function Add(Schedule $schedule, $copyLayoutFromScheduleId);
	
	/**
	 * @param int $scheduleId
	 * @param ILayoutFactory $layoutFactory factory to use to create the schedule layout
	 * @return IScheduleLayout
	 */
	public function GetLayout($scheduleId, ILayoutFactory $layoutFactory);
	
	/**
	 * @param int $scheduleId
	 * @param ILayoutCreation $layout
	 */
	public function AddScheduleLayout($scheduleId, ILayoutCreation $layout);
}

interface ILayoutFactory 
{
	/**
	 * @return IScheduleLayout
	 */
	public function CreateLayout();
}

class ScheduleLayoutFactory implements ILayoutFactory
{
	private $_targetTimezone;
	
	/**
	 * @param string $targetTimezone target timezone of layout
	 */
	public function __construct($targetTimezone)
	{
		$this->_targetTimezone = $targetTimezone;
	}
	
	/**
	 * @see ILayoutFactory::CreateLayout()
	 */
	public function CreateLayout()
	{
		return new ScheduleLayout($this->_targetTimezone);
	}
}

class ReservationLayoutFactory implements ILayoutFactory
{
	private $_targetTimezone;
	
	/**
	 * @param string $targetTimezone target timezone of layout
	 */
	public function __construct($targetTimezone)
	{
		$this->_targetTimezone = $targetTimezone;
	}
	
	/**
	 * @see ILayoutFactory::CreateLayout()
	 */
	public function CreateLayout()
	{
		return new ReservationLayout($this->_targetTimezone);
	}
}

class ScheduleRepository implements IScheduleRepository
{
	public function GetAll()
	{
		$schedules = array();

		$reader = ServiceLocator::GetDatabase()->Query(new GetAllSchedulesCommand());

		while ($row = $reader->GetRow())
		{
			$schedules[] = new Schedule(
				$row[ColumnNames::SCHEDULE_ID],
				$row[ColumnNames::SCHEDULE_NAME],
				$row[ColumnNames::SCHEDULE_DEFAULT],
				$row[ColumnNames::SCHEDULE_WEEKDAY_START],
				$row[ColumnNames::SCHEDULE_DAYS_VISIBLE],
				$row[ColumnNames::TIMEZONE_NAME]
			);
		}

		$reader->Free();

		return $schedules;
	}
	
	public function LoadById($scheduleId)
	{
		$schedule = null;

		$reader = ServiceLocator::GetDatabase()->Query(new GetScheduleByIdCommand($scheduleId));

		if ($row = $reader->GetRow())
		{
			$schedule = new Schedule(
				$row[ColumnNames::SCHEDULE_ID],
				$row[ColumnNames::SCHEDULE_NAME],
				$row[ColumnNames::SCHEDULE_DEFAULT],
				$row[ColumnNames::SCHEDULE_WEEKDAY_START],
				$row[ColumnNames::SCHEDULE_DAYS_VISIBLE],
				$row[ColumnNames::TIMEZONE_NAME],
				$row[ColumnNames::LAYOUT_ID]
			);
		}

		$reader->Free();

		return $schedule;
	}

	public function Update(Schedule $schedule)
	{
		ServiceLocator::GetDatabase()->Execute(new UpdateScheduleCommand(
			$schedule->GetId(), 
			$schedule->GetName(), 
			$schedule->GetIsDefault(),
			$schedule->GetWeekdayStart(),
			$schedule->GetDaysVisible()));
			
		if ($schedule->GetIsDefault())
		{
			ServiceLocator::GetDatabase()->Execute(new SetDefaultScheduleCommand($schedule->GetId()));
		}
	}
	
	public function Add(Schedule $schedule, $copyLayoutFromScheduleId)
	{
		$source = $this->LoadById($copyLayoutFromScheduleId);

		$db = ServiceLocator::GetDatabase();
		
		$db->ExecuteInsert(new AddScheduleCommand(
			$schedule->GetName(),
			$schedule->GetIsDefault(),
			$schedule->GetWeekdayStart(),
			$schedule->GetDaysVisible(),
			$source->GetLayoutId()
		));
	}
	/**
	 * @see IScheduleRepository::GetLayout()
	 */
	public function GetLayout($scheduleId, ILayoutFactory $layoutFactory)
	{
		$layout = $layoutFactory->CreateLayout();

		$reader = ServiceLocator::GetDatabase()->Query(new GetLayoutCommand($scheduleId));

		while ($row = $reader->GetRow())
		{
			$timezone = $row[ColumnNames::BLOCK_TIMEZONE];
			$start = Time::Parse($row[ColumnNames::BLOCK_START], $timezone);
			$end = Time::Parse($row[ColumnNames::BLOCK_END], $timezone);
			$label = $row[ColumnNames::BLOCK_LABEL];
			//$labelEnd = $row[ColumnNames::BLOCK_LABEL_END];
			$periodType = $row[ColumnNames::BLOCK_CODE];
				
			if ($periodType == PeriodTypes::RESERVABLE)
			{
				$layout->AppendPeriod($start, $end, $label);
			}
			else
			{
				$layout->AppendBlockedPeriod($start, $end, $label);
			}
		}

		$reader->Free();

		return $layout;
	}
	
	public function AddScheduleLayout($scheduleId, ILayoutCreation $layout)
	{
		$db = ServiceLocator::GetDatabase();
		$timezone = $layout->Timezone();
		
		$addLayoutCommand = new AddLayoutCommand($timezone);
		$layoutId = $db->ExecuteInsert($addLayoutCommand);
		
		$slots = $layout->GetSlots();
		
		/* @var slot LayoutPeriod */
		foreach($slots as $slot)
		{
			$db->Execute(new AddLayoutTimeCommand($layoutId, $slot->Start, $slot->End, $slot->PeriodType, $slot->Label));
		}
		
		$db->Execute(new UpdateScheduleLayoutCommand($scheduleId, $layoutId));
		
		//TODO: Delete old layout?
	}
}

?>