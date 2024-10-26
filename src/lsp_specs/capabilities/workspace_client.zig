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

const enums = @import("../enums.zig");
const base_c = @import("base.zig");

pub const FileOperations = struct {
    const dynamicRegistration: ?bool = null;
    ///
    /// The client has support for sending didCreateFiles notifications.
    ///
    const didCreate: ?bool = null;
    ///
    /// The client has support for sending willCreateFiles notifications.
    ///
    const willCreate: ?bool = null;
    ///
    /// The client has support for sending didRenameFiles notifications.
    ///
    const didRename: ?bool = null;
    ///
    /// The client has support for sending willRenameFiles notifications.
    ///
    const willRename: ?bool = null;
    ///
    /// The client has support for sending didDeleteFiles notifications.
    ///
    const didDelete: ?bool = null;
    ///
    /// The client has support for sending willDeleteFiles notifications.
    ///
    const willDelete: ?bool = null;
};

pub const DidChangeWatchedFilesClientCapabilities = struct {
    ///
    /// Did change watched files notification supports dynamic registration.
    /// Please note that the current protocol doesn't support static
    /// configuration for file changes from the server side.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// Whether the client has support for relative patterns
    /// or not.
    ///
    /// @since 3.17.0
    ///
    const relativePatternSupport: ?bool = null;
};

pub const WorkspaceSymbolClientCapabilities = struct {
    ///
    /// Symbol request supports dynamic registration.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// Specific capabilities for the `SymbolKind` in the `workspace/symbol` request.
    ///
    const symbolKind: ?struct {
        const valueSet: ?[]enums.SymbolKind = null;
    } = null;
    ///
    /// The client supports tags on `SymbolInformation` and `WorkspaceSymbol`.
    /// Clients supporting tags have to handle unknown tags gracefully.
    ///
    /// @since 3.16.0
    ///
    const tagSupport: ?struct {
        const valueSet: ?[]u64 = null;
    } = null;
    ///
    /// The client supports partial workspace symbols. The client will send the
    /// request `workspaceSymbol/resolve` to the server to resolve additional
    /// properties.
    ///
    /// @since 3.17.0 - proposedState
    ///
    const resolveSupport: ?struct {
        const properties: [][]const u8 = undefined;
    } = null;
};

pub const ChangeAnnotationSupport = struct {
    ///
    /// The client supports additional metadata in the form of change
    /// annotations on text edits, create file, rename file and delete file changes.
    ///
    const groupsOnLabel: ?bool = null;
};

pub const WorkspaceEditClientCapabilities = struct {
    ///
    /// The client supports versioned document changes in `WorkspaceEdit`s
    ///
    const documentChanges: ?bool = null;
    ///
    /// The resource operations the client supports. Clients should at least
    /// support 'create', 'rename' and 'delete' files and folders.
    ///
    const resourceOperations: ?[]const enums.ResourceOperationKind = null;
    ///
    /// The failure handling strategy of a client if applying the workspace edit
    /// fails.
    ///
    const failureHandling: ?enums.FailureHandlingKind = null;
    ///
    /// Whether the client normalizes line endings to the client specific
    /// setting.
    /// If set to `true` the client will normalize line ending characters
    /// in a workspace edit to the client specific new line character(s).
    ///
    /// @since 3.16.0
    ///
    const normalizesLineEndings: ?bool = null;
    ///
    /// Whether the client in general supports change annotations on text edits,
    /// create file, rename file and delete file changes.
    ///
    /// @since 3.16.0
    ///
    const changeAnnotationSupport: ?ChangeAnnotationSupport = null;
};
pub const WorkspaceClientCapabilities = struct {
    ///
    /// The client supports applying batch edits
    /// to the workspace by supporting the request
    /// `workspace/applyEdit`
    ///
    const applyEdit: ?bool = null;
    ///
    /// Capabilities specific to `WorkspaceEdit`s
    ///
    const workspaceEdit: ?WorkspaceEditClientCapabilities = null;
    ///
    /// Capabilities specific to the `workspace/didChangeConfiguration`
    /// notification.
    ///
    const didChangeConfiguration: ?base_c.BaseDynamicRegistration = null;
    ///
    /// Capabilities specific to the `workspace/didChangeWatchedFiles`
    /// notification.
    ///
    const didChangeWatchedFiles: ?DidChangeWatchedFilesClientCapabilities = null;
    ///
    /// Capabilities specific to the `workspace/symbol` request.
    ///
    const symbol: ?WorkspaceSymbolClientCapabilities = null;
    ///
    /// Capabilities specific to the `workspace/executeCommand` request.
    ///
    const executeCommand: ?base_c.BaseDynamicRegistration = null;
    ///
    /// The client has support for workspace folders.
    ///
    /// @since 3.6.0
    ///
    const workspaceFolders: ?bool = null;
    ///
    /// The client supports `workspace/configuration` requests.
    ///
    /// @since 3.6.0
    ///
    const configuration: ?bool = null;
    ///
    /// Capabilities specific to the semantic token requests scoped to the
    /// workspace.
    ///
    /// @since 3.16.0
    ///
    const semanticTokens: ?base_c.BaseRefreshSupport = null;
    ///
    /// Capabilities specific to the code lens requests scoped to the
    /// workspace.
    ///
    /// @since 3.16.0
    ///
    const codeLens: ?base_c.BaseRefreshSupport = null;
    ///
    /// The client has support for file requests/notifications.
    ///
    /// @since 3.16.0
    ///
    const fileOperations: ?FileOperations = null;
    ///
    /// Client workspace capabilities specific to inline values.
    ///
    /// @since 3.17.0
    ///
    const inlineValues: ?base_c.BaseRefreshSupport = null;
    ///
    /// Client workspace capabilities specific to inlay hints.
    ///
    /// @since 3.17.0
    ///
    const inlayHint: ?base_c.BaseRefreshSupport = null;
    ///
    /// Client workspace capabilities specific to diagnostics
    ///
    /// @since 3.17.0
    ///
    const diagnostics: ?base_c.BaseRefreshSupport = null;
};
