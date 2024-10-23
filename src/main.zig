const Server = @import("server/server.zig").Server;
const std = @import("std");
const logging = @import("utils/logging.zig");
const Handler = @import("server/handlers.zig").Handler;
const StateManager = @import("server/state.zig").StateManager;
const Config = @import("utils/config.zig").Config;
const build_options = @import("build_options");

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

    const allocator = arena.allocator();

    try initLogging(allocator);

    var stateManager = StateManager{};
    var config = Config{
        .projectName = "Pytongue",
        .projectVersion = build_options.version,
    };
    var handler = Handler.init(&stateManager, allocator, &config);

    defer {
        logging.GlobalLogger.deinit();
        arena.deinit();
    }

    var server = Server{ .handler = &handler, .stateManager = &stateManager };
    try server.serve(allocator);
}
