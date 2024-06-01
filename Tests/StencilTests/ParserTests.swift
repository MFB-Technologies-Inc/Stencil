// ParserTests.swift
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

final class TokenParserTests: XCTestCase {
    func testTextToken() throws {
        let parser = TokenParser(tokens: [
            .text(value: "Hello World", at: .unknown),
        ], environment: Environment())

        let nodes = try parser.parse()
        let node = nodes.first as? TextNode

        XCTAssertEqual(nodes.count, 1)
        XCTAssertEqual(node?.text, "Hello World")
    }

    func testVariableToken() throws {
        let parser = TokenParser(tokens: [
            .variable(value: "'name'", at: .unknown),
        ], environment: Environment())

        let nodes = try parser.parse()
        let node = nodes.first as? VariableNode
        XCTAssertEqual(nodes.count, 1)
        let result = try node?.render(Context())
        XCTAssertEqual(result, "name")
    }

    func testCommentToken() throws {
        let parser = TokenParser(tokens: [
            .comment(value: "Secret stuff!", at: .unknown),
        ], environment: Environment())

        let nodes = try parser.parse()
        XCTAssertEqual(nodes.count, 0)
    }

    func testTagToken() throws {
        let simpleExtension = Extension()
        simpleExtension.registerSimpleTag("known") { _ in
            ""
        }

        let parser = TokenParser(tokens: [
            .block(value: "known", at: .unknown),
        ], environment: Environment(extensions: [simpleExtension]))

        let nodes = try parser.parse()
        XCTAssertEqual(nodes.count, 1)
    }

    func testErrorUnknownTag() throws {
        let tokens: [Token] = [.block(value: "unknown", at: .unknown)]
        let parser = TokenParser(tokens: tokens, environment: Environment())

        try XCTAssertThrowsError(parser.parse()) { error in
            XCTAssertEqual(
                error as? TemplateSyntaxError,
                TemplateSyntaxError(
                    reason: "Unknown template tag 'unknown'",
                    token: tokens.first
                )
            )
        }
    }

    func testTransformWhitespaceBehaviourToTrimBehaviour() throws {
        let simpleExtension = Extension()
        simpleExtension.registerSimpleTag("known") { _ in "" }

        let parser = TokenParser(tokens: [
            .block(
                value: "known",
                at: .unknown,
                whitespace: WhitespaceBehaviour(leading: .unspecified, trailing: .trim)
            ),
            .text(value: "      \nSome text     ", at: .unknown),
            .block(value: "known", at: .unknown, whitespace: WhitespaceBehaviour(leading: .keep, trailing: .trim)),
        ], environment: Environment(extensions: [simpleExtension]))

        let nodes = try parser.parse()
        XCTAssertEqual(nodes.count, 3)
        let textNode = nodes[1] as? TextNode
        XCTAssertEqual(textNode?.text, "      \nSome text     ")
        XCTAssertEqual(textNode?.trimBehaviour, TrimBehaviour(leading: .whitespaceAndNewLines, trailing: .nothing))
    }
}
