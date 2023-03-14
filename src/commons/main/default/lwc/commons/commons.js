export function wait(callback) {
    setTimeout(callback, 0)
}

export function uniqueId() {
    let array = new Uint32Array(8)
    if (window.crypto) {
        window.crypto.getRandomValues(array)
    }
    let str = ''
    for (let i = 0; i < array.length; i++) {
        str += (i < 2 || i > 5 ? '' : '-') + array[i].toString(16).slice(-4)
    }
    return str
}

export function isEmpty(value) {
    if (value === undefined || value === null) {
        return true
    }

    if (Array.isArray(value)) {
        return value.length === 0
    } else if (typeof value === 'object') {
        return Object.keys(value).length === 0 && value.constructor === Object
    } else if (value === 0) {
        return false
    } else if (typeof value === 'string' || value instanceof String) {
        return !value.trim()
    } else {
        return !Boolean(value)
    }
}

export function isArray(arr) {
    return Array.isArray(arr)
}

export function isEmptyArray(arr) {
    return !(Array.isArray(arr) && arr.length)
}

export function isNotEmpty(obj) {
    return !isEmpty(obj)
}

export function debounce(callback, timeout = 500) {
    return function (args) {
        let previousCall = this.lastCall
        this.lastCall = Date.now()
        if (previousCall && this.lastCall - previousCall <= timeout) {
            clearTimeout(this.lastCallTimer)
        }
        this.lastCallTimer = setTimeout(() => callback(args), timeout)
    }
}

export function throttle(callback, interval = 1000) {
    let waitingCall = false
    return (args) => {
        if (!waitingCall) {
            waitingCall = true
            callback(args)
            setTimeout(() => {
                waitingCall = false
            }, interval)
        }
    }
}

export function cloneObject(value) {
    if (typeof window.structuredClone === 'function') {
        return window.structuredClone(value)
    } else {
        return JSON.parse(JSON.stringify(value))
    }
}

export function splitByComma(stringToSplit = '') {
    if (!stringToSplit) {
        return []
    }
    return stringToSplit
        .trim()
        .split(/\s*,+\s*/)
        .filter((i) => {
            return i
        })
}

export const pipe =
    (...functions) =>
    (args) =>
        functions.reduce((arg, fn) => fn(arg), args)

export function parseError(err) {
    let message = '',
        details = {},
        code = ''
    if (err) {
        if (err.body && err.body.output) {
            message = err.body.message
            if (err.body.output.errors.length > 0) {
                code = err.body.output.errors[0].message
            }
            details = JSON.parse(JSON.stringify(err.body.output))
        } else if (Array.isArray(err)) {
            return parseError(err[0] || {})
        } else if (Array.isArray(err.body) && err.body.length > 0) {
            message = err.body[0].message
            code = err.body[0].errorCode
        } else if (err.body && err.body.message) {
            message = err.body.message
        } else if (err.body) {
            message = err.body
        } else if (err.statusText) {
            message = err.statusText
        } else if (err.message) {
            message = err.message
        } else if (err.pageErrors?.length) {
            // Errors from force:recordData
            message = err.pageErrors[0].message
        } else {
            message = err
        }
        if (message && message.includes('"id":"APEX_CONTEXT_EXCEPTION"')) {
            details = JSON.parse(message)
            message = details.message
        }
    }
    return { message, code, details }
}