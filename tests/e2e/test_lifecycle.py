import os
import subprocess
import time
import json


class TestServerLifecycle:
    @classmethod
    def setup_class(cls):
        cls.request_data = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": None,
        }
        cls.bin = os.getenv("PYTONGUE_TEST_BINARY", "./zig-out/bin/pytongue")

        with open("version") as f:
            cls.version = f.read().strip()

        cls.server = subprocess.Popen(
            [cls.bin],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=os.environ.copy(),
        )
        time.sleep(1)

    @classmethod
    def teardown_class(cls):
        cls.server.terminate()
        cls.server.wait()

    def send_request(self, request):
        content_length = len(request)
        self.server.stdin.write(
            f"Content-Length: {content_length}\r\n\r\n{request}".encode()
        )
        self.server.stdin.flush()

    def read_response(self):
        header = self.server.stdout.readline().decode().strip()
        content_length = int(header.split(": ")[1])
        self.server.stdout.readline()  # Empty line
        return self.server.stdout.read(content_length).decode()

    def test_invalid_request(self):
        self.send_request("invalid request")
        response = self.read_response()
        response_parsed = json.loads(response)
        assert response_parsed["error"] is not None
        assert response_parsed["id"] is None

    def test_initialize(self):
        self.send_request(json.dumps(self.request_data))
        response = self.read_response()
        response_parsed = json.loads(response)
        assert response_parsed["error"] is None
        assert response_parsed["id"] == self.request_data["id"]
        assert response_parsed["result"]["serverInfo"]["version"] == self.version

    def test_invalid_header(self):
        self.server.stdin.write("invalid header\r\n\r\n".encode())
        self.server.stdin.flush()
        response = self.read_response()
        response_parsed = json.loads(response)
        assert response_parsed["error"] is not None
        assert response_parsed["error"]["code"] == -32700
        assert response_parsed["id"] is None
