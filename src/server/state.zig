const std = @import("std");

pub const ServerState = enum {
    Created,
    Started,
    Initialized,
    Shutdown,
    Exited,
};

pub const StateManager = struct {
    state: ServerState = ServerState.Created,
    const validStates = std.StaticStringMap([]const ServerState).initComptime(.{
        .{ @tagName(ServerState.Created), &[_]ServerState{.Started} },
        .{ @tagName(ServerState.Started), &[_]ServerState{.Initialized} },
        .{ @tagName(ServerState.Initialized), &[_]ServerState{.Shutdown} },
        .{ @tagName(ServerState.Shutdown), &[_]ServerState{.Exited} },
        .{ @tagName(ServerState.Exited), &[_]ServerState{} },
    });
    pub fn shouldBeRunning(self: *StateManager) bool {
        return self.state == ServerState.Started or self.state == ServerState.Initialized or self.state == ServerState.Shutdown;
    }
    fn validTransition(self: *StateManager, newState: ServerState) bool {
        if (validStates.get(@tagName(self.state))) |valids| {
            for (valids) |s| {
                if (s == newState) {
                    return true;
                }
            }
        }
        return false;
    }
    fn updateState(self: *StateManager, newState: ServerState) !void {
        if (!self.validTransition(newState)) {
            return error.InvalidTransition;
        }
        self.state = newState;
        std.log.debug("state updated to {s}", .{@tagName(self.state)});
    }
    pub fn startServer(self: *StateManager) !void {
        return self.updateState(ServerState.Started);
    }
    pub fn initServer(self: *StateManager) !void {
        return self.updateState(ServerState.Initialized);
    }
    pub fn shutdownServer(self: *StateManager) !void {
        return self.updateState(ServerState.Shutdown);
    }
    pub fn exitServer(self: *StateManager) !void {
        return self.updateState(ServerState.Exited);
    }
};
