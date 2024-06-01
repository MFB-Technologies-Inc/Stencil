// FilterTagTests.swift
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

final class FilterTagTests: XCTestCase {
    func testFilterTag() throws {
        _ = try {
            let template = Template(templateString: "{% filter uppercase %}Test{% endfilter %}")
            let result = try template.render()
            XCTAssertEqual(
                result,
                "TEST",
                "allows you to use a filter"
            )
        }()

        _ = try {
            let template = Template(templateString: "{% filter lowercase|capitalize %}TEST{% endfilter %}")
            let result = try template.render()
            XCTAssertEqual(
                result,
                "Test",
                "allows you to chain filters"
            )
        }()

        _ = try {
            let template = Template(templateString: "Some {% filter %}Test{% endfilter %}")
            try XCTAssertThrowsError(
                template.render(),
                "errors without a filter",
                { error in
                    XCTAssertEqual(
                        (error as? TemplateSyntaxError)?.description,
                        "'filter' tag takes one argument, the filter expression"
                    )
                }
            )
        }()

        _ = try {
            let ext = Extension()
            ext.registerFilter("split") { value, args in
                guard let value = value as? String,
                      let argument = args.first as? String else { return value }
                return value.components(separatedBy: argument)
            }
            let env = Environment(extensions: [ext])
            let result = try env.renderTemplate(
                string: #"{% filter split:","|join:";"  %}{{ items|join:"," }}{% endfilter %}"#,
                context: ["items": [1, 2]]
            )
            XCTAssertEqual(
                result,
                "1;2",
                "can render filters with arguments"
            )
        }()

        _ = try {
            let ext = Extension()
            ext.registerFilter("replace") { value, args in
                guard let value = value as? String,
                      args.count == 2,
                      let search = args.first as? String,
                      let replacement = args.last as? String else { return value }
                return value.replacingOccurrences(of: search, with: replacement)
            }
            let env = Environment(extensions: [ext])
            let result = try env.renderTemplate(
                string: #"{% filter replace:'"',"" %}{{ items|join:"," }}{% endfilter %}"#,
                context: ["items": ["\"1\"", "\"2\""]]
            )
            XCTAssertEqual(
                result,
                "1,2",
                "can render filters with quote as an argument"
            )
        }()
    }
}
