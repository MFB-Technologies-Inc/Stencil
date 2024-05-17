// TrimBehaviourTests.swift
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

final class TrimBehaviourTests: XCTestCase {
    func testSmartTrimCanRemoveNewlines() throws {
        let templateString = """
        {% for item in items %}
          - {{item}}
        {% endfor %}
        text
        """

        let context = ["items": ["item 1", "item 2"]]
        let template = Template(templateString: templateString, environment: .init(trimBehaviour: .smart))
        let result = try template.render(context)

        // swiftlint:disable indentation_width
        XCTAssertEqual(result, """
          - item 1
          - item 2
        text
        """)
        // swiftlint:enable indentation_width
    }

    func testSmartTrimOnlyRemoveSingleNewlines() throws {
        let templateString = """
        {% for item in items %}

          - {{item}}
        {% endfor %}
        text
        """

        let context = ["items": ["item 1", "item 2"]]
        let template = Template(templateString: templateString, environment: .init(trimBehaviour: .smart))
        let result = try template.render(context)

        // swiftlint:disable indentation_width
        XCTAssertEqual(result, """

          - item 1

          - item 2
        text
        """)
        // swiftlint:enable indentation_width
    }

    func testSmartTrimCanRemoveNewlinesWhileKeepingWhitespace() throws {
        // swiftlint:disable indentation_width
        let templateString = """
            Items:
            {% for item in items %}
                - {{item}}
            {% endfor %}
        """
        // swiftlint:enable indentation_width

        let context = ["items": ["item 1", "item 2"]]
        let template = Template(templateString: templateString, environment: .init(trimBehaviour: .smart))
        let result = try template.render(context)

        // swiftlint:disable indentation_width
        XCTAssertEqual(result, """
            Items:
                - item 1
                - item 2

        """)
        // swiftlint:enable indentation_width
    }

    func testTrimSymbols() throws {
        _ = try {
            // swiftlint:disable indentation_width
            let template: Template = """
            {% for num in numbers -%}
                {{num}}
            {%- endfor %}
            """
            // swiftlint:enable indentation_width
            let result = try template.render(["numbers": Array(1 ... 9)])
            XCTAssertEqual(
                result,
                "123456789",
                "Respects whitespace control symbols in for tags"
            )
        }()
        _ = try {
            let template: Template = """
            {% if value -%}
              {{text}}
            {%- endif %}
            """
            let result = try template.render(["text": "hello", "value": true])
            XCTAssertEqual(
                result,
                "hello",
                "Respects whitespace control symbols in if tags"
            )
        }()
    }

    func testTrimSymbolsOverridingEnvironment() throws {
        let environment = Environment(trimBehaviour: .all)

        _ = try {
            // swiftlint:disable indentation_width
            let templateString = """
              {% if value +%}
              {{text}}
            {%+ endif %}

            """
            // swiftlint:enable indentation_width
            let template = Template(templateString: templateString, environment: environment)
            let result = try template.render(["text": "hello", "value": true])
            XCTAssertEqual(
                result,
                "\n  hello\n",
                "respects whitespace control symbols in if tags"
            )
        }()

        _ = try {
            // swiftlint:disable indentation_width
            let templateString = """
                Items:{% for item in items +%}
                    - {{item}}
                {%- endfor %}
            """
            // swiftlint:enable indentation_width

            let context = ["items": ["item 1", "item 2"]]
            let template = Template(templateString: templateString, environment: environment)
            let result = try template.render(context)

            // swiftlint:disable indentation_width
            XCTAssertEqual(
                result,
                """
                    Items:
                        - item 1
                        - item 2
                """,
                "can customize blocks on same line as text"
            )
            // swiftlint:enable indentation_width
        }()
    }
}
