const server = @import("server.zig");
const std = @import("std");
const logging = @import("utils/logging.zig");
const h = @import("handlers.zig");

pub const std_options = .{
    .logFn = logging.logMessageFn,
};

pub fn initHandlers(allocator: std.mem.Allocator) !std.StringHashMap(server.HandlerType) {
    var handlers = std.StringHashMap(server.HandlerType).init(allocator);

    try handlers.put("initialize", &h.handleInitialize);
    try handlers.put("shutdown", &h.handleShutown);
    try handlers.put("exit", &h.handleExit);
    try handlers.put("unknown", &h.handleUnknown);
    return handlers;
}

pub fn initEnv(allocator: std.mem.Allocator) !void {
    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    if (env_map.get("PYTONGUE_LOG")) |lfn| {
        logging.log_file_name = try allocator.dupe(u8, lfn);
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var handlers = try initHandlers(allocator);
    defer handlers.deinit();
    try initEnv(allocator);
    defer {
        if (logging.log_file_name) |lfn| {
            allocator.free(lfn);
        }
    }

    server.Server.init(
        handlers,
        "exit",
        "unknown",
    );
    try server.Server.serve(allocator);
}
