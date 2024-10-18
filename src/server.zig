const std = @import("std");

pub const HandlerType = *const fn (
    *const fn (response: []const u8) void,
    []const u8,
) void;

pub const Server = struct {
    const Self = @This();
    var running: bool = false;
    var initialized: bool = false;
    pub var handlers: std.StringHashMap(HandlerType) = undefined;
    pub var exitHandler: []const u8 = "";
    pub var unknownHandler: []const u8 = "";

    pub fn exit() void {
        std.log.debug("server exit", .{});
        Self.running = false;
    }

    pub fn parseRequest() ![]const u8 {
        std.log.debug("server parseRequest", .{});
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();
        const allocator = gpa.allocator();

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
        return content;
    }

    pub fn sendResponse(response: []const u8) void {
        std.log.debug("server sendResponse", .{});
        const stdout = std.io.getStdOut().writer();
        stdout.print("Content-Length: {d}\r\n\r\n", .{response.len}) catch unreachable;
        stdout.writeAll(response) catch unreachable;
    }

    pub fn init(
        h: std.StringHashMap(HandlerType),
        e: []const u8,
        u: []const u8,
    ) void {
        Self.running = true;
        handlers = h;
        exitHandler = e;
        unknownHandler = u;
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

            var it = handlers.iterator();
            var found = false;
            while (it.next()) |kv| {
                if (std.mem.startsWith(u8, request, kv.key_ptr.*)) {
                    std.log.debug("found handler for {s}", .{kv.key_ptr.*});
                    found = true;
                    kv.value_ptr.*(&Self.sendResponse, request);
                    if (std.mem.eql(u8, kv.key_ptr.*, exitHandler)) {
                        Self.exit();
                    }
                }
            }
            if (!found) {
                std.log.debug("handler for request not found", .{});
                const unk: HandlerType = handlers.get(unknownHandler).?;
                unk(&Self.sendResponse, request);
            }
        }
    }
};
