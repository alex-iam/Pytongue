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

const types = @import("lsp_types.zig");
const p = @import("params.zig");
const e = @import("enums.zig");
pub const Message = struct {
    jsonrpc: []const u8 = "2.0",
};

pub const RequestMessage = struct {
    jsonrpc: []const u8 = "2.0",
    id: types.IntOrString,
    method: e.RequestMethod,
    params: ?types.ObjectOrArray = null,
};

pub const NotificationMessage = struct {
    jsonrpc: []const u8 = "2.0",
    method: e.RequestMethod,
    params: ?types.ObjectOrArray = null,
};

pub const ResponseError = struct {
    code: i32,
    message: []const u8,
    data: ?types.LSPAny = null,
};

pub const ResponseMessage = struct {
    jsonrpc: []const u8 = "2.0",
    id: ?types.IntOrString,
    ///
    /// The result of a request. This member is REQUIRED on success.
    /// This member MUST NOT exist if there was an error invoking the method.
    ///
    result: ?p.InitializeResult = null, // actually types.LSPAny, TODO WATCH
    @"error": ?ResponseError = null,
};
