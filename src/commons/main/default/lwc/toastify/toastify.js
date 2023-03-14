import { ShowToastEvent } from 'lightning/platformShowToastEvent'

// Custom Labels;
import infoMsg from '@salesforce/label/c.Global_Msg_Info'
import errorMsg from '@salesforce/label/c.Global_Msg_Error'
import successMsg from '@salesforce/label/c.Global_Msg_Success'
import warningMsg from '@salesforce/label/c.Global_Msg_Warning'

const Variant = {
    INFO: 'info',
    SUCCESS: 'success',
    WARNING: 'warning',
    ERROR: 'error',
}

/**
 * The component can be used for showing toasts of 4 variants ('success', 'info', 'warning' and 'error')
 *
 * Usage:
 * import toastify from 'c/toastify';
 * .......
 * toastify.success({message: "Your message", title: "Your title", mode: <mode>});
 */

function success({ message, mode, title }) {
    showToast(!title ? successMsg : title, message, Variant.SUCCESS, mode)
}

function info({ message, mode, title }) {
    showToast(!title ? infoMsg : title, message, Variant.INFO, mode)
}

function warning({ message, mode, title }) {
    showToast(!title ? warningMsg : title, message, Variant.WARNING, mode)
}

function error({ message, mode, title }) {
    showToast(!title ? errorMsg : title, message, Variant.ERROR, mode)
}

function showToast(title, message, variant, mode) {
    const event = new ShowToastEvent({
        title,
        message,
        variant,
        mode,
    })
    dispatchEvent(event)
}

function show(variant, payload) {
    if (!variant) {
        return
    }
    if (variant === Variant.SUCCESS) {
        success(payload)
    } else if (variant === Variant.INFO) {
        info(payload)
    } else if (variant === Variant.WARNING) {
        warning(payload)
    } else if (variant === Variant.ERROR) {
        error(payload)
    }
}

export default {
    success,
    info,
    warning,
    error,
}
