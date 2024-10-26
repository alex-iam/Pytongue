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

pub const RequestMethod = enum {
    initialize,
    shutdown,
};
pub const NotificationMethod = enum {
    initialized,
    exit,
};
pub const TraceValue = enum {
    off,
    messages,
    verbose,
};
pub const ResourceOperationKind = enum {
    create,
    rename,
    delete,
};
pub const FailureHandlingKind = enum {
    abort,
    transactional,
    textOnlyTransactional,
    undo,
};

pub const SymbolKind = enum { File, Module, Namespace, Package, Class, Method, Property, Field, Constructor, Enum, Interface, Function, Variable, Constant, String, Number, Boolean, Array, Object, Key, Null, EnumMember, Struct, Event, Operator, TypeParameter };

pub const MarkupKind = enum {
    plaintext,
    markdown,
};
pub const InsertTextMode = enum {
    asIs,
    adjustIndentation,
};
pub const CompletionItemKind = enum {
    Text,
    Method,
    Function,
    Constructor,
    Field,
    Variable,
    Class,
    Interface,
    Module,
    Property,
    Unit,
    Value,
    Enum,
    Keyword,
    Snippet,
    Color,
    File,
    Reference,
    Folder,
    EnumMember,
    Constant,
    Struct,
    Event,
    Operator,
    TypeParameter,
};
pub const CodeActionKind = [_][]const u8{ "", "quickfix", "refactor", "refactor.extract", "refactor.inline", "refactor.rewrite", "source", "source.organizeImports", "source.fixAll" };

pub const DiagnosticTag = enum {
    ///
    /// Unused or unnecessary code.
    ///
    /// Clients are allowed to render diagnostics with this tag faded out
    /// instead of having an error squiggle.
    ///
    Unnecessary,
    ///
    /// Deprecated or obsolete code.
    ///
    /// Clients are allowed to rendered diagnostics with this tag strike through.
    ///
    Deprecated,
};
pub const FoldingRangeKind = enum {
    ///
    /// Folding range for a comment
    ///
    comment,
    ///
    /// Folding range for a imports or includes
    ///
    imports,
    ///
    /// Folding range for a region (e.g. `#region`)
    ///
    region,
};
