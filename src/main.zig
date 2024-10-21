const Server = @import("server/server.zig").Server;
const std = @import("std");
const logging = @import("utils/logging.zig");
const h = @import("server/handlers.zig");

pub const std_options = .{
    .logFn = logging.logMessageFn,
};

pub fn initLogging(allocator: std.mem.Allocator) !void {
    logging.GlobalLogger = logging.Logger.init(allocator);

    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    if (env_map.get("PYTONGUE_LOG")) |lfn| {
        try logging.GlobalLogger.openLogFile(lfn);
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try initLogging(allocator);
    defer logging.GlobalLogger.deinit();

    var server = Server{ .baseHandler = &h.baseHandler };
    try server.serve(allocator);
}
