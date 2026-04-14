({
    doInit: function (component, event, helper) {
        var action = component.get('c.enableLogs');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.status', 'success');
                setTimeout(function () {
                    $A.get('e.force:closeQuickAction').fire();
                }, 1500);
            } else {
                var errors = response.getError();
                var message = 'An unexpected error occurred while enabling logs.';
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                component.set('v.errorMessage', message);
                component.set('v.status', 'error');
            }
        });
        $A.enqueueAction(action);
    }
});
