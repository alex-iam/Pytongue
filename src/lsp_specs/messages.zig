const types = @import("lsp_types.zig");
const p = @import("params.zig");
pub const Message = struct {
    jsonrpc: []const u8 = "2.0",
};

pub const RequestMessage = struct {
    jsonrpc: []const u8 = "2.0",
    id: []const u8,
    method: []const u8 = "",
    params: ?types.ObjectOrArray = null,
};

pub const NotificationMessage = struct {
    jsonrpc: []const u8 = "2.0",
    method: []const u8 = "",
    params: ?types.ObjectOrArray = null,
};

pub const ResponseError = struct {
    code: i32,
    message: []const u8,
    data: ?types.LSPAny = null,
};

pub const ResponseMessage = struct {
    jsonrpc: []const u8 = "2.0",
    id: ?[]const u8,
    ///
    /// The result of a request. This member is REQUIRED on success.
    /// This member MUST NOT exist if there was an error invoking the method.
    ///
    result: ?p.InitializeResult = null, // actually types.LSPAny, TODO WATCH
    @"error": ?ResponseError = null,
};
