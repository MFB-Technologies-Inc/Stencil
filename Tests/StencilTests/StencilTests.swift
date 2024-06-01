// StencilTests.swift
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
import XCTest

final class StencilTests: XCTestCase {
    private lazy var environment: Environment = {
        let exampleExtension = Extension()
        exampleExtension.registerSimpleTag("simpletag") { _ in
            "Hello World"
        }
        exampleExtension.registerTag("customtag") { _, token in
            CustomNode(token: token)
        }
        return Environment(extensions: [exampleExtension])
    }()

    func testStencil() throws {
        _ = try {
            let templateString = """
            There are {{ articles.count }} articles.

            {% for article in articles %}\
              - {{ article.title }} by {{ article.author }}.
            {% endfor %}
            """

            let context = [
                "articles": [
                    Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
                    Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
                ],
            ]

            let template = Template(templateString: templateString)
            let result = try template.render(context)

            XCTAssertEqual(
                result,
                """
                There are 2 articles.

                  - Migrating from OCUnit to XCTest by Kyle Fuller.
                  - Memory Management with ARC by Kyle Fuller.

                """,
                "can render the README example"
            )
        }()

        _ = try {
            let result = try self.environment.renderTemplate(string: "{% customtag %}")
            XCTAssertEqual(
                result,
                "Hello World",
                "can render a custom template tag"
            )
        }()

        _ = try {
            let result = try self.environment.renderTemplate(string: "{% simpletag %}")
            XCTAssertEqual(
                result,
                "Hello World",
                "can render a simple custom tag"
            )
        }()
    }
}

// MARK: - Helpers

private struct CustomNode: NodeType {
    let token: Token?
    func render(_: Context) throws -> String {
        "Hello World"
    }
}

private struct Article {
    let title: String
    let author: String
}
