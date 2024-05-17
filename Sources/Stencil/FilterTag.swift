// FilterTag.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

class FilterNode: NodeType {
    let resolvable: Resolvable
    let nodes: [NodeType]
    let token: Token?

    class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
        let bits = token.components

        guard bits.count == 2 else {
            throw TemplateSyntaxError("'filter' tag takes one argument, the filter expression")
        }

        let blocks = try parser.parse(until(["endfilter"]))

        guard parser.nextToken() != nil else {
            throw TemplateSyntaxError("`endfilter` was not found.")
        }

        let resolvable = try parser.compileFilter("filter_value|\(bits[1])", containedIn: token)
        return FilterNode(nodes: blocks, resolvable: resolvable, token: token)
    }

    init(nodes: [NodeType], resolvable: Resolvable, token: Token) {
        self.nodes = nodes
        self.resolvable = resolvable
        self.token = token
    }

    func render(_ context: Context) throws -> String {
        let value = try renderNodes(nodes, context)

        return try context.push(dictionary: ["filter_value": value]) {
            try VariableNode(variable: resolvable, token: token).render(context)
        }
    }
}
