// StencilTestCase.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

import Foundation
@testable import Stencil
import XCTest

class StencilTestCase: XCTestCase {
    static let (fixtures, fixturesResolved) = {
        let fixtures: String
        let fixturesResolved: String
        if let tempDirFromEnv = ProcessInfo.processInfo.environment["TEMP_DIR"] {
            fixtures = "\(tempDirFromEnv)/StencilTests"
            fixturesResolved = "\(tempDirFromEnv)/StencilTests"
        } else {
            fixtures = "/tmp/StencilTests"
            #if os(Linux)
                fixturesResolved = "/tmp/StencilTests"
            #else
                fixturesResolved = "/private/tmp/StencilTests"
            #endif
        }
        return (fixtures, fixturesResolved)
    }()

    override class func tearDown() {
        if FileManager.default.fileExists(atPath: fixtures) {
            try! FileManager.default.removeItem(atPath: fixtures)
        }
        super.tearDown()
    }

    static func setupFixtures() throws {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: fixtures) {
            try fileManager.removeItem(atPath: fixtures)
        }

        let targetDir = fixtures

        try fileManager.createDirectory(atPath: targetDir, withIntermediateDirectories: true)

        fileManager.createFile(atPath: "\(targetDir)/base.html", contents: Fixtures.base.data(using: .utf8))
        fileManager.createFile(
            atPath: "\(targetDir)/base-repeat.html",
            contents: Fixtures.baseRepeat.data(using: .utf8)
        )
        fileManager.createFile(atPath: "\(targetDir)/child.html", contents: Fixtures.child.data(using: .utf8))
        fileManager.createFile(
            atPath: "\(targetDir)/child-child.html",
            contents: Fixtures.childChild.data(using: .utf8)
        )
        fileManager.createFile(
            atPath: "\(targetDir)/child-repeat.html",
            contents: Fixtures.childRepeat.data(using: .utf8)
        )
        fileManager.createFile(
            atPath: "\(targetDir)/child-super.html",
            contents: Fixtures.childSuper.data(using: .utf8)
        )
        fileManager.createFile(atPath: "\(targetDir)/huge.html", contents: Fixtures.huge.data(using: .utf8))
        fileManager.createFile(atPath: "\(targetDir)/if-block.html", contents: Fixtures.ifBlock.data(using: .utf8))
        fileManager.createFile(
            atPath: "\(targetDir)/if-block-child.html",
            contents: Fixtures.ifBlockChild.data(using: .utf8)
        )
        fileManager.createFile(
            atPath: "\(targetDir)/invalid-base.html",
            contents: Fixtures.invalidBase.data(using: .utf8)
        )
        fileManager.createFile(
            atPath: "\(targetDir)/invalid-child-super.html",
            contents: Fixtures.invalidChildSuper.data(using: .utf8)
        )
        fileManager.createFile(
            atPath: "\(targetDir)/invalid-include.html",
            contents: Fixtures.invalidInclude.data(using: .utf8)
        )
        fileManager.createFile(atPath: "\(targetDir)/test.html", contents: Fixtures.test.data(using: .utf8))
    }

    func expectedSyntaxError(token: String, template: Template, description: String) -> TemplateSyntaxError? {
        guard let range = template.templateString.range(of: token) else {
            XCTFail("Can't find '\(token)' in '\(template)'")
            return nil
        }
        let lexer = Lexer(templateString: template.templateString)
        let location = lexer.rangeLocation(range)
        let sourceMap = SourceMap(filename: template.name, location: location)
        let token = Token.block(value: token, at: sourceMap)
        return TemplateSyntaxError(reason: description, token: token, stackTrace: [])
    }
}
