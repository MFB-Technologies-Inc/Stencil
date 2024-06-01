// IfNodeTests.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

@testable import Stencil
import XCTest

final class IfNodeTests: XCTestCase {
    func testParseIf() throws {
        _ = try {
            let tokens: [Token] = [
                .block(value: "if value", at: .unknown),
                .text(value: "true", at: .unknown),
                .block(value: "endif", at: .unknown),
            ]

            let parser = TokenParser(tokens: tokens, environment: Environment())
            let nodes = try parser.parse()
            let node = nodes.first as? IfNode

            let conditions = node?.conditions
            XCTAssertEqual(conditions?.count, 1)
            XCTAssertEqual(conditions?[0].nodes.count, 1)
            let trueNode = conditions?[0].nodes.first as? TextNode
            XCTAssertEqual(
                trueNode?.text,
                "true",
                "can parse an if block"
            )
        }()

        _ = try {
            let tokens: [Token] = [
                .block(
                    value: #"if value == \"test\" and (not name or not (name and surname) or( some )and other )"#,
                    at: .unknown
                ),
                .text(value: "true", at: .unknown),
                .block(value: "endif", at: .unknown),
            ]

            let parser = TokenParser(tokens: tokens, environment: Environment())
            let nodes = try parser.parse()
            XCTAssertTrue(nodes.first is IfNode, "can parse an if with complex expression")
        }()
    }

