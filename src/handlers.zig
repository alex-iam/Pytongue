const Server = @import("server/server.zig").Server;
const std = @import("std");
const StateManager = @import("server/state.zig").StateManager;

pub fn baseHandler(_: *StateManager, _: []const u8) []const u8 {
    return "Your request is very important for us";
}
