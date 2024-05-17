// FilterTests.swift
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

final class FilterTests: XCTestCase {
    func testRegistration() throws {
        let context: [String: Any] = ["name": "Kyle"]

        _ = try {
            let template = Template(templateString: "{{ name|repeat }}")

            let repeatExtension = Extension()
            repeatExtension.registerFilter("repeat") { (value: Any?) in
                if let value = value as? String {
                    return "\(value) \(value)"
                }

                return nil
            }

            let result = try template.render(Context(
                dictionary: context,
                environment: Environment(extensions: [repeatExtension])
            ))
            XCTAssertEqual(
                result,
                "Kyle Kyle",
                "allows you to register a custom filter"
            )
        }()

        _ = try {
            let repeatExtension = Extension()
            repeatExtension.registerFilter(name: "isPositive", negativeFilterName: "isNotPositive") { (value: Any?) in
                if let value = value as? Int {
                    return value > 0
                }
                return nil
            }

            let result = try Template(templateString: "{{ value|isPositive }}")
                .render(Context(dictionary: ["value": 1], environment: Environment(extensions: [repeatExtension])))
            XCTAssertEqual(
                result,
                "true",
                "allows you to register boolean filters"
            )

            let negativeResult = try Template(templateString: "{{ value|isNotPositive }}")
                .render(Context(dictionary: ["value": -1], environment: Environment(extensions: [repeatExtension])))
            XCTAssertEqual(
                negativeResult,
                "true",
                "allows you to register boolean filters"
            )
        }()
        _ = try {
            let template = Template(templateString: "{{ name|repeat }}")
            let repeatExtension = Extension()
            repeatExtension.registerFilter("repeat") { (_: Any?) in
                throw TemplateSyntaxError("No Repeat")
            }

            let context = Context(dictionary: context, environment: Environment(extensions: [repeatExtension]))
            try XCTAssertThrowsError(
                template.render(context),
                "allows you to register a custom which throws"
            ) { error in
                let error = error as? TemplateSyntaxError
                XCTAssertEqual(error, TemplateSyntaxError(reason: "No Repeat", token: template.tokens.first))
            }
        }()

        _ = try {
            let template = Template(templateString: "{{ name|uppercase:5 }}")
            try XCTAssertThrowsError(
                template.render(Context(dictionary: ["name": "kyle"])),
                "throws when you pass arguments to simple filter"
            ) { error in
                let error = error as? TemplateSyntaxError
                XCTAssertEqual(
                    error,
                    TemplateSyntaxError(
                        reason: "Can't invoke filter with an argument",
                        token: template.tokens.first
                    )
                )
            }
        }()
    }

    func testRegistrationOverrideDefault() throws {
        let template = Template(templateString: "{{ name|join }}")
        let context: [String: Any] = ["name": "Kyle"]

        let repeatExtension = Extension()
        repeatExtension.registerFilter("join") { (_: Any?) in
            "joined"
        }

        let result = try template.render(Context(
            dictionary: context,
            environment: Environment(extensions: [repeatExtension])
        ))
        XCTAssertEqual(result, "joined")
    }

