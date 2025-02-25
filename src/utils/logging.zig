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

//! Temporary logging
//! ATTENTION! WRITTEN WITH AI HELP

const std = @import("std");
const time = @import("time.zig");
const f = @import("files.zig");

pub const Logger = struct {
    logFileName: ?[]const u8,
    logFile: ?std.fs.File,
    mutex: std.Thread.Mutex,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Logger {
        return .{
            .logFileName = null,
            .logFile = null,
            .mutex = std.Thread.Mutex{},
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *Logger) void {
        if (self.logFile) |*file| {
            file.close();
        }
        if (self.logFileName) |name| {
            self.allocator.free(name);
        }
    }

    pub fn openLogFile(self: *Logger, filename: []const u8) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        if (self.logFileName) |name| {
            self.allocator.free(name);
        }
        self.logFileName = try self.allocator.dupe(u8, filename);

        if (self.logFile) |*file| {
            file.close();
        }
        self.logFile = f.openFileAppend(filename);
    }
    pub fn log(
        self: *Logger,
        comptime level: std.log.Level,
        comptime scope: @TypeOf(.EnumLiteral),
        comptime format: []const u8,
        args: anytype,
    ) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        if (self.logFile == null or level == .err) {
            std.log.defaultLog(level, scope, format, args);
            return;
        }

        var buffer: [12]u8 = undefined;
        const timestamp = time.getTimestamp(&buffer);
        const prefix = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";
        const msg = std.fmt.allocPrint(
            self.allocator,
            "[{s}] [{s}]{s}" ++ format ++ "\n",
            .{ timestamp, @tagName(level), prefix } ++ args,
        ) catch return;
        defer self.allocator.free(msg);

        self.logFile.?.writeAll(msg) catch unreachable;
    }
};

pub var GlobalLogger: Logger = undefined;

pub fn logMessageFn(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    GlobalLogger.log(level, scope, format, args);
}
