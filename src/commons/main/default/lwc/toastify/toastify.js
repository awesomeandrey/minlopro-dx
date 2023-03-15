import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Custom Labels;
import successMsg from '@salesforce/label/c.Commons_Msg_Success';
import errorMsg from '@salesforce/label/c.Commons_Msg_Error';
import warningMsg from '@salesforce/label/c.Commons_Msg_Warning';
import infoMsg from '@salesforce/label/c.Commons_Msg_Info';

const Variant = {
    INFO: 'info',
    SUCCESS: 'success',
    WARNING: 'warning',
    ERROR: 'error'
};

/**
 * The component can be used for showing toasts of 4 variants ('success', 'info', 'warning' and 'error')
 *
 * Usage:
 * import toastify from 'c/toastify';
 * .......
 * toastify.success({message: "Your message", title: "Your title", mode: <mode>});
 */

function success({ message, mode, title }) {
    showToast(!title ? successMsg : title, message, Variant.SUCCESS, mode);
}

function info({ message, mode, title }) {
    showToast(!title ? infoMsg : title, message, Variant.INFO, mode);
}

function warning({ message, mode, title }) {
    showToast(!title ? warningMsg : title, message, Variant.WARNING, mode);
}

function error({ message, mode, title }) {
    showToast(!title ? errorMsg : title, message, Variant.ERROR, mode);
}

function showToast(title, message, variant, mode) {
    const event = new ShowToastEvent({
        title,
        message,
        variant,
        mode
    });
    // 'dispatchEvent' function is invoked against 'window' object!
    dispatchEvent(event);
}

export default {
    Variant,
    success,
    info,
    warning,
    error
};
