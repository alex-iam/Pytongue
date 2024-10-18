const std = @import("std");

pub const Server = struct {
    const Self = @This();
    var running: bool = false;
    var initialized: bool = false;

    pub fn parseRequest() ![]const u8 {
        std.log.debug("server parseRequest", .{});
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

        var header = try std.io.getStdIn().reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
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
        return content;
    }

    pub fn sendResponse(response: []const u8) !void {
        std.log.debug("server sendResponse", .{});
        const stdout = std.io.getStdOut().writer();
        try stdout.print("Content-Length: {d}\r\n\r\n", .{response.len});
        try stdout.writeAll(response);
    }

    pub fn handleExit() void {
        std.log.debug("server handleExit", .{});
        Self.running = false;
    }

    pub fn init() void {
        Self.running = true;
        std.log.debug("server init", .{});
    }

    pub fn serve() !void {
        std.log.debug("server serve", .{});
        while (Self.running) {
            const request = try Self.parseRequest();
            if (request.len == 0) {
                std.log.debug("server serve empty request", .{});
                continue;
            }

            if (std.mem.startsWith(u8, request, "initialize")) {
                std.log.debug("initialize request", .{});
                try Self.sendResponse("Initialized with basic capabilities");
            } else if (std.mem.startsWith(u8, request, "shutdown")) {
                std.log.debug("shutdown request", .{});
                try Self.sendResponse("Server shutting down");
            } else if (std.mem.startsWith(u8, request, "exit")) {
                std.log.debug("exit request", .{});
                Self.handleExit();
            } else {
                std.log.debug("unknown request", .{});
                try Self.sendResponse("Unknown method");
            }
        }
    }
};
