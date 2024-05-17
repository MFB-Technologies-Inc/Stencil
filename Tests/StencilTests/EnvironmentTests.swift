// EnvironmentTests.swift
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

final class EnvironmentTests: StencilTestCase {
    override func setUp() {
        super.setUp()

        let errorExtension = Extension()
        errorExtension.registerFilter("throw") { (_: Any?) in
            throw TemplateSyntaxError("filter error")
        }
        errorExtension.registerSimpleTag("simpletag") { _ in
            throw TemplateSyntaxError("simpletag error")
        }
        errorExtension.registerTag("customtag") { _, token in
            ErrorNode(token: token)
        }
    }

    private func errorExtension() throws -> Extension {
        let errorExtension = Extension()
        errorExtension.registerFilter("throw") { (_: Any?) in
            throw TemplateSyntaxError("filter error")
        }
        errorExtension.registerSimpleTag("simpletag") { _ in
            throw TemplateSyntaxError("simpletag error")
        }
        errorExtension.registerTag("customtag") { _, token in
            ErrorNode(token: token)
        }
        return errorExtension
    }

    private func newEnvironment() throws -> Environment {
        var environment = Environment(loader: ExampleLoader())
        try environment.extensions += [errorExtension()]
        return environment
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoading() throws {
        _ = try {
            let environment = try newEnvironment()
            let template = try environment.loadTemplate(name: "example.html")
            XCTAssertEqual(
                template.name,
                "example.html",
                "can load a template from a name"
            )
        }()

        _ = try {
            let environment = try newEnvironment()
            let template = try environment.loadTemplate(names: ["first.html", "example.html"])
            XCTAssertEqual(
                template.name,
                "example.html",
                "can load a template from a names"
            )
        }()
    }

    func testRendering() throws {
        _ = try {
            let environment = try newEnvironment()
            let result = try environment.renderTemplate(string: "Hello World")
            XCTAssertEqual(
                result,
                "Hello World",
                "can render a template from a string"
            )
        }()

        _ = try {
            let environment = try newEnvironment()
            let result = try environment.renderTemplate(name: "example.html")
            XCTAssertEqual(
                result,
                "Hello World!",
                "can render a template from a file"
            )
        }()

        _ = try {
            let environment = Environment(loader: ExampleLoader(), templateClass: CustomTemplate.self)
            let result = try environment.renderTemplate(string: "Hello World")
            XCTAssertEqual(
                result,
                "here",
                "allows you to provide a custom template class"
            )
        }()
    }

    func testSyntaxError() throws {
        _ = try {
            let template: Template = "Hello {% for name in %}{{ name }}, {% endfor %}!"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "for name in",
                template: template,
                description: "'for' statements should use the syntax: `for <x> in <y> [where <condition>]`."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error on invalid for tag syntax"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error on invalid for tag syntax"
                )
            }
        }()

