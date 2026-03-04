# Salesforce Web-To-Case (W2C) Form

LWC that submits support cases directly to Salesforce via the standard Web-to-Case HTTP endpoint.
Uses `c-dig-ex-re-captcha-form` for reCAPTCHA v2 (checkbox) verification before submission.

## Fields

| Label       | `name` Attribute | Type     | Required |
| ----------- | ---------------- | -------- | -------- |
| Name        | `name`           | text     | Yes      |
| Email       | `email`          | email    |          |
| Subject     | `subject`        | text     | Yes      |
| Description | `description`    | textarea |          |

## W2C API

POST to: `${SF_INSTANCE_URL}/servlet/servlet.WebToCase?encoding=UTF-8`

Required hidden fields:

- `orgid` — 18-digit Salesforce organization ID

Optional:

- `retURL` — redirect URL after submission (not applicable in `mode: 'no-cors'` fetch)

## Standard Case Field Mapping

| Case Standard Field | Form `name` Parameter |
| ------------------- | --------------------- |
| `SuppliedName`      | `name`                |
| `SuppliedEmail`     | `email`               |
| `Subject`           | `subject`             |
| `Description`       | `description`         |

## reCAPTCHA Integration

Inherits the reCAPTCHA setup from `c-dig-ex-re-captcha-form`. See that component for
script tag requirements in the Experience Site Head Markup.

The reCAPTCHA `verifyUserToken` Apex call is handled by `DigExReCaptchaController`.

## Trusted URLs

The Salesforce instance URL must be listed under **Setup → Trusted URLs** (CSP) to allow
the `fetch()` call to the Web-to-Case endpoint.
