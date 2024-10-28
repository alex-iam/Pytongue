// This file is a part of Pytongue.
//
// Copyright (C) 2024 Oleksandr Korzh
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

const Server = @import("server/server.zig").Server;
const std = @import("std");
const logging = @import("utils/logging.zig");
const Handler = @import("server/handlers.zig").Handler;
const StateManager = @import("server/state.zig").StateManager;
const Config = @import("utils/config.zig").Config;
const build_options = @import("build_options");
const args = @import("utils/args.zig");
const parser = @import("parser/parser.zig");
const ts = @import("parser/tree-sitter.zig");

pub const std_options = .{
    .logFn = logging.logMessageFn,
};

pub const RunOptions = enum {
    server,
    parser,
};

pub fn initLogging(allocator: std.mem.Allocator) !void {
    logging.GlobalLogger = logging.Logger.init(allocator);

    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    if (env_map.get("PYTONGUE_LOG")) |lfn| {
        try logging.GlobalLogger.openLogFile(lfn);
    }
}

pub fn runServer(allocator: std.mem.Allocator) !void {
    var stateManager = StateManager{};
    var config = Config{
        .projectName = "Pytongue",
        .projectVersion = build_options.version,
    };
    var handler = Handler.init(&stateManager, allocator, &config);

    var server = Server{ .handler = &handler, .stateManager = &stateManager };
    try server.serve(allocator);
}

pub fn runParser() !void {
    const code =
        \\ x = "Hello, World!"
        \\ print(x)
        \\ y = 2
        \\ print(y + 7)
    ;
    const p = ts.TreeSitter.ts_parser_new().?;
    defer ts.TreeSitter.ts_parser_delete(p);

    _ = ts.TreeSitter.ts_parser_set_language(p, ts.tree_sitter_python());

    const pythonFile = try parser.PythonFile.init(code, p);
    defer pythonFile.deinit();
    pythonFile.printTree();
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    try initLogging(allocator);

    const option = try args.parseOptionFromArgs(allocator);
    switch (std.meta.stringToEnum(RunOptions, option).?) {
        RunOptions.server => try runServer(allocator),
        RunOptions.parser => try runParser(),
    }

    defer {
        logging.GlobalLogger.deinit();
        arena.deinit();
    }
}
