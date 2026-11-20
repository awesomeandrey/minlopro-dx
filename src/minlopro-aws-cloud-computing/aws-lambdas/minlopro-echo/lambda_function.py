import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def _response(status_code, payload):
    # HTTP API's Lambda integration requires this exact shape - statusCode is the real
    # transport HTTP status, and the payload must be JSON-stringified under 'body'.
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(payload),
    }


def _extract_payload(event):
    # HTTP API's proxy integration nests the real JSON payload as a string under 'body';
    # a direct console/CLI test invoke sends it flat instead.
    if not isinstance(event, dict):
        return {}

    body = event.get("body")
    if isinstance(body, str):
        try:
            parsed = json.loads(body)
        except json.JSONDecodeError:
            return {}
        return parsed if isinstance(parsed, dict) else {}

    return event


def lambda_handler(event, context):
    payload = _extract_payload(event)
    raw_message = payload.get("message") if isinstance(payload, dict) else None
    message = raw_message.strip() if isinstance(raw_message, str) else None

    logger.info(json.dumps({"request_id": context.aws_request_id, "message": message}))

    if message:
        return _response(200, {"echo": f"Echo -> {message}"})

    return _response(400, {"instructions": "Pass a non-blank string 'message' field."})
