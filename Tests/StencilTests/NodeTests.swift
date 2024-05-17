// NodeTests.swift
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

final class NodeTests: XCTestCase {
    private let context = Context(dictionary: [
        "name": "Kyle",
        "age": 27,
        "items": [1, 2, 3],
    ])

    func testTextNode() throws {
        _ = try {
            let node = TextNode(text: "Hello World")
            XCTAssertEqual(
                try node.render(self.context),
                "Hello World",
                "renders the given text"
            )
        }()
        _ = try {
            let text = "      \n Some text     "
            let trimBehaviour = TrimBehaviour(leading: .whitespace, trailing: .nothing)
            let node = TextNode(text: text, trimBehaviour: trimBehaviour)
            XCTAssertEqual(
                try node.render(self.context),
                "\n Some text     ",
                "Trims leading whitespace"
            )
        }()
        _ = try {
            let text = "\n\n Some text     "
            let trimBehaviour = TrimBehaviour(leading: .whitespaceAndOneNewLine, trailing: .nothing)
            let node = TextNode(text: text, trimBehaviour: trimBehaviour)
            XCTAssertEqual(
                try node.render(self.context),
                "\n Some text     ",
                "Trims leading whitespace and one newline"
            )
        }()
        _ = try {
            let text = "\n\n Some text     "
            let trimBehaviour = TrimBehaviour(leading: .whitespaceAndNewLines, trailing: .nothing)
            let node = TextNode(text: text, trimBehaviour: trimBehaviour)
            XCTAssertEqual(
                try node.render(self.context),
                "Some text     ",
                "Trims leading whitespace and one newline"
            )
        }()
        _ = try {
            let text = "      Some text     \n"
            let trimBehaviour = TrimBehaviour(leading: .nothing, trailing: .whitespace)
            let node = TextNode(text: text, trimBehaviour: trimBehaviour)
            XCTAssertEqual(
                try node.render(self.context),
                "      Some text\n",
                "Trims trailing whitespace"
            )
        }()
        _ = try {
            let text = "      Some text     \n \n "
            let trimBehaviour = TrimBehaviour(leading: .nothing, trailing: .whitespaceAndOneNewLine)
            let node = TextNode(text: text, trimBehaviour: trimBehaviour)
            XCTAssertEqual(
                try node.render(self.context),
                "      Some text     \n ",
                "Trims trailing whitespace and one newline"
            )
        }()
        _ = try {
            let text = "      Some text     \n \n "
            let trimBehaviour = TrimBehaviour(leading: .nothing, trailing: .whitespaceAndNewLines)
            let node = TextNode(text: text, trimBehaviour: trimBehaviour)
            XCTAssertEqual(
                try node.render(self.context),
                "      Some text",
                "Trims trailing whitespace and newlines"
            )
        }()
        _ = try {
            let text = "    \n  \nSome text \n    "
            let trimBehaviour = TrimBehaviour(leading: .whitespaceAndNewLines, trailing: .whitespaceAndNewLines)
            let node = TextNode(text: text, trimBehaviour: trimBehaviour)
            XCTAssertEqual(
                try node.render(self.context),
                "Some text",
                "Trims all whitespace"
            )
        }()
    }

    func testVariableNode() throws {
        _ = try {
            let node = VariableNode(variable: Variable("name"))
            XCTAssertEqual(
                try node.render(self.context),
                "Kyle",
                "resolves and renders the variable"
            )
        }()

        _ = try {
            let node = VariableNode(variable: Variable("age"))
            XCTAssertEqual(
                try node.render(self.context),
                "27",
                "resolves and renders a non string variable"
            )
        }()
    }

    func testRendering() throws {
        _ = try {
            let nodes: [NodeType] = [
                TextNode(text: "Hello "),
                VariableNode(variable: "name"),
            ]

            XCTAssertEqual(
                try renderNodes(nodes, self.context),
                "Hello Kyle",
                "renders the nodes"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [
                TextNode(text: "Hello "),
                VariableNode(variable: "name"),
                ErrorNode(),
            ]

            try XCTAssertThrowsError(
                renderNodes(nodes, self.context),
                "correctly throws a nodes failure"
            ) { error in
                XCTAssertEqual(error as? TemplateSyntaxError, TemplateSyntaxError("Custom Error"))
            }
        }()
    }

    func testRenderingBooleans() throws {
        _ = try {
            try XCTAssertEqual(
                Template(templateString: "{{ true }}").render(),
                "true",
                "can render true & false"
            )
            try XCTAssertEqual(
                Template(templateString: "{{ false }}").render(),
                "false",
                "can render true & false"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ value == \"known\" }}")
            try XCTAssertEqual(
                template.render(["value": "known"]),
                "true",
                "can resolve variable"
            )
            try XCTAssertEqual(
                template.render(["value": "unknown"]),
                "false",
                "can resolve variable"
            )
        }()

        _ = try {
            try XCTAssertEqual(
                Template(templateString: "{{ 1 > 0 }}").render(),
                "true",
                "can render a boolean expression"
            )
            try XCTAssertEqual(
                Template(templateString: "{{ 1 == 2 }}").render(),
                "false",
                "can render a boolean expression"
            )
        }()
    }
}
