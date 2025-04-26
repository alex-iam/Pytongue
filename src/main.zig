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

pub const std_options: std.Options = .{
    .logFn = logMessageFn,
};

pub fn initLogging(allocator: std.mem.Allocator, maybeAppDir: ?[]u8) !void {
    utils.logging.GlobalLogger = Logger.init(allocator);

    var envMap = try std.process.getEnvMap(allocator);
    defer envMap.deinit();

    const fileName: []const u8 = "pytongue.log"; // TODO use app name to construct this

    if (envMap.get("PYTONGUE_LOG")) |lfn| { // only used for testing now
        try utils.logging.GlobalLogger.openLogFile(lfn);
    } else if (maybeAppDir) |appDir| {
        const pathParts = [2][]const u8{ appDir, fileName };
        const path = try std.fs.path.join(allocator, &pathParts);
        try utils.logging.GlobalLogger.openLogFile(path);
    } else {
        return error.LogsInitUnsuccessful;
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
    const appDir: ?[]u8 = utils.files.ensureAppDir(allocator) catch null;
    try initLogging(allocator, appDir);
    try runServer(allocator);
    defer {
        utils.logging.GlobalLogger.deinit();
        allocator.free(appDir);
        arena.deinit();
    }
}
