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

pub fn getTimestamp(buffer: []u8) []const u8 {
    const timestamp = std.time.timestamp();
    const epoch_seconds: u64 = @intCast(@mod(timestamp, 86400)); // Seconds since start of day
    const hours: u64 = @intCast(@divFloor(epoch_seconds, 3600));
    const minutes: u64 = @intCast(@divFloor(@mod(epoch_seconds, 3600), 60));
    const seconds: u64 = @intCast(@mod(epoch_seconds, 60));

    return std.fmt.bufPrint(
        buffer,
        "{:0>2}:{:0>2}:{:0>2}",
        .{ hours, minutes, seconds },
    ) catch unreachable;
}
