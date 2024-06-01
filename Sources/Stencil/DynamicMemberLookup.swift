// DynamicMemberLookup.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

/// Marker protocol so we can know which types support `@dynamicMemberLookup`. Add this to your own types that support
/// lookup by String.
public protocol DynamicMemberLookup {
    /// Get a value for a given `String` key
    subscript(dynamicMember _: String) -> Any? { get }
}

extension DynamicMemberLookup where Self: RawRepresentable {
    /// Get a value for a given `String` key
    public subscript(dynamicMember member: String) -> Any? {
        switch member {
        case "rawValue":
            rawValue
        default:
            nil
        }
    }
}
