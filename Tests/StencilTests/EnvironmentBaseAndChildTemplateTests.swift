// EnvironmentBaseAndChildTemplateTests.swift
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

final class EnvironmentBaseAndChildTemplateTests: StencilTestCase {
    override class func setUp() {
        super.setUp()
        try! setupFixtures()
    }

    func testSyntaxErrorInBaseTemplate() throws {
        let loader = FileSystemLoader(paths: [Path(Self.fixtures)])
        let environment = Environment(loader: loader)
        let childTemplate = try environment.loadTemplate(name: "invalid-child-super.html")
        let baseTemplate = try environment.loadTemplate(name: "invalid-base.html")

        let expectedError = try expectedError(
            reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
            childTemplate: childTemplate,
            childToken: "extends \"invalid-base.html\"",
            baseTemplate: baseTemplate,
            baseToken: "target|unknown"
        )
        try XCTAssertThrowsError(environment.render(template: childTemplate, context: ["target": "World"])) { error in
            let reporter = SimpleErrorReporter()
            XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
        }
    }

    func testRuntimeErrorInBaseTemplate() throws {
        let loader = FileSystemLoader(paths: [Path(Self.fixtures)])
        var environment = Environment(loader: loader)
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown") { (_: Any?) in
            throw TemplateSyntaxError("filter error")
        }
        environment.extensions += [filterExtension]

        let childTemplate = try environment.loadTemplate(name: "invalid-child-super.html")
        let baseTemplate = try environment.loadTemplate(name: "invalid-base.html")

        let expectedError = try expectedError(
            reason: "filter error",
            childTemplate: childTemplate,
            childToken: "extends \"invalid-base.html\"",
            baseTemplate: baseTemplate,
            baseToken: "target|unknown"
        )
        try XCTAssertThrowsError(environment.render(template: childTemplate, context: ["target": "World"])) { error in
            let reporter = SimpleErrorReporter()
            XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
        }
    }

    func testSyntaxErrorInChildTemplate() throws {
        let loader = FileSystemLoader(paths: [Path(Self.fixtures)])
        let environment = Environment(loader: loader)
        let childTemplate = Template(
            templateString: """
            {% extends "base.html" %}
            {% block body %}Child {{ target|unknown }}{% endblock %}
            """,
            environment: environment,
            name: nil
        )

        let expectedError = try expectedError(
            reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
            childTemplate: childTemplate,
            childToken: "target|unknown"
        )
        try XCTAssertThrowsError(environment.render(template: childTemplate, context: ["target": "World"])) { error in
            let reporter = SimpleErrorReporter()
            XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
        }
    }

    func testRuntimeErrorInChildTemplate() throws {
        let loader = FileSystemLoader(paths: [Path(Self.fixtures)])
        var environment = Environment(loader: loader)
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown") { (_: Any?) in
            throw TemplateSyntaxError("filter error")
        }
        environment.extensions += [filterExtension]

        let childTemplate = Template(
            templateString: """
            {% extends "base.html" %}
            {% block body %}Child {{ target|unknown }}{% endblock %}
            """,
            environment: environment,
            name: nil
        )

        let expectedError = try expectedError(
            reason: "filter error",
            childTemplate: childTemplate,
            childToken: "target|unknown"
        )
        try XCTAssertThrowsError(environment.render(template: childTemplate, context: ["target": "World"])) { error in
            let reporter = SimpleErrorReporter()
            XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
        }
    }

    private func expectedError(
        reason: String,
        childTemplate: Template,
        childToken: String,
        baseTemplate: Template? = nil,
        baseToken: String? = nil
    ) throws -> TemplateSyntaxError {
        var expectedChildError = try XCTUnwrap(expectedSyntaxError(
            token: childToken,
            template: childTemplate,
            description: reason
        ))
        if let baseTemplate, let baseToken {
            let expectedBaseError = try XCTUnwrap(expectedSyntaxError(
                token: baseToken,
                template: baseTemplate,
                description: reason
            ))
            expectedChildError.stackTrace = [
                expectedBaseError.token,
            ].compactMap { $0 }
        }
        return expectedChildError
    }
}
