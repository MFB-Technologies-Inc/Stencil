// InheritanceTests.swift
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

final class InheritanceTests: StencilTestCase {
    private lazy var path = Path(Self.fixtures)
    private lazy var loader = FileSystemLoader(paths: [path])
    private lazy var environment = Environment(loader: loader)

    override class func setUp() {
        super.setUp()
        try! setupFixtures()
    }

    func testInheritance() throws {
        _ = try {
            let template = try self.environment.loadTemplate(name: "child.html")
            let expectedValue = """
            Super_Header Child_Header
            Child_Body
            """
            XCTAssertEqual(
                try template.render(),
                expectedValue,
                "can inherit from another template"
            )
        }()

        _ = try {
            let template = try self.environment.loadTemplate(name: "child-child.html")
            let expectedValue = """
            Super_Header Child_Header Child_Child_Header
            Child_Body
            """
            XCTAssertEqual(
                try template.render(),
                expectedValue,
                "can inherit from another template inheriting from another template"
            )
        }()

        _ = try {
            let template = try self.environment.loadTemplate(name: "child-super.html")
            let expectedValue = """
            Header
            Child_Body
            """
            XCTAssertEqual(
                try template.render(),
                expectedValue,
                "can inherit from a template that calls a super block"
            )
        }()

        _ = try {
            let template = try self.environment.loadTemplate(name: "if-block-child.html")

            try XCTAssertEqual(
                template.render(["sort": "new"]),
                "Title - Nieuwste spellen",
                "can render block.super in if tag"
            )

            try XCTAssertEqual(
                template.render(["sort": "upcoming"]),
                "Title - Binnenkort op de agenda",
                "can render block.super in if tag"
            )

            try XCTAssertEqual(
                template.render(["sort": "near-me"]),
                "Title - In mijn buurt",
                "can render block.super in if tag"
            )
        }()
    }

    func testInheritanceCache() throws {
        _ = try {
            let template: Template = "{% block repeat %}Block{% endblock %}{{ block.repeat }}"
            XCTAssertEqual(
                try template.render(),
                "BlockBlock",
                "can call block twice"
            )
        }()

        _ = try {
            let template = try self.environment.loadTemplate(name: "child-repeat.html")
            let expectedValue = """
            Super_Header Child_Header
            Child_Body
            Repeat
            Super_Header Child_Header
            Child_Body
            """
            XCTAssertEqual(
                try template.render(),
                expectedValue,
                "renders child content when calling block twice in base template"
            )
        }()
    }
}
