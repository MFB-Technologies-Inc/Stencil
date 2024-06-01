// ErrorNode.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

import Stencil

class ErrorNode: NodeType {
    let token: Token?
    init(token: Token? = nil) {
        self.token = token
    }

    func render(_: Context) throws -> String {
        throw TemplateSyntaxError("Custom Error")
    }
}
