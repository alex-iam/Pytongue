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

const std = @import("std");

pub fn parseValue(allocator: std.mem.Allocator, data: []const u8) !std.json.Value {
    var stream = std.io.fixedBufferStream(data);
    var jr = std.json.reader(allocator, stream.reader());
    return std.json.Value.jsonParse(
        allocator,
        &jr,
        .{ .max_value_len = data.len },
    );
}
