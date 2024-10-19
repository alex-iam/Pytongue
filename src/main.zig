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
    const allocator = arena.allocator();

    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    const lfn = env_map.get("PYTONGUE_LOG");
    logging.log_file_name = lfn;

    var handlers = std.StringHashMap(server.HandlerType).init(allocator);
    defer handlers.deinit();

    try handlers.put("initialize", &h.handleInitialize);
    try handlers.put("shutdown", &h.handleShutown);
    try handlers.put("exit", &h.handleExit);
    try handlers.put("unknown", &h.handleUnknown);

    server.Server.init(
        handlers,
        "exit",
        "unknown",
    );
    try server.Server.serve(allocator);
}
