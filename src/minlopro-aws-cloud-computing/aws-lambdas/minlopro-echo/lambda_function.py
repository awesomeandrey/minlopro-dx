import base64
import json
import logging
import boto3

# Cache initializations for warm start
logger = logging.getLogger()
logger.setLevel(logging.INFO)
sts = boto3.client("sts")
s3 = boto3.client("s3")


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
        if event.get("isBase64Encoded"):
            try:
                body = base64.b64decode(body).decode("utf-8")
            except (ValueError, UnicodeDecodeError):
                return {}
        try:
            parsed = json.loads(body)
        except json.JSONDecodeError:
            return {}
        return parsed if isinstance(parsed, dict) else {}

    return event


def _run_cpu_intensive_logic():
    total = sum(i * i for i in range(500000))


def lambda_handler(event, context):
    payload = _extract_payload(event)
    raw_message = payload.get("message") if isinstance(payload, dict) else None
    message = raw_message.strip() if isinstance(raw_message, str) else None

    logger.info(
        json.dumps(
            {
                "request_id": context.aws_request_id,
                "evt": json.dumps(event)[1:1500],
                "message": message,
            }
        )
    )

    identity = sts.get_caller_identity()

    buckets = s3.list_buckets()
    bucket_names = [b["Name"] for b in buckets["Buckets"]]

    _run_cpu_intensive_logic()

    response_payload = {
        "identity": json.dumps(identity),
        "buckets": bucket_names,
        "memory_mb": context.memory_limit_in_mb,
    }

    if message:
        response_payload["echo"] = f"Echo -> {message}"
        return _response(200, response_payload)
    else:
        response_payload["instructions"] = "Pass a non-blank string 'message' field."
        return _response(400, response_payload)
