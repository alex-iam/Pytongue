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

pub const BaseDynamicRegistration = struct {
    const dynamicRegistration: ?bool = null;
};

pub const BaseRefreshSupport = struct {
    const refreshSupport: ?bool = null;
};
pub const BaseLinkSupport = struct {
    ///
    /// Whether declaration supports dynamic registration. If this is set to `true`
    /// the client supports the new `DeclarationRegistrationOptions` return value
    /// for the corresponding server capability as well.
    ///
    const dynamicRegistration: ?bool = null;
    ///
    /// The client supports additional metadata in the form of declaration links.
    ///
    const linkSupport: ?bool = null;
};
