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

const WorkspaceClientCapabilities = @import("workspace_client.zig").WorkspaceClientCapabilities;
const TextDocumentClientCapabilities = @import("text_document_client.zig").TextDocumentClientCapabilities;

pub const NotebookDocumentSyncClientCapabilities = struct {
    ///
    /// Whether implementation supports dynamic registration. If this is
    /// set to `true` the client supports the new
    /// `(TextDocumentRegistrationOptions & StaticRegistrationOptions)`
    /// return value for the corresponding server capability as well.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The client supports sending execution summary data per cell.
    ///
    const executionSummarySupport: ?bool = null;
};

pub const NotebookDocumentClientCapabilities = struct {
    ///
    /// Capabilities specific to notebook document synchronization
    ///
    /// @since 3.17.0
    ///
    const synchronization: NotebookDocumentSyncClientCapabilities = undefined;
};

pub const ClientCapabilities = struct {
    ///
    /// Workspace specific client capabilities.
    ///
    const workspace: ?WorkspaceClientCapabilities = null;
    ///
    /// Text document specific client capabilities.
    ///
    const textDocument: ?TextDocumentClientCapabilities = null;
    ///
    /// Capabilities specific to the notebook document support.
    ///
    /// @since 3.17.0
    ///
    const notebookDocument: ?NotebookDocumentClientCapabilities = null;
};
