<?php

/**
 * Copyright 2016 Nick Korbel
 *
 * This file is part of Booked Scheduler.
 *
 * Booked Scheduler is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Booked Scheduler is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Booked Scheduler.  If not, see <http://www.gnu.org/licenses/>.
 */

require_once(ROOT_DIR . 'Presenters/ResourceDisplayPresenter.php');

interface IResourceDisplayPage extends IPage, IActionPage
{

	public function DisplayLogin();

	/**
	 * @return string
	 */
	public function GetResourceId();

	/**
	 * @return string
	 */
	public function GetPublicResourceId();

	/**
	 * @return string
	 */
	public function GetEmail();

	/**
	 * @return string
	 */
	public function GetPassword();

	public function BindInvalidLogin();

	/**
	 * @param BookableResource[] $resourceList
	 */
	public function BindResourceList($resourceList);

	/**
	 * @param $publicId
	 */
	public function SetActivatedResourceId($publicId);

	public function BindResource(BookableResource $resource);

	public function DisplayAvailability(IDailyLayout $dailyLayout, Date $today);

	/**
	 * @param bool $availableNow
	 */
	public function SetIsAvailableNow($availableNow);

	public function DisplayNotEnabled();
}

class ResourceDisplayPage extends ActionPage implements IResourceDisplayPage
{
	/**
	 * @var ResourceDisplayPresenter
	 */
	private $presenter;

	public function __construct()
	{
		parent::__construct('Resource');
		$this->presenter = new ResourceDisplayPresenter($this,
														new ResourceRepository(),
														new ReservationService(new ReservationViewRepository(), new ReservationListingFactory()),
														PluginManager::Instance()->LoadAuthorization(),
														new WebAuthentication(PluginManager::Instance()->LoadAuthentication()),
														new ScheduleRepository(),
														new DailyLayoutFactory());
	}

	public function ProcessAction()
	{
		$this->presenter->ProcessAction();
	}

	public function ProcessDataRequest($dataRequest)
	{
		// no op
	}

	public function ProcessPageLoad()
	{
		$this->presenter->PageLoad();
	}

	public function GetResourceId()
	{
		return $this->GetForm(FormKeys::RESOURCE_ID);
	}

	public function DisplayLogin()
	{
		$this->Display('ResourceDisplay/resource-display-shell.tpl');
	}

	public function EnforceCSRFCheck()
	{
		// no op
	}

	public function GetEmail()
	{
		return $this->GetForm(FormKeys::EMAIL);
	}

	public function GetPassword()
	{
		return $this->GetForm(FormKeys::PASSWORD);
	}

	public function BindInvalidLogin()
	{
		$this->SetJson(array('error' => true));
	}

	public function BindResourceList($resourceList)
	{
		$resources = array();
		foreach ($resourceList as $resource)
		{
			$resources[] = array('id' => $resource->GetId(), 'name' => $resource->GetName());
		}

		$this->SetJson(array('resources' => $resources));
	}

	public function SetActivatedResourceId($publicId)
	{
		$resourceDisplayUrl = Configuration::Instance()->GetScriptUrl() . '/' . Pages::DISPLAY_RESOURCE . '?' . QueryStringKeys::RESOURCE_ID . '=' . $publicId;
		$this->SetJson(array('location' => $resourceDisplayUrl));
	}

	public function GetPublicResourceId()
	{
		return $this->GetQuerystring(QueryStringKeys::RESOURCE_ID);
	}

	public function BindResource(BookableResource $resource)
	{
		$this->Set('ResourceName', $resource->GetName());
		$this->Set('ResourceId', $resource->GetId());
	}

	public function DisplayAvailability(IDailyLayout $dailyLayout, Date $today)
	{
		$this->Set('Today', $today);
		$this->Set('DailyLayout', $dailyLayout);
		$this->Set('SlotLabelFactory', new SlotLabelFactory(new NullUserSession()));
		$this->Display('ResourceDisplay/resource-display-resource.tpl');
	}

	public function SetIsAvailableNow($availableNow)
	{
		$this->Set('AvailableNow', $availableNow);
	}

	public function DisplayNotEnabled()
	{
		$this->Display('ResourceDisplay/resource-display-not-enabled.tpl');
	}
}

