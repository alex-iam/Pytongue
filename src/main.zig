// This file is a part of Pytongue.
//
// Copyright (C) 2024, 2025 Oleksandr Korzh
//
// Pytongue is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pytongue is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Pytongue. If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");
const build_options = @import("build_options");

const server = @import("server");
const Server = server.Server;
const Handler = server.Handler;
const StateManager = server.StateManager;

const utils = @import("utils");
const Config = utils.Config;
const logMessageFn = utils.logging.logMessageFn;
const Logger = utils.logging.Logger;

pub const std_options = .{
    .logFn = logMessageFn,
};

pub fn initLogging(allocator: std.mem.Allocator) !void {
    utils.logging.GlobalLogger = Logger.init(allocator);

    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    if (env_map.get("PYTONGUE_LOG")) |lfn| {
        try utils.logging.GlobalLogger.openLogFile(lfn);
    }
}

pub fn runServer(allocator: std.mem.Allocator) !void {
    var stateManager = StateManager{};
    var config = Config{
        .projectName = "Pytongue",
        .projectVersion = build_options.version,
    };
    var handler = Handler.init(&stateManager, allocator, &config);

    var s = Server{ .handler = &handler, .stateManager = &stateManager };
    try s.serve(allocator);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    try initLogging(allocator);
    try runServer(allocator);
    defer {
        utils.logging.GlobalLogger.deinit();
        arena.deinit();
    }
}
