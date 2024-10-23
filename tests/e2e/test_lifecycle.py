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


def test_should_fail_shutdown_before_initialize(
    send_request,
    shutdown_request,
    read_response,
):
    send_request(json.dumps(shutdown_request))
    response = read_response()
    response_parsed = json.loads(response)
    assert response_parsed["error"] is not None
    assert response_parsed["error"]["code"] == -32600
    assert response_parsed["id"] == shutdown_request["id"]


def test_shutdown(send_request, shutdown_request, read_response, initialize):
    initialize()
    send_request(json.dumps(shutdown_request))
    response = read_response()
    response_parsed = json.loads(response)
    assert response_parsed["error"] is None
    assert response_parsed["id"] == shutdown_request["id"]


def test_unknown_method_request(
    send_request,
    invalid_method_request,
    read_response,
    initialize,
):
    initialize()
    send_request(json.dumps(invalid_method_request))
    response = read_response()
    response_parsed = json.loads(response)
    assert response_parsed["error"] is not None
    assert response_parsed["error"]["code"] == -32601
    assert response_parsed["id"] == invalid_method_request["id"]


def test_invalid_method_notification(
    send_request,
    invalid_method_notification,
    read_response,
    initialize,
):
    initialize()
    send_request(json.dumps(invalid_method_notification))
    response = read_response()
    response_parsed = json.loads(response)
    assert response_parsed["error"] is not None
    assert response_parsed["error"]["code"] == -32601
    assert response_parsed["id"] is None


def test_request_after_shutdown(
    send_request,
    simple_initialize_request,
    read_response,
    shutdown,
):
    shutdown()
    # TODO send a different request after shutdown
    send_request(json.dumps(simple_initialize_request))
    response = read_response()
    response_parsed = json.loads(response)
    assert response_parsed["error"] is not None
    assert response_parsed["error"]["code"] == -32600


def test_exit_before_shutdown(server, send_request, exit_notification):
    send_request(json.dumps(exit_notification))
    server.wait(0.01)
    assert server.poll() is not None
    assert server.returncode == 1


def test_exit_after_shutdown(server, send_request, exit_notification, shutdown):
    shutdown()
    send_request(json.dumps(exit_notification))
    server.wait(0.01)
    assert server.poll() is not None
    assert server.returncode == 0
