import json
import logging

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Comprehend isn't offered in every region (not in eu-north-1, where this function
# runs) - target it explicitly rather than inheriting the function's own region.
COMPREHEND_REGION = "eu-central-1"

comprehend = boto3.client("comprehend", region_name=COMPREHEND_REGION)

MIN_TEXT_LENGTH = 20
MAX_TEXT_LENGTH = 300


def _response(status_code, payload):
    # HTTP API's Lambda integration requires this exact shape - statusCode is the real
    # transport HTTP status, and the payload must be JSON-stringified under 'body'.
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(payload),
    }


def _extract_payload(event):
    # API Gateway's Lambda proxy integration nests the real JSON payload as a
    # string under 'body'; a direct console/CLI test invoke sends it flat instead.
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
    request_id = context.aws_request_id
    logger.info(json.dumps({"request_id": request_id, "step": "received_event"}))

    payload = _extract_payload(event)
    raw_text = payload.get("text") if isinstance(payload, dict) else None
    text = raw_text.strip() if isinstance(raw_text, str) else None

    logger.info(
        json.dumps(
            {
                "request_id": request_id,
                "step": "extracted_text",
                "text_length": len(text) if text else 0,
            }
        )
    )

    if not text or not (MIN_TEXT_LENGTH <= len(text) <= MAX_TEXT_LENGTH):
        logger.info(json.dumps({"request_id": request_id, "step": "validation_failed"}))
        return _response(
            400,
            {
                "instructions": f"Pass a 'text' field between {MIN_TEXT_LENGTH} and {MAX_TEXT_LENGTH} characters."
            },
        )

    logger.info(json.dumps({"request_id": request_id, "step": "calling_comprehend"}))

    try:
        result = comprehend.detect_sentiment(Text=text, LanguageCode="en")
    except ClientError as e:
        logger.error(
            json.dumps(
                {"request_id": request_id, "step": "comprehend_failed", "error": str(e)}
            )
        )
        return _response(502, {"instructions": "Sentiment detection failed."})

    sentiment = result["Sentiment"]
    scores = result["SentimentScore"]

    logger.info(
        json.dumps(
            {
                "request_id": request_id,
                "step": "comprehend_succeeded",
                "sentiment": sentiment,
            }
        )
    )

    return _response(200, {"sentiment": sentiment, "scores": scores})