        _ = try {
            let template: Template = "{% for name in names %}{{ name }}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "for name in names",
                template: template,
                description: "`endfor` was not found."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error on missing endfor"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error on missing endfor"
                )
            }
        }()

        _ = try {
            let template: Template = "{% for name in names %}{{ name }}{% end %}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "end",
                template: template,
                description: "Unknown template tag 'end'"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error on unknown tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error on unknown tag"
                )
            }
        }()
    }

    func testUnknownFilter() throws {
        _ = try {
            let template: Template = "{% for name in names|unknown %}{{ name }}{% endfor %}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "names|unknown",
                template: template,
                description: "Unknown filter 'unknown'. Found similar filters: 'uppercase'."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error in for tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error in for tag"
                )
            }
        }()

        _ = try {
            let template: Template = "{% for name in names where name|unknown %}{{ name }}{% endfor %}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "name|unknown",
                template: template,
                description: "Unknown filter 'unknown'. Found similar filters: 'uppercase'."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error in for-where tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error in for-where tag"
                )
            }
        }()

        _ = try {
            let template: Template = "{% if name|unknown %}{{ name }}{% endif %}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "name|unknown",
                template: template,
                description: "Unknown filter 'unknown'. Found similar filters: 'uppercase'."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error in if tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error in if tag"
                )
            }
        }()

        _ = try {
            let template: Template = "{% if name %}{{ name }}{% elif name|unknown %}{% endif %}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "name|unknown",
                template: template,
                description: "Unknown filter 'unknown'. Found similar filters: 'uppercase'."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error in elif tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error in elif tag"
                )
            }
        }()

        _ = try {
            let template: Template = "{% ifnot name|unknown %}{{ name }}{% endif %}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "name|unknown",
                template: template,
                description: "Unknown filter 'unknown'. Found similar filters: 'uppercase'."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error in ifnot tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error in ifnot tag"
                )
            }
        }()

        _ = try {
            let template: Template = "{% filter unknown %}Text{% endfilter %}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "filter unknown",
                template: template,
                description: "Unknown filter 'unknown'. Found similar filters: 'uppercase'."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error in filter tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error in filter tag"
                )
            }
        }()

        _ = try {
            let template: Template = "{{ name|unknown }}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "name|unknown",
                template: template,
                description: "Unknown filter 'unknown'. Found similar filters: 'uppercase'."
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports syntax error in variable tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports syntax error in variable tag"
                )
            }
        }()

        _ = try {
            let template: Template = "{{ }}"
            let environment = try newEnvironment()
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: " ",
                template: template,
                description: "Missing variable name"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports error in variable tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports error in variable tag"
                )
            }
        }()
    }

    func testRenderingError() throws {
        _ = try {
            let environment = try newEnvironment()

            let template = Template(templateString: "{{ name|throw }}", environment: environment)
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "name|throw",
                template: template,
                description: "filter error"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports rendering error in variable filter"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports rendering error in variable filter"
                )
            }
        }()

        _ = try {
            let environment = try newEnvironment()

            let template = Template(templateString: "{% filter throw %}Test{% endfilter %}", environment: environment)
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "filter throw",
                template: template,
                description: "filter error"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports rendering error in filter tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports rendering error in filter tag"
                )
            }
        }()

        _ = try {
            let environment = try newEnvironment()

            let template = Template(templateString: "{% simpletag %}", environment: environment)
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "simpletag",
                template: template,
                description: "simpletag error"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports rendering error in simple tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports rendering error in simple tag"
                )
            }
        }()

        _ = try {
            let environment = try newEnvironment()

            let template = Template(templateString: "{{ name|uppercase:5 }}", environment: environment)
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "name|uppercase:5",
                template: template,
                description: "Can't invoke filter with an argument"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports passing argument to simple filter"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports passing argument to simple filter"
                )
            }
        }()

        _ = try {
            let environment = try newEnvironment()

            let template = Template(templateString: "{% customtag %}", environment: environment)
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "customtag",
                template: template,
                description: "Custom Error"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports rendering error in custom tag"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports rendering error in custom tag"
                )
            }
        }()

        _ = try {
            let environment = try newEnvironment()

            let template = Template(
                templateString: #"{% for name in names %}{% customtag %}{% endfor %}"#,
                environment: environment
            )
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "customtag",
                template: template,
                description: "Custom Error"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports rendering error in for body"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports rendering error in for body"
                )
            }
        }()

        _ = try {
            let environment = try newEnvironment()

            let template = Template(
                templateString: "{% block some %}{% customtag %}{% endblock %}",
                environment: environment
            )
            let expectedError = try XCTUnwrap(expectedSyntaxError(
                token: "customtag",
                template: template,
                description: "Custom Error"
            ))
            try XCTAssertThrowsError(
                environment.render(
                    template: template,
                    context: ["names": ["Bob", "Alice"], "name": "Bob"]
                ),
                "reports rendering error in block"
            ) { error in
                let reporter = SimpleErrorReporter()
                XCTAssertEqual(
                    reporter.renderError(error),
                    reporter.renderError(expectedError),
                    "reports rendering error in block"
                )
            }
        }()
    }
}

// MARK: - Helpers

private class CustomTemplate: Template {
    // swiftlint:disable discouraged_optional_collection
    override func render(_: [String: Any]? = nil) throws -> String {
        "here"
    }
}
