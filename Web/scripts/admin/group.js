function GroupManagement(opts) {
    var options = opts;

    var elements = {
        activeId: $('#activeId'),
        groupList: $('#groupList'),

        autocompleteSearch: $('#groupSearch'),
        userSearch: $('#userSearch'),

        groupUserList: $('#groupUserList'),
        membersDialog: $('#membersDialog'),
        allUsersList: $('#allUsersList'),
        permissionsDialog: $('#permissionsDialog'),
        deleteDialog: $('#deleteDialog'),
        editDialog: $('#editDialog'),
        browseUserDialog: $('#allUsers'),
        rolesDialog: $('#rolesDialog'),
        groupAdminDialog: $('#groupAdminDialog'),

        permissionsForm: $('#permissionsForm'),
        addUserForm: $('#addUserForm'),
        removeUserForm: $('#removeUserForm'),
        editGroupForm: $('#editGroupForm'),
        deleteGroupForm: $('#deleteGroupForm'),
        rolesForm: $('#rolesForm'),
        groupAdminForm: $('#groupAdminForm'),
        groupCount: $('#groupCount'),

        addForm: $('#addGroupForm'),

        checkAllResourcesFull: $('#checkAllResourcesFull'),
        checkAllResourcesView: $('#checkAllResourcesView'),
        checkNoResources: $('#checkNoResources'),

        editGroupName: $('#editGroupName'),
        editGroupIsDefault: $('#editGroupIsDefault'),

        changeAdminGroupsForm: $('#groupAdminGroupsForm'),
        changeAdminResourcesForm: $('#resourceAdminForm'),
        changeAdminSchedulesForm: $('#scheduleAdminForm'),
        resourceAdminDialog: $('#resourceAdminDialog'),
        groupAdminAllDialog: $('#groupAdminAllDialog'),
        scheduleAdminDialog: $('#scheduleAdminDialog'),

        creditsAddDialog: $('#creditsAddDialog'),
        creditsReplenishDialog: $('#creditsReplenishDialog'),
        creditsReplenishForm: $('#creditsReplenishForm'),
        creditsAddForm: $('#creditsAddForm')
    };

    var allUserList = null;

    GroupManagement.prototype.init = function () {

        elements.groupList.delegate('a.update', 'click', function (e) {
            setActiveId($(this));
            e.preventDefault();
        });

        elements.groupList.delegate('.rename', 'click', function () {
            editGroup();
        });

        elements.groupList.delegate('.permissions', 'click', function () {
            changePermissions();
        });

        elements.groupList.delegate('.members', 'click', function () {
            changeMembers();
            elements.membersDialog.modal('open');
        });

        elements.groupList.delegate('.delete', 'click', function () {
            deleteGroup();
        });

        elements.groupList.delegate('.roles', 'click', function () {
            changeRoles();
        });

        elements.groupList.delegate('.credits-add', 'click', function () {
            addCredits();
        });

        elements.groupList.delegate('.credits-replenish', 'click', function () {
            replenishCredits();
        });

        elements.browseUserDialog.delegate('.add', 'click', function () {
            var link = $(this);
            var userId = link.siblings('.id').val();

            addUserToGroup(userId);

            link.find('img').attr('src', '../img/tick-white.png');
        });

        elements.groupUserList.delegate('.delete', 'click', function () {
            var userId = $(this).siblings('.id').val();
            removeUserFromGroup($(this), userId);
        });

        elements.autocompleteSearch.autocomplete({
            source: function (request, response) {
                $.ajax({
                    url: options.groupAutocompleteUrl,
                    dataType: "json",
                    data: {
                        term: request.term
                    },
                    success: function (data) {
                        response($.map(data, function (item) {
                            return {
                                label: item.Name,
                                value: item.Id
                            }
                        }));
                    }
                });
            },
            focus: function (event, ui) {
                elements.autocompleteSearch.val(ui.item.label);
                return false;
            },
            select: function (event, ui) {
                elements.autocompleteSearch.val(ui.item.label);
                window.location.href = options.selectGroupUrl + ui.item.value
                return false;
            }
        });

        elements.userSearch.userAutoComplete(options.userAutocompleteUrl, function (ui) {
            addUserToGroup(ui.item.value);
            elements.userSearch.val('');
        });

        elements.groupList.delegate('.groupAdmin', 'click', function () {
            changeGroupAdmin();
        });

        elements.groupList.delegate('.changeAdminGroups', 'click', function () {
            changeAdminGroups();
        });
        elements.groupList.delegate('.changeAdminResources', 'click', function () {
            changeAdminResources();
        });
        elements.groupList.delegate('.changeAdminSchedules', 'click', function () {
            changeAdminSchedules();
        });

        elements.checkAllResourcesFull.click(function (e) {
            e.preventDefault();
            elements.permissionsDialog.find('.full').prop('selected', true);
        });

        elements.checkAllResourcesView.click(function (e) {
            e.preventDefault();
            elements.permissionsDialog.find('.view').prop('selected', true);
        });

        elements.checkNoResources.click(function (e) {
            e.preventDefault();
            elements.permissionsDialog.find('.none').prop('selected', true);
        });

        $(".save").click(function () {
            $(this).closest('form').submit();
        });

        $(".cancel").click(function () {
            $(this).closest('.modal').modal("close");
        });

        var hidePermissionsDialog = function () {
            elements.permissionsDialog.modal('close');
        };

        var error = function (errorText) {
            alert(errorText);
        };

        $("#browseUsers").click(function () {
            showAllUsersToAdd();
        });

        $('.adminDialog').on('click', '.checkbox', function (e) {
            var $checkbox = $(e.target);
            var modal = $checkbox.closest('.modal-body');
            modal.find('.count').text(modal.find(':checked').length);
        });

        wireUpCreditReplenishment();

        ConfigureAsyncForm(elements.addUserForm, getSubmitCallback(options.actions.addUser), changeMembers, error);
        ConfigureAsyncForm(elements.removeUserForm, getSubmitCallback(options.actions.removeUser), changeMembers, error);
        ConfigureAsyncForm(elements.permissionsForm, getSubmitCallback(options.actions.permissions), hidePermissionsDialog, error);
        ConfigureAsyncForm(elements.editGroupForm, getSubmitCallback(options.actions.updateGroup), null, error);
        ConfigureAsyncForm(elements.deleteGroupForm, getSubmitCallback(options.actions.deleteGroup), null, error);
        ConfigureAsyncForm(elements.addForm, getSubmitCallback(options.actions.addGroup), null, error);
        ConfigureAsyncForm(elements.rolesForm, getSubmitCallback(options.actions.roles), null, error);
        ConfigureAsyncForm(elements.groupAdminForm, getSubmitCallback(options.actions.groupAdmin), null, error);
        ConfigureAsyncForm(elements.changeAdminGroupsForm, getSubmitCallback(options.actions.adminGroups), function () {
            elements.groupAdminAllDialog.modal('close');
        }, error);
        ConfigureAsyncForm(elements.changeAdminResourcesForm, getSubmitCallback(options.actions.resourceGroups), function () {
            elements.resourceAdminDialog.modal('close');
        }, error);
        ConfigureAsyncForm(elements.changeAdminSchedulesForm, getSubmitCallback(options.actions.scheduleGroups), function () {
            elements.scheduleAdminDialog.modal('close');
        }, error);
        ConfigureAsyncForm(elements.creditsReplenishForm, getSubmitCallback(options.actions.creditReplenishment), function () {
            elements.creditsReplenishDialog.modal("close");
        }, error);
        ConfigureAsyncForm(elements.creditsAddForm, getSubmitCallback(options.actions.creditAdd), function () {
            elements.creditsAddDialog.modal("close");
        }, error);
    };

    var showAllUsersToAdd = function () {
        elements.membersDialog.modal('close');
        elements.allUsersList.empty();

        if (allUserList == null) {
            $.ajax({
                url: options.userAutocompleteUrl,
                dataType: 'json',
                async: false,
                success: function (data) {
                    allUserList = data;
                }
            });
        }

        var items = [];
        if (allUserList != null) {
            $.map(allUserList, function (item) {
                if (elements.groupUserList.data('userIds')[item.Id] == undefined) {
                    items.push('<div><a href="#" class="add"><img src="../img/plus-button.png" alt="Add To Group" /></a> ' + item.DisplayName + '<input type="hidden" class="id" value="' + item.Id + '"/></div>');
                } else {
                    items.push('<div><img src="../img/tick-white.png" alt="Group Member" /> <span>' + item.DisplayName + '</span></div>');
                }
            });
        }

        $('<div/>', {'class': '', html: items.join('')}).appendTo(elements.allUsersList);
        elements.browseUserDialog.modal('open');
    };

    var getSubmitCallback = function (action) {
        return function () {
            return options.submitUrl + "?gid=" + getActiveId() + "&action=" + action;
        };
    };

    function setActiveId(activeElement) {
        var id = activeElement.closest('tr').attr('data-group-id');
        elements.activeId.val(id);
    }

    function getActiveId() {
        return elements.activeId.val();
    }

    var editGroup = function () {
        var activeRow = elements.groupList.find('[data-group-id="' + getActiveId() + '"]');
        elements.editGroupName.val(activeRow.find('.dataGroupName').text());
        elements.editGroupIsDefault.prop('checked', activeRow.data('group-default') == '1');
        elements.editDialog.modal('open');
        elements.editGroupName.focus();
    };

    var changeMembers = function () {
        var groupId = getActiveId();
        $.getJSON(opts.groupsUrl + '?dr=groupMembers', {gid: groupId}, function (data) {
            var items = [];
            var userIds = [];

            $('#totalUsers').text(data.Total);
            if (data.Users != null) {
                $.map(data.Users, function (item) {
                    items.push('<div><a href="#" class="delete"><img src="../img/cross-button.png" /></a> ' + item.DisplayName + '<input type="hidden" class="id" value="' + item.Id + '"/></div>');
                    userIds[item.Id] = item.Id;
                });
            }

            elements.groupUserList.empty();
            elements.groupUserList.data('userIds', userIds);

            $('<div/>', {'class': '', html: items.join('')}).appendTo(elements.groupUserList);
        });
    };

    var addUserToGroup = function (userId) {
        $('#addUserId').val(userId);
        elements.addUserForm.submit();
    };

    var removeUserFromGroup = function (element, userId) {
        $('#removeUserId').val(userId);
        elements.removeUserForm.submit();
    };

    var changePermissions = function () {
        var groupId = getActiveId();

        var data = {dr: opts.dataRequests.permissions, gid: groupId};
        $.get(opts.permissionsUrl, data, function (permissions) {
            elements.permissionsForm.find('.none').prop('selected', true);

            $.each(permissions.full, function (index, value) {
                elements.permissionsForm.find('#permission_' + value).val(value + '_0');
            });

            $.each(permissions.view, function (index, value) {
                elements.permissionsForm.find('#permission_' + value).val(value + '_1');
            });

            elements.permissionsDialog.modal('open');
        });
    };

    const deleteGroup = function () {
        elements.deleteDialog.modal('open');
    };

    const changeRoles = function () {
        var groupId = getActiveId();

        var data = {dr: opts.dataRequests.roles, gid: groupId};
        $.get(opts.rolesUrl, data, function (roleIds) {
            elements.rolesForm.find(':checkbox').prop('checked', false);
            $.each(roleIds, function (index, value) {
                elements.rolesForm.find(':checkbox[value="' + value + '"]').prop('checked', true);
            });

            elements.rolesDialog.modal('open');
        });
    };

    const addCredits = function () {
        const groupId = getActiveId();
        $.getJSON(opts.groupsUrl + '?dr=groupMembers', {gid: groupId}, function (data) {
            $('#addCreditsTotalUsers').text(data.Total);
            elements.creditsAddDialog.find('input[type="number"]').val('1');
            elements.creditsAddDialog.modal('open');
            M.updateTextFields();
        });
    };

    const replenishCredits = function () {
        const groupId = getActiveId();

        $.getJSON(opts.groupsUrl + '?dr=groupMembers', {gid: groupId}, function (data) {
            $('#replenishCreditsTotalUsers').text(data.Total);
        });

        elements.creditsReplenishDialog.find(':radio').removeAttr('checked');
        elements.creditsReplenishDialog.find('input[type="number"]').val('');
        var data = {dr: opts.dataRequests.creditReplenishment, gid: groupId};
        $.getJSON(opts.submitUrl, data, function (replenishment) {
            $('#credits-replenishment-id').val(replenishment.id);
            $('#credits-last-replenished').text(replenishment.lastReplenishment);

            let checkedRadio = $('#credits-never');
            if (replenishment.type === "1") {
                $('#credits-days-amount').val(replenishment.amount);
                $('#credits-days-days').val(replenishment.interval);
                checkedRadio = $('#credits-days');
            } else if (replenishment.type === "2") {
                $('#credits-set-day-amount').val(replenishment.amount);
                $('#credits-set-day-days').val(replenishment.dayOfMonth);
                checkedRadio = $('#credits-set-day');
            }

            elements.creditsReplenishDialog.modal('open');
            checkedRadio.click();
            M.updateTextFields();
            showApplicableCreditReplenishment(checkedRadio);
        });
    };

    const changeGroupAdmin = function () {
        var groupId = getActiveId();

        elements.groupAdminForm.find('select').val('');

        elements.groupAdminDialog.modal('open');
    };

    var changeAdminGroups = function () {
        populateAdminCheckboxes(opts.dataRequests.adminGroups, elements.changeAdminGroupsForm, elements.groupAdminAllDialog);
    };

    var changeAdminResources = function () {
        populateAdminCheckboxes(opts.dataRequests.resourceGroups, elements.changeAdminResourcesForm, elements.resourceAdminDialog);
    };

    var changeAdminSchedules = function () {
        populateAdminCheckboxes(opts.dataRequests.scheduleGroups, elements.changeAdminSchedulesForm, elements.scheduleAdminDialog);
    };

    var populateAdminCheckboxes = function (dr, $form, $dialog) {
        var groupId = getActiveId();

        $dialog.find('.count').text($dialog.find(':checked').length);

        var data = {dr: dr, gid: groupId};
        $.get(opts.submitUrl, data, function (groupIds) {
            $form.find(':checkbox').prop('checked', false);
            $.each(groupIds, function (index, value) {
                $form.find(':checkbox[value="' + value + '"]').prop('checked', true);
            });

            $dialog.find('.count').text(groupIds.length);
            $dialog.modal('open');
        });
    };

    function wireUpCreditReplenishment() {
        elements.creditsReplenishDialog.on('click', ':radio', function (e) {
            showApplicableCreditReplenishment($(e.target));
        });
    }

    function showApplicableCreditReplenishment(selectedOption) {
        elements.creditsReplenishDialog.find(".credits-details").addClass("no-show");
        elements.creditsReplenishDialog.find("input").removeAttr("required");

        const rel = selectedOption.attr("rel");
        if (rel) {
            $(rel).removeClass("no-show");
            $(rel).find("input").attr("required", true);
        }
    }
}