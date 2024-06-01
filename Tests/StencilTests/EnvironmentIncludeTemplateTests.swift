// EnvironmentIncludeTemplateTests.swift
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

final class EnvironmentIncludeTemplateTests: StencilTestCase {
    override class func setUp() {
        super.setUp()
        try! setupFixtures()
    }

    func testSyntaxError() throws {
        let loader = FileSystemLoader(paths: [Path(Self.fixtures)])
        let environment = Environment(loader: loader)
        let template = Template(templateString: #"{% include "invalid-include.html" %}"#, environment: environment)
        let includedTemplate = try environment.loadTemplate(name: "invalid-include.html")

        let expectedError = try expectedError(
            reason: "Unknown filter 'unknown'. Found similar filters: 'uppercase'.",
            template: template,
            token: #"include "invalid-include.html""#,
            includedTemplate: includedTemplate,
            includedToken: "target|unknown"
        )
        try XCTAssertThrowsError(environment.render(template: template, context: ["target": "World"])) { error in
            let reporter = SimpleErrorReporter()
            XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
        }
    }

    func testRuntimeError() throws {
        let loader = FileSystemLoader(paths: [Path(Self.fixtures)])
        var environment = Environment(loader: loader)
        let filterExtension = Extension()
        filterExtension.registerFilter("unknown") { (_: Any?) in
            throw TemplateSyntaxError("filter error")
        }
        environment.extensions += [filterExtension]

        let template = Template(templateString: #"{% include "invalid-include.html" %}"#, environment: environment)
        let includedTemplate = try environment.loadTemplate(name: "invalid-include.html")

        let expectedError = try expectedError(
            reason: "filter error",
            template: template,
            token: "include \"invalid-include.html\"",
            includedTemplate: includedTemplate,
            includedToken: "target|unknown"
        )
        try XCTAssertThrowsError(environment.render(template: template, context: ["target": "World"])) { error in
            let reporter = SimpleErrorReporter()
            XCTAssertEqual(reporter.renderError(error), reporter.renderError(expectedError))
        }
    }

    private func expectedError(
        reason: String,
        template: Template,
        token: String,
        includedTemplate: Template,
        includedToken: String
    ) throws -> TemplateSyntaxError {
        var expectedError = try XCTUnwrap(expectedSyntaxError(
            token: token,
            template: template,
            description: reason
        ))
        let expectedIncludedError = try XCTUnwrap(expectedSyntaxError(
            token: includedToken,
            template: includedTemplate,
            description: reason
        ))
        expectedError.stackTrace = [
            expectedIncludedError.token,
        ].compactMap { $0 }
        return expectedError
    }
}
