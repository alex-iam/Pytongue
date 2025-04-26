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

/// Creates a directory to store app-local data.
pub fn ensureAppDir(allocator: std.mem.Allocator) ![]u8 {
    const app_name = "pytongue"; // TODO move it to build or constants
    const dir = try std.fs.getAppDataDir(allocator, app_name);
    std.fs.makeDirAbsolute(dir) catch |err| {
        switch (err) {
            error.PathAlreadyExists => {
                return dir;
            },
            else => return err,
        }
    };
    return dir;
}

fn moveToFileEnd(file: std.fs.File) !std.fs.File {
    const stat = try file.stat();
    try file.seekTo(stat.size);
    return file;
}

pub fn openFileAppend(filename: []const u8) !std.fs.File {
    const file = std.fs.openFileAbsolute(
        filename,
        .{ .mode = .write_only },
    ) catch |err| {
        switch (err) {
            error.FileNotFound => {
                const file2 = try std.fs.createFileAbsolute(
                    filename,
                    .{},
                );
                return moveToFileEnd(file2);
            },
            else => return err,
        }
    };
    return moveToFileEnd(file);
}
