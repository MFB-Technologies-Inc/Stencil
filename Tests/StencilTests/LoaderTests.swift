// LoaderTests.swift
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
import Stencil
import XCTest

final class TemplateLoaderTests: StencilTestCase {
    override class func setUp() {
        super.setUp()
        try! setupFixtures()
    }

    func testFileSystemLoader() throws {
        let path = Path(Self.fixtures)
        let loader = FileSystemLoader(paths: [path])
        let environment = Environment(loader: loader)

        _ = try XCTAssertThrowsError(
            environment.loadTemplate(name: "unknown.html"),
            "errors when a template cannot be found"
        )

        _ = try XCTAssertThrowsError(
            environment.loadTemplate(names: ["unknown.html", "unknown2.html"]),
            "errors when an array of templates cannot be found"
        )

        _ = try XCTAssertNoThrow(
            environment.loadTemplate(name: "test.html"),
            "can load a template from a file"
        )

        _ = try XCTAssertThrowsError(
            environment.loadTemplate(name: "/etc/hosts"),
            "errors when loading absolute file outside of the selected path"
        )

        _ = try XCTAssertThrowsError(
            environment.loadTemplate(name: "../LoaderSpec.swift"),
            "errors when loading relative file outside of the selected path"
        )
    }

    func testDictionaryLoader() throws {
        let loader = DictionaryLoader(templates: [
            "index.html": "Hello World",
        ])
        let environment = Environment(loader: loader)

        _ = try XCTAssertThrowsError(
            environment.loadTemplate(name: "unknown.html"),
            "errors when a template cannot be found"
        )

        _ = try XCTAssertThrowsError(
            environment.loadTemplate(names: ["unknown.html", "unknown2.html"]),
            "errors when an array of templates cannot be found"
        )

        _ = try XCTAssertNoThrow(
            environment.loadTemplate(name: "index.html"),
            "can load a template from a known templates"
        )

        _ = try XCTAssertNoThrow(
            environment.loadTemplate(names: ["unknown.html", "index.html"]),
            "can load a known template from a collection of templates"
        )
    }
}
