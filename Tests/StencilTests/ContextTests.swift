// ContextTests.swift
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

final class ContextTests: StencilTestCase {
    private func newContext(dictionary: [String: Any] = ["name": "Kyle"]) -> Context {
        Context(dictionary: dictionary)
    }

    func testContextSubscripting() throws {
        _ = {
            let context = newContext()
            XCTAssertEqual(
                context["name"] as? String,
                "Kyle",
                "allows you to get a value via subscripting"
            )
        }()

        _ = {
            let context = newContext()
            context["name"] = "Katie"
            XCTAssertEqual(
                context["name"] as? String,
                "Katie",
                "allows you to set a value via subscripting"
            )
        }()

        _ = {
            let context = newContext()
            context["name"] = nil
            XCTAssertNil(
                context["name"] as? String,
                "allows you to remove a value via subscripting"
            )
        }()

        _ = {
            let context = newContext()
            context.push {
                XCTAssertEqual(
                    context["name"] as? String,
                    "Kyle",
                    "allows you to retrieve a value from a parent"
                )
            }
        }()

        _ = {
            let context = newContext()
            context.push {
                context["name"] = "Katie"
                XCTAssertEqual(
                    context["name"] as? String,
                    "Katie",
                    "allows you to override a parent's value"
                )
            }
        }()
    }

    func testContextRestoration() throws {
        _ = {
            let context = newContext()
            context.push {
                context["name"] = "Katie"
            }
            XCTAssertEqual(
                context["name"] as? String,
                "Kyle",
                "allows you to pop to restore previous state"
            )
        }()

        _ = {
            let context = newContext()
            context.push {
                context["name"] = nil
                XCTAssertNil(context["name"] as? String)
            }
            XCTAssertEqual(
                context["name"] as? String,
                "Kyle",
                "allows you to remove a parent's value in a level"
            )
        }()

        _ = {
            let context = newContext()
            var didRun = false
            context.push(dictionary: ["name": "Katie"]) {
                didRun = true
                XCTAssertEqual(
                    context["name"] as? String,
                    "Katie",
                    "allows you to push a dictionary and run a closure then restoring previous state"
                )
            }
            XCTAssertTrue(
                didRun,
                "allows you to push a dictionary and run a closure then restoring previous state"
            )
            XCTAssertEqual(
                context["name"] as? String,
                "Kyle",
                "allows you to push a dictionary and run a closure then restoring previous state"
            )
        }()

        _ = {
            let context = newContext()
            context.push(dictionary: ["test": "abc"]) {
                let flattened = context.flatten()
                XCTAssertEqual(
                    flattened.count,
                    2,
                    "allows you to flatten the context contents"
                )
                XCTAssertEqual(
                    flattened["name"] as? String,
                    "Kyle",
                    "allows you to flatten the context contents"
                )
                XCTAssertEqual(
                    flattened["test"] as? String,
                    "abc",
                    "allows you to flatten the context contents"
                )
            }
            XCTAssertEqual(context["name"] as? String, "Kyle")
        }()
    }

    private func lazyEvaluationSetup() -> (context: Context, ticker: Ticker, wrapper: LazyValueWrapper) {
        let ticker = Ticker()
        let wrapper = LazyValueWrapper(ticker.tick())
        let context = newContext(dictionary: ["name": wrapper])
        return (context: context, ticker: ticker, wrapper: wrapper)
    }

    func testContextLazyEvaluation() throws {
        _ = try {
            let (context, ticker, _) = lazyEvaluationSetup()

            let template = Template(templateString: "{{ name }}")
            let result = try template.render(context)
            XCTAssertEqual(
                result,
                "Kyle",
                "Evaluates lazy data"
            )
            XCTAssertEqual(
                ticker.count,
                1,
                "Evaluates lazy data"
            )
        }()

        _ = try {
            let (context, ticker, _) = lazyEvaluationSetup()

            let template = Template(templateString: "{{ name }}{{ name }}")
            let result = try template.render(context)
            XCTAssertEqual(
                result,
                "KyleKyle",
                "Evaluates lazy only once"
            )
            XCTAssertEqual(
                ticker.count,
                1,
                "Evaluates lazy only once"
            )
        }()

        _ = try {
            let (context, ticker, _) = lazyEvaluationSetup()

            let template = Template(templateString: "{{ 'Katie' }}")
            let result = try template.render(context)
            XCTAssertEqual(
                result,
                "Katie",
                "Does not evaluate lazy data when not used"
            )
            XCTAssertEqual(
                ticker.count,
                0,
                "Does not evaluate lazy data when not used"
            )
        }()
    }

    func testSupportsEvaluationViaContextReference() throws {}

    func testSupportsEvaluationViaContextCopy() throws {}

    func testContextLazyAccessTypes() throws {
        _ = try {
            let context = newContext()
            context["alias"] = LazyValueWrapper { $0["name"] ?? "" }
            let template = Template(templateString: "{{ alias }}")

            try context.push(dictionary: ["name": "Katie"]) {
                let result = try template.render(context)
                XCTAssertEqual(
                    result,
                    "Katie",
                    "Supports evaluation via context reference"
                )
            }
        }()

        _ = try {
            let context = newContext()
            context["alias"] = LazyValueWrapper(copying: context) { $0["name"] ?? "" }
            let template = Template(templateString: "{{ alias }}")

            try context.push(dictionary: ["name": "Katie"]) {
                let result = try template.render(context)
                XCTAssertEqual(
                    result,
                    "Kyle",
                    "Supports evaluation via context copy"
                )
            }
        }()
    }
}

// MARK: - Helpers

private final class Ticker {
    var count: Int = 0
    func tick() -> String {
        count += 1
        return "Kyle"
    }
}
