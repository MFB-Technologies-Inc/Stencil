// NowTag.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

#if !os(Linux)
    import Foundation

    class NowNode: NodeType {
        let format: Variable
        let token: Token?

        class func parse(_: TokenParser, token: Token) throws -> NodeType {
            var format: Variable?

            let components = token.components
            guard components.count <= 2 else {
                throw TemplateSyntaxError("'now' tags may only have one argument: the format string.")
            }
            if components.count == 2 {
                format = Variable(components[1])
            }

            return NowNode(format: format, token: token)
        }

        init(format: Variable?, token: Token? = nil) {
            self.format = format ?? Variable("\"yyyy-MM-dd 'at' HH:mm\"")
            self.token = token
        }

        func render(_ context: Context) throws -> String {
            let date = Date()
            let format = try format.resolve(context)

            var formatter: DateFormatter
            if let format = format as? DateFormatter {
                formatter = format
            } else if let format = format as? String {
                formatter = DateFormatter()
                formatter.dateFormat = format
            } else {
                return ""
            }

            return formatter.string(from: date)
        }
    }
#endif
