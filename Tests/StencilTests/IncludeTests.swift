// IncludeTests.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

import PathKit
@testable import Stencil
import XCTest

final class IncludeTests: StencilTestCase {
    private lazy var path = Path(Self.fixtures)
    private lazy var loader = FileSystemLoader(paths: [path])
    private lazy var environment = Environment(loader: loader)

    override class func setUp() {
        super.setUp()
        try! setupFixtures()
    }

    func testParsing() throws {
        _ = try {
            let tokens: [Token] = [.block(value: "include", at: .unknown)]
            let parser = TokenParser(tokens: tokens, environment: Environment())

            let expectedError = TemplateSyntaxError(reason: """
            'include' tag requires one argument, the template file to be included. \
            A second optional argument can be used to specify the context that will \
            be passed to the included file
            """, token: tokens.first)
            try XCTAssertThrowsError(
                parser.parse(),
                "throws an error when no template is given"
            ) { error in
                XCTAssertEqual(error as? TemplateSyntaxError, expectedError)
            }
        }()

        _ = try {
            let tokens: [Token] = [.block(value: "include \"test.html\"", at: .unknown)]
            let parser = TokenParser(tokens: tokens, environment: Environment())

            let nodes = try parser.parse()
            let node = nodes.first as? IncludeNode
            XCTAssertEqual(
                nodes.count,
                1,
                "can parse a valid include block"
            )
            XCTAssertEqual(
                node?.templateName,
                Variable("\"test.html\""),
                "can parse a valid include block"
            )
        }()
    }

    func testRendering() throws {
        _ = try {
            let node = IncludeNode(templateName: Variable("\"test.html\""), token: .block(value: "", at: .unknown))

            try XCTAssertThrowsError(
                node.render(Context()),
                "throws an error when rendering without a loader"
            ) { error in
                XCTAssertEqual(
                    (error as? TemplateDoesNotExist)?.description,
                    "Template named `test.html` does not exist. No loaders found"
                )
            }
        }()

        _ = try {
            let node = IncludeNode(templateName: Variable("\"unknown.html\""), token: .block(value: "", at: .unknown))

            try XCTAssertThrowsError(
                node.render(Context(environment: self.environment)),
                "throws an error when it cannot find the included template"
            ) { error in
                guard let description = (error as? TemplateDoesNotExist)?.description else {
                    XCTFail("Expected a `TemplateDoesNotExist` error")
                    return
                }
                XCTAssertTrue(
                    description.hasPrefix("Template named `unknown.html` does not exist in loader")
                )
            }
        }()

        _ = try {
            let node = IncludeNode(templateName: Variable("\"test.html\""), token: .block(value: "", at: .unknown))
            let context = Context(dictionary: ["target": "World"], environment: self.environment)
            let value = try node.render(context)
            XCTAssertEqual(
                value,
                "Hello World!",
                "successfully renders a found included template"
            )
        }()

        _ = try {
            let template = Template(templateString: #"{% include "test.html" child %}"#)
            let context = Context(dictionary: ["child": ["target": "World"]], environment: self.environment)
            let value = try template.render(context)
            XCTAssertEqual(
                value,
                "Hello World!",
                "successfully passes context"
            )
        }()
    }
}
