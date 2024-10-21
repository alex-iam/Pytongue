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

        cls.server = subprocess.Popen(
            ["./zig-out/bin/pytongue"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=dict(
                os.environ,
                PYTONGUE_LOG="/home/alex/Documents/code/zig/pytongue/logs/all.log",
            ),
        )
        time.sleep(1)

    @classmethod
    def teardown_class(cls):
        cls.server.terminate()
        cls.server.wait()

    def send_request(self, request):
        content_length = len(request)
        self.server.stdin.write(
            f"Content-Length: {content_length}\n\n{request}\n".encode()
        )
        self.server.stdin.flush()

        # Read the response
        header = self.server.stdout.readline().decode().strip()
        content_length = int(header.split(": ")[1])
        self.server.stdout.readline()  # Empty line
        return self.server.stdout.read(content_length).decode()

    def test_initialize(self):
        response = self.send_request(json.dumps(self.request_data))
        response_parsed = json.loads(response)
        assert response_parsed["error"] is None
        assert response_parsed["id"] == self.request_data["id"]

    def test_invalid_request(self):
        response = self.send_request("invalid request")
        response_parsed = json.loads(response)
        assert response_parsed["error"] is not None
        assert response_parsed["id"] is None
