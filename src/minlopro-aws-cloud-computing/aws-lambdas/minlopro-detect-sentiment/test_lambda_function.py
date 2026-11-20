import json
from types import SimpleNamespace
from unittest.mock import patch

import lambda_function
from botocore.exceptions import ClientError

VALID_TEXT = "This product completely exceeded every expectation I had!"  # 58 chars


def _context():
    return SimpleNamespace(aws_request_id="test-request-id")


def _sentiment_response(sentiment="POSITIVE"):
    return {
        "Sentiment": sentiment,
        "SentimentScore": {
            "Positive": 0.9,
            "Negative": 0.02,
            "Neutral": 0.05,
            "Mixed": 0.03,
        },
    }


def test_missing_text_returns_400():
    response = lambda_function.lambda_handler({}, _context())

    assert response["statusCode"] == 400


def test_text_shorter_than_minimum_returns_400():
    response = lambda_function.lambda_handler({"text": "too short"}, _context())

    assert response["statusCode"] == 400


def test_text_longer_than_maximum_returns_400():
    response = lambda_function.lambda_handler(
        {"text": "x" * (lambda_function.MAX_TEXT_LENGTH + 1)}, _context()
    )

    assert response["statusCode"] == 400


def test_text_at_min_boundary_is_accepted():
    text = "x" * lambda_function.MIN_TEXT_LENGTH

    with patch.object(
        lambda_function.comprehend,
        "detect_sentiment",
        return_value=_sentiment_response(),
    ) as mock_call:
        response = lambda_function.lambda_handler({"text": text}, _context())

    assert response["statusCode"] == 200
    mock_call.assert_called_once_with(Text=text, LanguageCode="en")


def test_text_at_max_boundary_is_accepted():
    text = "x" * lambda_function.MAX_TEXT_LENGTH

    with patch.object(
        lambda_function.comprehend,
        "detect_sentiment",
        return_value=_sentiment_response(),
    ):
        response = lambda_function.lambda_handler({"text": text}, _context())

    assert response["statusCode"] == 200


def test_valid_flat_event_returns_sentiment():
    with patch.object(
        lambda_function.comprehend,
        "detect_sentiment",
        return_value=_sentiment_response("POSITIVE"),
    ):
        response = lambda_function.lambda_handler({"text": VALID_TEXT}, _context())

    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["sentiment"] == "POSITIVE"
    assert body["scores"]["Positive"] == 0.9


def test_api_gateway_proxy_event_unwraps_body():
    event = {
        "body": json.dumps({"text": VALID_TEXT}),
        "headers": {"x-minlopro-dx-client": "some value"},
    }

    with patch.object(
        lambda_function.comprehend,
        "detect_sentiment",
        return_value=_sentiment_response(),
    ):
        response = lambda_function.lambda_handler(event, _context())

    assert response["statusCode"] == 200


def test_malformed_body_json_returns_400():
    response = lambda_function.lambda_handler({"body": "not-json"}, _context())

    assert response["statusCode"] == 400


def test_comprehend_failure_returns_502():
    error = ClientError(
        error_response={
            "Error": {"Code": "AccessDeniedException", "Message": "denied"}
        },
        operation_name="DetectSentiment",
    )

    with patch.object(
        lambda_function.comprehend, "detect_sentiment", side_effect=error
    ):
        response = lambda_function.lambda_handler({"text": VALID_TEXT}, _context())

    assert response["statusCode"] == 502