    func testRegistrationWithArguments() throws {
        let context: [String: Any] = ["name": "Kyle"]

        _ = try {
            let template = Template(templateString: #"{{ name|repeat:'value1, "value2"' }}"#)

            let repeatExtension = Extension()
            repeatExtension.registerFilter("repeat") { value, arguments in
                guard let value,
                      let argument = arguments.first else { return nil }

                return "\(value) \(value) with args \(argument ?? "")"
            }

            let result = try template.render(Context(
                dictionary: context,
                environment: Environment(extensions: [repeatExtension])
            ))

            XCTAssertEqual(
                result,
                #"Kyle Kyle with args value1, "value2""#,
                "allows you to register a custom filter which accepts single argument"
            )
        }()

        _ = try {
            let template = Template(templateString: #"{{ name|repeat:'value"1"',"value'2'",'(key, value)' }}"#)

            let repeatExtension = Extension()
            repeatExtension.registerFilter("repeat") { value, arguments in
                guard let value else { return nil }
                let args = arguments.compactMap { $0 }
                return "\(value) \(value) with args 0: \(args[0]), 1: \(args[1]), 2: \(args[2])"
            }

            let result = try template.render(Context(
                dictionary: context,
                environment: Environment(extensions: [repeatExtension])
            ))
            XCTAssertEqual(
                result,
                #"Kyle Kyle with args 0: value"1", 1: value'2', 2: (key, value)"#,
                "allows you to register a custom filter which accepts several arguments"
            )
        }()

        _ = try {
            let template = Template(templateString: #"{{ value | join : ", " }}"#)
            let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
            XCTAssertEqual(
                result,
                "One, Two",
                "allows whitespace in expression"
            )
        }()
    }

    func testStringFilters() throws {
        _ = try {
            let template = Template(templateString: "{{ name|capitalize }}")
            let result = try template.render(Context(dictionary: ["name": "kyle"]))
            XCTAssertEqual(
                result,
                "Kyle",
                "transforms a string to be capitalized"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ name|uppercase }}")
            let result = try template.render(Context(dictionary: ["name": "kyle"]))
            XCTAssertEqual(
                result, "KYLE",
                "transforms a string to be uppercase"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ name|lowercase }}")
            let result = try template.render(Context(dictionary: ["name": "Kyle"]))
            XCTAssertEqual(
                result, "kyle",
                "transforms a string to be lowercase"
            )
        }()
    }

    func testStringFiltersWithArrays() throws {
        _ = try {
            let template = Template(templateString: "{{ names|capitalize }}")
            let result = try template.render(Context(dictionary: ["names": ["kyle", "kyle"]]))
            XCTAssertEqual(
                result,
                #"["Kyle", "Kyle"]"#,
                "transforms a string to be capitalized"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ names|uppercase }}")
            let result = try template.render(Context(dictionary: ["names": ["kyle", "kyle"]]))
            XCTAssertEqual(
                result,
                #"["KYLE", "KYLE"]"#,
                "transforms a string to be uppercase"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ names|lowercase }}")
            let result = try template.render(Context(dictionary: ["names": ["Kyle", "Kyle"]]))
            XCTAssertEqual(
                result,
                #"["kyle", "kyle"]"#,
                "transforms a string to be lowercase"
            )
        }()
    }

    func testDefaultFilter() throws {
        let template = Template(templateString: #"Hello {{ name|default:"World" }}"#)

        _ = try {
            let result = try template.render(Context(dictionary: ["name": "Kyle"]))
            XCTAssertEqual(
                result,
                "Hello Kyle",
                "shows the variable value"
            )
        }()

        _ = try {
            let result = try template.render(Context(dictionary: [:]))
            XCTAssertEqual(
                result,
                "Hello World",
                "shows the default value"
            )
        }()

        _ = try {
            let template = Template(templateString: #"Hello {{ name|default:a,b,c,"World" }}"#)
            let result = try template.render(Context(dictionary: [:]))
            XCTAssertEqual(
                result,
                "Hello World",
                "supports multiple defaults"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ value|default:1 }}")
            let result = try template.render(Context(dictionary: [:]))
            XCTAssertEqual(
                result,
                "1",
                "can use int as default"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ value|default:1.5 }}")
            let result = try template.render(Context(dictionary: [:]))
            XCTAssertEqual(
                result,
                "1.5",
                "can use float as default"
            )
        }()

        _ = try {
            let template = Template(templateString: #"Hello {{ user.name|default:"anonymous" }}"#)
            let nilName: String? = nil
            let user: [String: Any?] = ["name": nilName]
            let result = try template.render(Context(dictionary: ["user": user]))
            XCTAssertEqual(
                result,
                "Hello anonymous",
                "checks for underlying nil value correctly"
            )
        }()
    }

    func testJoinFilter() throws {
        let template = Template(templateString: #"{{ value|join:", " }}"#)

        _ = try {
            let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
            XCTAssertEqual(
                result,
                "One, Two",
                "joins a collection of strings"
            )
        }()

        _ = try {
            let result = try template.render(Context(dictionary: ["value": ["One", 2, true, 10.5, "Five"]]))
            XCTAssertEqual(
                result,
                "One, 2, true, 10.5, Five",
                "joins a mixed-type collection"
            )
        }()

        _ = try {
            let template = Template(templateString: #"{{ value|join:separator }}"#)
            let result = try template.render(Context(dictionary: ["value": ["One", "Two"], "separator": true]))
            XCTAssertEqual(
                result,
                "OnetrueTwo",
                "can join by non string"
            )
        }()

        _ = try {
            let template = Template(templateString: #"{{ value|join }}"#)
            let result = try template.render(Context(dictionary: ["value": ["One", "Two"]]))
            XCTAssertEqual(
                result,
                "OneTwo",
                "can join without arguments"
            )
        }()
    }

    func testSplitFilter() throws {
        let template = Template(templateString: #"{{ value|split:", " }}"#)

        _ = try {
            let result = try template.render(Context(dictionary: ["value": "One, Two"]))
            XCTAssertEqual(
                result,
                #"["One", "Two"]"#,
                "split a string into array"
            )
        }()

        _ = try {
            let template = Template(templateString: #"{{ value|split }}"#)
            let result = try template.render(Context(dictionary: ["value": "One, Two"]))
            XCTAssertEqual(
                result,
                #"["One,", "Two"]"#,
                "can split without arguments"
            )
        }()
    }

    func testFilterSuggestion() throws {
        _ = try {
            let template = Template(templateString: "{{ value|unknownFilter }}")
            let filterExtension = Extension()
            filterExtension.registerFilter("knownFilter") { value, _ in value }
            let environment = Environment(extensions: [filterExtension])
            let expectedError = try expectedError(
                reason: "Unknown filter 'unknownFilter'. Found similar filters: 'knownFilter'.",
                template: template,
                token: "value|unknownFilter"
            )
            try XCTAssertThrowsError(
                environment.render(template: template, context: [:]),
                "made for unknown filter"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
            }
        }()

        _ = try {
            let template = Template(templateString: "{{ value|lowerFirst }}")
            let filterExtension = Extension()
            filterExtension.registerFilter("lowerFirstWord") { value, _ in value }
            filterExtension.registerFilter("lowerFirstLetter") { value, _ in value }
            let environment = Environment(extensions: [filterExtension])
            let expectedError = try expectedError(
                reason: "Unknown filter 'lowerFirst'. Found similar filters: 'lowerFirstWord', 'lowercase'.",
                template: template,
                token: "value|lowerFirst"
            )
            try XCTAssertThrowsError(
                environment.render(template: template, context: [:]),
                "made for multiple similar filters"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
            }
        }()

        _ = try {
            let template = Template(templateString: "{{ value|unknownFilter }}")
            let filterExtension = Extension()
            filterExtension.registerFilter("lowerFirstWord") { value, _ in value }
            let environment = Environment(extensions: [filterExtension])
            let expectedError = try expectedError(
                reason: "Unknown filter 'unknownFilter'. Found similar filters: 'lowerFirstWord'.",
                template: template,
                token: "value|unknownFilter"
            )
            try XCTAssertThrowsError(
                environment.render(template: template, context: [:]),
                "not made when can't find similar filter"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
            }
        }()
    }

    func testIndentContent() throws {
        let template = Template(templateString: #"{{ value|indent:2 }}"#)
        let result = try template.render(Context(dictionary: [
            "value": """
            One
            Two
            """,
        ]))
        let expectedResult = """
        One
          Two
        """
        XCTAssertEqual(
            result,
            expectedResult
        )
    }

    func testIndentWithArbitraryCharacter() throws {
        let template = Template(templateString: """
        {{ value|indent:2,"\t" }}
        """)
        let result = try template.render(Context(dictionary: [
            "value": """
            One
            Two
            """,
        ]))
        let expectedResult = """
        One
        \t\tTwo
        """
        XCTAssertEqual(
            result,
            expectedResult
        )
    }

    func testIndentFirstLine() throws {
        let template = Template(templateString: #"{{ value|indent:2," ",true }}"#)
        let result = try template.render(Context(dictionary: [
            "value": """
            One
            Two
            """,
        ]))
        // swiftlint:enable indentation_width
        let expectedResult = """
          One
          Two
        """
        // swiftlint:disable indentation_width
        XCTAssertEqual(
            result,
            expectedResult
        )
    }

    func testIndentNotEmptyLines() throws {
        let template = Template(templateString: #"{{ value|indent }}"#)
        let result = try template.render(Context(dictionary: [
            "value": """
            One


            Two


            """,
        ]))
        let expectedResult = """
        One


            Two


        """
        XCTAssertEqual(
            result,
            expectedResult
        )
    }

    func testDynamicFilters() throws {
        _ = try {
            let template = Template(templateString: "{{ name|filter:somefilter }}")
            let result = try template.render(Context(dictionary: ["name": "Jhon", "somefilter": "uppercase"]))
            XCTAssertEqual(
                result,
                "JHON",
                "can apply dynamic filter"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ values|filter:joinfilter }}")
            let result = try template.render(Context(dictionary: ["values": [1, 2, 3], "joinfilter": "join:\", \""]))
            XCTAssertEqual(
                result,
                "1, 2, 3",
                "can apply dynamic filter on array"
            )
        }()

        _ = try {
            let template = Template(templateString: "{{ values|filter:unknown }}")
            let context = Context(dictionary: ["values": [1, 2, 3], "unknown": "absurd"])
            try XCTAssertThrowsError(
                template.render(context),
                "throws on unknown dynamic filter"
            ) { error in
                let error = error as? TemplateSyntaxError
                XCTAssertEqual(
                    error,
                    TemplateSyntaxError(
                        reason: "Unknown filter 'absurd'. Found similar filters: 'default'.",
                        token: template.tokens.first
                    )
                )
            }
        }()
    }

    private func expectedError(
        reason: String,
        template: Template,
        token: String
    ) throws -> TemplateSyntaxError {
        let range = try XCTUnwrap(template.templateString.range(of: token))

        let lexer = Lexer(templateString: template.templateString)
        let location = lexer.rangeLocation(range)
        let sourceMap = SourceMap(filename: template.name, location: location)
        let token = Token.block(value: token, at: sourceMap)
        return TemplateSyntaxError(reason: reason, token: token, stackTrace: [])
    }
}
