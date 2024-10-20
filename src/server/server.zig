const std = @import("std");
const StateManager = @import("state.zig").StateManager;

pub const Server = struct {
    stateManager: StateManager = .{},
    baseHandler: *const fn (*StateManager, []const u8) []const u8,

    fn parseRequest(_: *Server, allocator: std.mem.Allocator) ![]const u8 {
        std.log.debug("server parseRequest", .{});

        // TODO: there might be optional Content-Type header

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

    pub fn serve(self: *Server, allocator: std.mem.Allocator) !void {
        std.log.debug("server serve", .{});
        try self.stateManager.startServer();
        while (self.stateManager.shouldBeRunning()) {
            const request = try self.parseRequest(allocator);
            if (request.len == 0) {
                std.log.debug("server serve empty request", .{});
                continue;
            }
            const response = self.baseHandler(&self.stateManager, request);
            self.sendResponse(response);
        }
    }
};
