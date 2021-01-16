{*
Copyright 2013-2020 Nick Korbel

This file is part of Booked Scheduler.

Booked Scheduler is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Booked Scheduler is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Booked Scheduler.  If not, see <http://www.gnu.org/licenses/>.
*}
<p>Your Apple Capture equipment booking is ending soon.</p>
<p><strong>Reservation Details:</strong></p>

<p>
	<strong>Start:</strong> {formatdate date=$StartDate key=reservation_email}<br/>
	<strong>End:</strong> {formatdate date=$EndDate key=reservation_email}<br/>
	<strong>Resource:</strong> {$ResourceName}<br/>
        <br/><br />If you need more time, please extend your booking if the equipment is available.<br /><a href="{$ScriptUrl}/{$ReservationUrl}">View this booking</a>
        <a href="{$ScriptUrl}">Log in</a>
	
	We need your donations to keep Apple Capture running! Please donate (<a href=“https://secure.wildsight.ca/civicrm/contribute/transact?reset=1&id=34&source=Email%20-%20Apples”>for Kimberley and Cranbrook</a>, for <a href=“https://secure.wildsight.ca/civicrm/contribute/transact?reset=1&id=35&source=Email%20-%20Apples”>Fernie</a>).
</p>
