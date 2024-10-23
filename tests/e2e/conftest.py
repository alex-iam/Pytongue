import os
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
def server(binary):
    server = subprocess.Popen(
        [binary],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=os.environ.copy(),
    )
    yield server

    server.terminate()
    server.wait()


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
        content_length = int(header.split(": ")[1])
        server.stdout.readline()  # Empty line
        return server.stdout.read(content_length).decode()

    return _read_response
