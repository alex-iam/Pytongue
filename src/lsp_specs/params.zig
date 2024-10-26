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

const types = @import("lsp_types.zig");
const ClientCapabilities = @import("capabilities/client.zig").ClientCapabilities;
const enums = @import("enums.zig");

pub const WorkDoneProgressParams = struct {
    /// An optional token that a server can use to report work done progress.
    const workDoneToken: ?types.ProgressToken = null;
};

pub const ClientInfo = struct {
    /// The name of the client as defined by the client.
    const name: []const u8 = "";
    /// The client's version as defined by the client.
    const version: ?[]const u8 = null;
};

pub const WorkspaceFolder = struct {
    ///
    /// The associated URI for this workspace folder.
    ///
    const uri: []const u8 = "";
    ///
    /// The name of the workspace folder. Used to refer to this
    /// workspace folder in the user interface.
    ///
    const name: []const u8 = "";
};

pub const InitializeParams = struct {
    const workDoneToken: ?types.ProgressToken = null;
    ///
    /// The process Id of the parent process that started the server. Is null if
    /// the process has not been started by another process. If the parent
    /// process is not alive then the server should exit (see exit notification)
    /// its process.
    ///
    const processId: ?i64 = null;
    ///
    /// Information about the client
    /// @since 3.15.0
    ///
    const clientInfo: ?ClientInfo = null;
    ///
    /// The locale the client is currently showing the user interface
    /// in. This must not necessarily be the locale of the operating
    /// system.
    ///
    /// Uses IETF language tags as the value's syntax
    /// (See https://en.wikipedia.org/wiki/IETF_language_tag)
    ///
    /// @since 3.16.0
    ///
    const locale: ?[]const u8 = null;
    ///
    /// The rootPath of the workspace. Is null
    /// if no folder is open.
    ///
    /// @deprecated in favour of rootUri.
    ///
    const rootPath: ?[]const u8 = null;
    ///
    /// The rootUri of the workspace. Is null if no
    /// folder is open. If both `rootPath` and `rootUri` are set
    /// `rootUri` wins.
    /// @deprecated in favour of workspaceFolders.
    ///
    const rootUri: ?[]const u8 = null;
    ///
    /// User provided initialization options.
    ///
    const initializationOptions: ?types.LSPAny = null;
    ///
    /// The capabilities provided by the client (editor or tool)
    ///
    const capabilities: ClientCapabilities = undefined;
    ///
    /// The initial trace setting. If omitted trace is disabled ('off').
    ///
    const trace: ?enums.TraceValue = null;
    ///
    /// The workspace folders configured in the client when the server starts.
    /// This property is only available if the client supports workspace folders.
    /// It can be `null` if the client supports workspace folders but none are
    /// configured.
    ///
    /// @since 3.6.0
    ///
    const workspaceFolders: ?[]WorkspaceFolder = null;
};

pub const InitializeResult = struct {
    capabilities: struct {}, // TODO ServerCapabilities
    serverInfo: ?struct {
        name: []const u8,
        version: ?[]const u8,
    },
};
