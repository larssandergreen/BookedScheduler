{*
Copyright 2011-2020 Nick Korbel

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
{include file='globalheader.tpl' Validator=true}

<div id="page-register">

    <div class="error hidden" id="registrationError">
        {translate key=UnknownError}
    </div>

    <div id="registration-box" class="default-box col-xs-12 col-sm-8 col-sm-offset-2">

        <form method="post" ajaxAction="{RegisterActions::Register}" id="form-register"
              action="{$smarty.server.SCRIPT_NAME}" role="form"
              data-bv-feedbackicons-valid="glyphicon glyphicon-ok"
              data-bv-feedbackicons-invalid="glyphicon glyphicon-remove"
              data-bv-feedbackicons-validating="glyphicon glyphicon-refresh"
              data-bv-feedbackicons-required="glyphicon glyphicon-asterisk"
              data-bv-submitbuttons='button[type="submit"]'
              data-bv-onerror="enableButton"
              data-bv-onsuccess="enableButton"
              data-bv-live="enabled">

            <h1>{translate key=RegisterANewAccount}</h1>

            <div class="validationSummary alert alert-danger no-show" id="validationErrors">
                <ul>
                    {async_validator id="uniqueemail" key="UniqueEmailRequired"}
                    {async_validator id="uniqueusername" key="UniqueUsernameRequired"}
                    {async_validator id="username" key="UserNameRequired"}
                    {async_validator id="emailformat" key="ValidEmailRequired"}
                    {async_validator id="fname" key="FirstNameRequired"}
                    {async_validator id="lname" key="LastNameRequired"}
                    {async_validator id="passwordmatch" key="PwMustMatch"}
                    {async_validator id="passwordcomplexity" key=""}
                    {async_validator id="captcha" key="CaptchaMustMatch"}
                    {async_validator id="additionalattributes" key=""}
                    {async_validator id="requiredEmailDomain" key="InvalidEmailDomain"}
                    {async_validator id="termsOfService" key="TermsOfServiceError"}
                    {async_validator id="phoneRequired" key="PhoneRequired"}
                    {async_validator id="positionRequired" key="PositionRequired"}
                    {async_validator id="organizationRequired" key="OrganizationRequired"}
                </ul>
            </div>

            <div class="row">
                <div class="col-xs-12 col-sm-6" id="username">
                    <div class="form-group">
                        <label class="reg" for="login">{translate key="Username"}</label>
                        {textbox name="LOGIN" value="Login" required="required"
                        data-bv-notempty="true"
                        data-bv-notempty-message="{translate key=UserNameRequired}"}
                    </div>
                </div>

                <div class="col-xs-12 col-sm-6" id="email">
                    <div class="form-group">
                        <label class="reg" for="email">{translate key="Email"}</label>
                        {textbox type="email" name="EMAIL" class="input" value="Email" required="required"
                        data-bv-notempty="true"
                        data-bv-notempty-message="{translate key=ValidEmailRequired}"
                        data-bv-emailaddress="true"
                        data-bv-emailaddress-message="{translate key=ValidEmailRequired}" }
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xs-12 col-sm-6" id="password">
                    <div class="form-group">
                        <label class="reg" for="password">{translate key="Password"}</label>
                        {textbox type="password" name="PASSWORD" value="" required="required"
                        data-bv-notempty="true"
                        data-bv-notempty-message="{translate key=PwMustMatch}"
                        data-bv-identical="true"
                        data-bv-identical-field="{FormKeys::PASSWORD_CONFIRM}"
                        data-bv-identical-message="{translate key=PwMustMatch}" }
                    </div>
                </div>

                <div class="col-xs-12 col-sm-6" id="password-confirm">
                    <div class="form-group">
                        <label class="reg" for="passwordConfirm">{translate key="PasswordConfirmation"}</label>
                        {textbox type="password" name="PASSWORD_CONFIRM" value="" required="required"
                        data-bv-notempty="true"
                        data-bv-notempty-message="{translate key=PwMustMatch}"
                        data-bv-identical="true"
                        data-bv-identical-field="{FormKeys::PASSWORD}"
                        data-bv-identical-message="{translate key=PwMustMatch}"}
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xs-12 col-sm-6" id="first-name">
                    <div class="form-group">
                        <label class="reg" for="fname">{translate key="FirstName"}</label>
                        {textbox name="FIRST_NAME" class="input" value="FirstName" required="required"
                        data-bv-notempty="true"
                        data-bv-notempty-message="{translate key=FirstNameRequired}"}
                    </div>
                </div>
                <div class="col-xs-12 col-sm-6" id="last-name">
                    <div class="form-group">
                        <label class="reg" for="lname">{translate key="LastName"}</label>
                        {textbox name="LAST_NAME" class="input" value="LastName" required="required" data-bv-notempty="true"
                        data-bv-notempty-message="{translate key=LastNameRequired}"}
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xs-12 col-sm-6" id="default-page">
                    <div class="form-group">
                        <label class="reg" for="homepage">City (for bookings)</label>
                        <select {formname key='DEFAULT_HOMEPAGE'} id="homepage" class="form-control">
                            {html_options values=$HomepageValues output=$HomepageOutput selected=$Homepage}
                        </select>
                    </div>

                </div>
                <div class="col-xs-12 col-sm-6" id="timezone">
                    <label class="reg" for="timezoneDropDown">{translate key="Timezone"}</label>

                    <div class="input-group" style="display:none;">
                        <span class="input-group-addon"><a href="#" id="detectTimezone"
                                                           title="{translate key=Detect}"><i class="fa fa-clock-o"></i></a></span>
                        <select {formname key='TIMEZONE'} class="form-control" id="timezoneDropDown" style="display:none;">
                            {html_options values=$TimezoneValues output=$TimezoneOutput selected=$Timezone}
                        </select>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xs-12 col-sm-6" id="phone">
                    <div class="form-group">
                        <label class="reg" for="phone">{translate key="Phone"}</label>
                        <input type="text" id="phone" {formname key="PHONE"} class="form-control" size="20"
                                {if $RequirePhone}required="required"
                                    data-bv-notempty="true"
                                    data-bv-notempty-message="{translate key=PhoneRequired}"{/if}
                        />
                    </div>
                </div>

                <div class="col-xs-12 col-sm-6" id="organization">
                    <div class="form-group">
                        <label class="reg" for="txtOrganization">Street Address</label>
                        <input type="text" id="txtOrganization" {formname key="ORGANIZATION"} class="form-control"
                               size="20"
                                {if $RequireOrganization}required="required"
                                    data-bv-notempty="true"
                                    data-bv-notempty-message="{translate key=OrganizationRequired}"{/if}/>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-xs-12 col-sm-6" id="position">
                    <div class="form-group">
                        <label class="reg" for="txtPosition">Postal Code</label>
                        <input type="text" id="txtPosition" {formname key="POSITION"} class="form-control"
                               size="20" {if $RequirePosition}required="required"
                            data-bv-notempty="true"
                            data-bv-notempty-message="{translate key=PositionRequired}"{/if}/>
                    </div>
                </div>

                <div class="col-xs-12 col-sm-6">
                    {if $Attributes|count > 0}
                        {control type="AttributeControl" attribute=$Attributes[0]}
                    {/if}
                </div>

            </div>

            {if $Attributes|count > 1}
                {for $i=1 to $Attributes|count-1}
                    {if $i%2==1}
                        <div class="row">
                    {/if}
                    <div class="col-xs-12 col-sm-6">
                        {control type="AttributeControl" attribute=$Attributes[$i]}
                    </div>
                    {if $i%2==0 || $i==$Attributes|count-1}
                        </div>
                    {/if}
                {/for}
            {/if}

            {if $EnableCaptcha}
                <div class="row">
                    <div class="col-xs-12">
                        <div class="form-group">
                            {control type="CaptchaControl"}
                        </div>
                    </div>
                </div>
            {else}
                <input type="hidden" {formname key=CAPTCHA} value=""/>
            {/if}

            {if $Terms != null}
                <div class="row" id="termsAndConditions">
                    <div class="col-xs-12">
                        <div class="checkbox">
                            <input type="checkbox"
                                   id="termsAndConditionsAcknowledgement" {formname key=TOS_ACKNOWLEDGEMENT}/>
                            <label for="termsAndConditionsAcknowledgement">{translate key=IAccept}</label>
                            <a href="{$Terms->DisplayUrl()}" style="vertical-align: middle"
                               target="_blank">{translate key=TheTermsOfService}</a>
                        </div>
                    </div>
                </div>
            {/if}
            
            <div class="registrationHeader"><h3>Waiver</h3></div>
            <p>By registering for Wildsight’s Apple Capture equipment booking system you agree to the following:</p>
            <p>WAIVER OF ALL CLAIMS, RELEASE FROM LIABILITY and ASSUMPTION OF RISKS</p>
            <p>WARNING: By signing this you also give up the right to sue</p>
            <p>Wildsight means the regional society Wildsight, its five branches (Creston Valley, Golden, Elk Valley, Kimberley/Cranbrook, and Invermere), and their officers, directors, members, employees, contractors, agents, and any person acting on their behalf.</p> 
            <p>By participating in the Apple Capture Project and/or using the Apple Capture equipment (fruit press, grinder, dehydrator, fruit picker, ladder, or other equipment), I agree to this release form from liability, waiver of all claims and agreement not to sue.</p>
            <p>I also agree for myself, my heirs, my executors, administrators and assignees to forever discharge and release Wildsight for any personal injury, death, property damage or loss sustained by me as a result of my participation in the Wildsight activity due to any cause whatsoever, including, without limitation, negligence on the part of Wildsight or its staff.</p>
            <p>I am aware that certain dangers and risks are possible, some of which include:</p>
            <p>Equipment lifting and transportation – Equipment is heavy and requires adequate strength to move, load, and unload.</p> 
            <p>Equipment use – The fruit pressing and grinding equipment have moving parts that can cause injury to fingers.  The dehydrator is an electrical appliance and could cause electrical shock.  Ladders can fall or be fallen from.</p>
            <p>Food safety – Dirty or contaminated fruit could cause illness.  Unpasteurized juice can harbor bacteria.</p>
            <p>I further acknowledge and agree that I am to return the equipment in the condition in which it was received.  This includes thoroughly cleaning all parts of the equipment.</p>
            <p>I am aware that it is my responsibility to return the equipment by the end of the day of my reservation, and therefore agree to schedule use efficiently so that the equipment can be used by as many community members as possible.</p>
            <p>I accept all the dangers and risks and the possibility of injury, death, property damage or lose resulting from participating in the Apple Capture Project. I agree not to sue Wildsight on account of any circumstance whatsoever arising from my participation in said project.</p>
            
            <div>
                <button type="submit" name="{Actions::REGISTER}" value="{translate key='Register'}"
                        class="btn btn-primary col-xs-12" id="btnUpdate">{translate key='Register'}</button>
            </div>
        </form>
    </div>

    {include file="javascript-includes.tpl" Validator=true}

    {jsfile src="js/jstz.min.js"}
    {jsfile src="ajax-helpers.js"}
    {jsfile src="autocomplete.js"}
    {jsfile src="registration.js"}

    <script type="text/javascript">

        function enableButton() {
            $('#form-register').find('button').removeAttr('disabled');
        }

        $(document).ready(function () {
            $('#detectTimezone').click(function (e) {
                e.preventDefault();

                if (Intl.DateTimeFormat) {
                    var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
                } else {
                    var timezone = jstz.determine_timezone().name();
                }

                $('#timezoneDropDown').val(timezone);
            });

            var registrationPage = new Registration();
            registrationPage.init();

            var $frmRegister = $('#form-register');

            $frmRegister.on('init.field.bv', function (e, data) {
                var $parent = data.element.parents('.form-group');
                var $icon = $parent.find('.form-control-feedback[data-bv-icon-for="' + data.field + '"]');
                var validators = data.bv.getOptions(data.field).validators;

                if (validators.notEmpty) {
                    $icon.addClass('glyphicon glyphicon-asterisk').show();
                }
            })
                .off('success.form.bv')
                .on('success.form.bv', function (e) {
                    e.preventDefault();
                });

            $frmRegister.bootstrapValidator();

            $('#txtOrganization').orgAutoComplete("ajax/autocomplete.php?type={AutoCompleteType::Organization}");

        });
    </script>

    <div id="colorbox">
        <div id="modalDiv" class="wait-box">
            <h3>{translate key=Working}</h3>
            {html_image src="reservation_submitting.gif"}
        </div>
    </div>

</div>
{include file='globalfooter.tpl'}
