import json
import os
import random
import subprocess

import pytest


@pytest.fixture
def binary():
    return os.getenv("PYTONGUE_TEST_BINARY", "./zig-out/bin/pytongue")


@pytest.fixture
def version():
    with open("version") as f:
        return f.read().strip()


@pytest.fixture
def simple_initialize_request():
    return {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": None,
    }


@pytest.fixture
def initialized_notification():
    return {
        "jsonrpc": "2.0",
        "method": "initialized",
        "params": {},
    }


@pytest.fixture
def shutdown_request():
    return {
        "jsonrpc": "2.0",
        "id": random.randint(1, 100),
        "method": "shutdown",
        "params": None,
    }


@pytest.fixture
def invalid_method_request():
    return {
        "jsonrpc": "2.0",
        "id": random.randint(1, 100),
        "method": "invalid_method",
        "params": None,
    }


@pytest.fixture
def invalid_method_notification():
    return {
        "jsonrpc": "2.0",
        "method": "invalid_method",
        "params": None,
    }


@pytest.fixture
def exit_notification():
    return {
        "jsonrpc": "2.0",
        "method": "exit",
        "params": None,
    }


@pytest.fixture
def server(binary):
    server = subprocess.Popen(
        [binary],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=os.environ.copy(),
    )
    yield server
    if server.poll() is None:
        server.terminate()
        server.wait(2)


@pytest.fixture
def send_request(server):
    def _send_request(request):
        content_length = len(request)
        server.stdin.write(
            f"Content-Length: {content_length}\r\n\r\n{request}".encode()
        )
        server.stdin.flush()

    return _send_request


@pytest.fixture
def send_arbitrary_request(server):
    def _send_arbitrary_request(request):
        server.stdin.write(request.encode())
        server.stdin.flush()

    return _send_arbitrary_request


@pytest.fixture
def read_response(server):
    def _read_response():
        header = server.stdout.readline().decode().strip()
        try:
            content_length = int(header.split(": ")[1])
        except IndexError:
            raise Exception(f"Invalid data received from server: {header}")
        server.stdout.readline()  # Empty line
        return server.stdout.read(content_length).decode()

    return _read_response


@pytest.fixture
def initialize(send_request, simple_initialize_request, read_response):
    def _initialize():
        send_request(json.dumps(simple_initialize_request))
        read_response()

    return _initialize


@pytest.fixture
def shutdown(send_request, shutdown_request, read_response, initialize):
    def _shutdown():
        initialize()
        send_request(json.dumps(shutdown_request))
        read_response()

    return _shutdown