    func testParseIfWithElse() throws {
        let tokens: [Token] = [
            .block(value: "if value", at: .unknown),
            .text(value: "true", at: .unknown),
            .block(value: "else", at: .unknown),
            .text(value: "false", at: .unknown),
            .block(value: "endif", at: .unknown),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        XCTAssertEqual(conditions?.count, 2)

        XCTAssertEqual(conditions?[0].nodes.count, 1)
        let trueNode = conditions?[0].nodes.first as? TextNode
        XCTAssertEqual(trueNode?.text, "true")

        XCTAssertEqual(conditions?[1].nodes.count, 1)
        let falseNode = conditions?[1].nodes.first as? TextNode
        XCTAssertEqual(falseNode?.text, "false")
    }

    func testParseIfWithElif() throws {
        let tokens: [Token] = [
            .block(value: "if value", at: .unknown),
            .text(value: "true", at: .unknown),
            .block(value: "elif something", at: .unknown),
            .text(value: "some", at: .unknown),
            .block(value: "else", at: .unknown),
            .text(value: "false", at: .unknown),
            .block(value: "endif", at: .unknown),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        XCTAssertEqual(conditions?.count, 3)

        XCTAssertEqual(conditions?[0].nodes.count, 1)
        let trueNode = conditions?[0].nodes.first as? TextNode
        XCTAssertEqual(trueNode?.text, "true")

        XCTAssertEqual(conditions?[1].nodes.count, 1)
        let elifNode = conditions?[1].nodes.first as? TextNode
        XCTAssertEqual(elifNode?.text, "some")

        XCTAssertEqual(conditions?[2].nodes.count, 1)
        let falseNode = conditions?[2].nodes.first as? TextNode
        XCTAssertEqual(falseNode?.text, "false")
    }

    func testParseIfWithElifWithoutElse() throws {
        let tokens: [Token] = [
            .block(value: "if value", at: .unknown),
            .text(value: "true", at: .unknown),
            .block(value: "elif something", at: .unknown),
            .text(value: "some", at: .unknown),
            .block(value: "endif", at: .unknown),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        XCTAssertEqual(conditions?.count, 2)

        XCTAssertEqual(conditions?[0].nodes.count, 1)
        let trueNode = conditions?[0].nodes.first as? TextNode
        XCTAssertEqual(trueNode?.text, "true")

        XCTAssertEqual(conditions?[1].nodes.count, 1)
        let elifNode = conditions?[1].nodes.first as? TextNode
        XCTAssertEqual(elifNode?.text, "some")
    }

    func testParseMultipleElif() throws {
        let tokens: [Token] = [
            .block(value: "if value", at: .unknown),
            .text(value: "true", at: .unknown),
            .block(value: "elif something1", at: .unknown),
            .text(value: "some1", at: .unknown),
            .block(value: "elif something2", at: .unknown),
            .text(value: "some2", at: .unknown),
            .block(value: "else", at: .unknown),
            .text(value: "false", at: .unknown),
            .block(value: "endif", at: .unknown),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode

        let conditions = node?.conditions
        XCTAssertEqual(conditions?.count, 4)

        XCTAssertEqual(conditions?[0].nodes.count, 1)
        let trueNode = conditions?[0].nodes.first as? TextNode
        XCTAssertEqual(trueNode?.text, "true")

        XCTAssertEqual(conditions?[1].nodes.count, 1)
        let elifNode = conditions?[1].nodes.first as? TextNode
        XCTAssertEqual(elifNode?.text, "some1")

        XCTAssertEqual(conditions?[2].nodes.count, 1)
        let elif2Node = conditions?[2].nodes.first as? TextNode
        XCTAssertEqual(elif2Node?.text, "some2")

        XCTAssertEqual(conditions?[3].nodes.count, 1)
        let falseNode = conditions?[3].nodes.first as? TextNode
        XCTAssertEqual(falseNode?.text, "false")
    }

    func testParseIfnot() throws {
        let tokens: [Token] = [
            .block(value: "ifnot value", at: .unknown),
            .text(value: "false", at: .unknown),
            .block(value: "else", at: .unknown),
            .text(value: "true", at: .unknown),
            .block(value: "endif", at: .unknown),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()
        let node = nodes.first as? IfNode
        let conditions = node?.conditions
        XCTAssertEqual(conditions?.count, 2)

        XCTAssertEqual(conditions?[0].nodes.count, 1)
        let trueNode = conditions?[0].nodes.first as? TextNode
        XCTAssertEqual(trueNode?.text, "true")

        XCTAssertEqual(conditions?[1].nodes.count, 1)
        let falseNode = conditions?[1].nodes.first as? TextNode
        XCTAssertEqual(falseNode?.text, "false")
    }

    func testParsingErrors() throws {
        _ = try {
            let tokens: [Token] = [.block(value: "if value", at: .unknown)]

            let parser = TokenParser(tokens: tokens, environment: Environment())
            let expectedError = TemplateSyntaxError(reason: "`endif` was not found.", token: tokens.first)
            try XCTAssertThrowsError(
                parser.parse(),
                "throws an error when parsing an if block without an endif"
            ) { error in
                XCTAssertEqual(error as? TemplateSyntaxError, expectedError)
            }
        }()

        _ = try {
            let tokens: [Token] = [.block(value: "ifnot value", at: .unknown)]

            let parser = TokenParser(tokens: tokens, environment: Environment())
            let expectedError = TemplateSyntaxError(reason: "`endif` was not found.", token: tokens.first)
            try XCTAssertThrowsError(
                parser.parse(),
                "throws an error when parsing an ifnot without an endif"
            ) { error in
                XCTAssertEqual(error as? TemplateSyntaxError, expectedError)
            }
        }()
    }

    func testRendering() throws {
        _ = try {
            let node = IfNode(conditions: [
                IfCondition(expression: VariableExpression(variable: Variable("true")), nodes: [TextNode(text: "1")]),
                IfCondition(expression: VariableExpression(variable: Variable("true")), nodes: [TextNode(text: "2")]),
                IfCondition(expression: nil, nodes: [TextNode(text: "3")]),
            ])

            XCTAssertEqual(
                try node.render(Context()),
                "1",
                "renders a true expression"
            )
        }()

        _ = try {
            let node = IfNode(conditions: [
                IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "1")]),
                IfCondition(expression: VariableExpression(variable: Variable("true")), nodes: [TextNode(text: "2")]),
                IfCondition(expression: nil, nodes: [TextNode(text: "3")]),
            ])

            XCTAssertEqual(
                try node.render(Context()),
                "2",
                "renders the first true expression"
            )
        }()

        _ = try {
            let node = IfNode(conditions: [
                IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "1")]),
                IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "2")]),
                IfCondition(expression: nil, nodes: [TextNode(text: "3")]),
            ])

            XCTAssertEqual(
                try node.render(Context()),
                "3",
                "renders the empty expression when other conditions are falsy"
            )
        }()

        _ = try {
            let node = IfNode(conditions: [
                IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "1")]),
                IfCondition(expression: VariableExpression(variable: Variable("false")), nodes: [TextNode(text: "2")]),
            ])

            XCTAssertEqual(
                try node.render(Context()),
                "",
                "renders empty when no truthy conditions"
            )
        }()
    }

    func testSupportVariableFilters() throws {
        let tokens: [Token] = [
            .block(value: "if value|uppercase == \"TEST\"", at: .unknown),
            .text(value: "true", at: .unknown),
            .block(value: "endif", at: .unknown),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()

        let result = try renderNodes(nodes, Context(dictionary: ["value": "test"]))
        XCTAssertEqual(result, "true")
    }

    func testEvaluatesNilAsFalse() throws {
        let tokens: [Token] = [
            .block(value: "if instance.value", at: .unknown),
            .text(value: "true", at: .unknown),
            .block(value: "endif", at: .unknown),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()

        let result = try renderNodes(nodes, Context(dictionary: ["instance": SomeType()]))
        XCTAssertEqual(result, "")
    }

    func testSupportsRangeVariables() throws {
        let tokens: [Token] = [
            .block(value: "if value in 1...3", at: .unknown),
            .text(value: "true", at: .unknown),
            .block(value: "else", at: .unknown),
            .text(value: "false", at: .unknown),
            .block(value: "endif", at: .unknown),
        ]

        let parser = TokenParser(tokens: tokens, environment: Environment())
        let nodes = try parser.parse()

        try XCTAssertEqual(renderNodes(nodes, Context(dictionary: ["value": 3])), "true")
        try XCTAssertEqual(renderNodes(nodes, Context(dictionary: ["value": 4])), "false")
    }
}

// MARK: - Helpers

private struct SomeType {
    let value: String? = nil
}
