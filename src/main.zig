const server = @import("server.zig");
const std = @import("std");
const logging = @import("utils/logging.zig");
const h = @import("handlers.zig");

pub const std_options = .{
    .logFn = logging.logMessageFn,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var handlers = std.StringHashMap(server.HandlerType).init(arena.allocator());
    defer handlers.deinit();

    try handlers.put("initialize", &h.handleInitialize);
    try handlers.put("shutdown", &h.handleInitialize);
    try handlers.put("exit", &h.handleInitialize);
    try handlers.put("unknown", &h.handleInitialize);

    server.Server.init(
        handlers,
        "exit",
        "unknown",
    );
    try server.Server.serve();
}
