import json


def test_invalid_request(send_request, read_response):
    send_request("invalid request")
    response = read_response()
    response_parsed = json.loads(response)
    assert response_parsed["error"] is not None
    assert response_parsed["id"] is None


def test_initialize(send_request, simple_initialize_request, read_response, version):
    send_request(json.dumps(simple_initialize_request))
    response = read_response()
    response_parsed = json.loads(response)
    assert response_parsed["error"] is None
    assert response_parsed["id"] == simple_initialize_request["id"]
    assert response_parsed["result"]["serverInfo"]["version"] == version


def test_invalid_header(send_arbitrary_request, read_response):
    send_arbitrary_request("invalid header\r\n\r\n")
    response = read_response()
    response_parsed = json.loads(response)
    assert response_parsed["error"] is not None
    assert response_parsed["error"]["code"] == -32700
    assert response_parsed["id"] is None
