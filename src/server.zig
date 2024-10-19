const std = @import("std");

pub const HandlerType = *const fn ([]const u8) []const u8;

// pub const ServerState = enum {
//     Created,
//     Started,
//     Initialized,
//     Shutdown,
//     pub fn validateMove(from: ServerState, to: ServerState) bool {}
// };

pub const Server = struct {
    running: bool = false,
    handlers: std.StringHashMap(HandlerType) = undefined,
    exitHandler: []const u8 = "",
    unknownHandler: []const u8 = "",

    fn exit(self: *Server) void {
        std.log.debug("server exit", .{});
        self.running = false;
    }

    fn parseRequest(_: *Server, allocator: std.mem.Allocator) ![]const u8 {
        std.log.debug("server parseRequest", .{});

        var header = try std.io.getStdIn().reader().readUntilDelimiterAlloc(
            allocator,
            '\n',
            std.math.maxInt(usize),
        );
        defer allocator.free(header);

        if (header.len == 0) {
            return "";
        }
        var contentLength: usize = 0;
        if (std.mem.startsWith(u8, header, "Content-Length: ")) {
            contentLength = try std.fmt.parseInt(usize, header[16..], 10);
        }
        // Ignore the empty line
        _ = try std.io.getStdIn().reader().skipUntilDelimiterOrEof('\n');
        const content = try allocator.alloc(u8, contentLength);
        defer allocator.free(content);

        const bytesRead = try std.io.getStdIn().reader().readAll(content);
        if (bytesRead != contentLength) {
            return error.UnexpectedEOF;
        }
        std.log.debug("server parseRequest {s}", .{content});
        return try allocator.dupe(u8, content);
    }

    fn sendResponse(_: *Server, response: []const u8) void {
        std.log.debug("server sendResponse", .{});
        const stdout = std.io.getStdOut().writer();
        stdout.print("Content-Length: {d}\r\n\r\n", .{response.len}) catch unreachable;
        stdout.writeAll(response) catch unreachable;
    }

    pub fn init(
        h: std.StringHashMap(HandlerType),
        e: []const u8,
        u: []const u8,
    ) Server {
        std.log.debug("server init", .{});
        return Server{
            .running = true,
            .handlers = h,
            .exitHandler = e,
            .unknownHandler = u,
        };
    }

    pub fn serve(self: *Server, allocator: std.mem.Allocator) !void {
        std.log.debug("server serve", .{});
        while (self.running) {
            const request = try self.parseRequest(allocator);
            if (request.len == 0) {
                std.log.debug("server serve empty request", .{});
                continue;
            }

            var it = self.handlers.iterator();
            var found = false;
            while (it.next()) |kv| {
                if (std.mem.startsWith(u8, request, kv.key_ptr.*)) {
                    std.log.debug("found handler for {s}", .{kv.key_ptr.*});
                    found = true;

                    if (std.mem.eql(u8, kv.key_ptr.*, self.exitHandler)) {
                        self.exit();
                    } else {
                        const response = kv.value_ptr.*(request);
                        self.sendResponse(response);
                    }
                }
            }
            if (!found) {
                std.log.debug("handler for request not found", .{});
                const unk: HandlerType = self.handlers.get(self.unknownHandler).?;
                const response = unk(request);
                self.sendResponse(response);
            }
        }
    }
};
