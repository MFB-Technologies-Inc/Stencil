// NowNodeTests.swift
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

final class NowNodeTests: XCTestCase {
    func testParsing() throws {
        _ = try {
            #if !os(Linux)
                let tokens: [Token] = [.block(value: "now", at: .unknown)]
                let parser = TokenParser(tokens: tokens, environment: Environment())

                let nodes = try parser.parse()
                let node = nodes.first as? NowNode
                XCTAssertEqual(
                    nodes.count,
                    1,
                    "parses default format without any now arguments"
                )
                XCTAssertEqual(
                    node?.format.variable,
                    "\"yyyy-MM-dd 'at' HH:mm\"",
                    "parses default format without any now arguments"
                )
            #endif
        }()

        _ = try {
            #if !os(Linux)
                let tokens: [Token] = [.block(value: "now \"HH:mm\"", at: .unknown)]
                let parser = TokenParser(tokens: tokens, environment: Environment())
                let nodes = try parser.parse()
                let node = nodes.first as? NowNode
                XCTAssertEqual(
                    nodes.count,
                    1,
                    "parses now with a format"
                )
                XCTAssertEqual(
                    node?.format.variable,
                    "\"HH:mm\"",
                    "parses now with a format"
                )
            #endif
        }()
    }

    func testRendering() throws {
        _ = try {
            #if !os(Linux)
                let node = NowNode(format: Variable("\"yyyy-MM-dd\""))

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let date = formatter.string(from: Date())

                XCTAssertEqual(
                    try node.render(Context()),
                    date,
                    "renders the date"
                )
            #endif
        }()
    }
}
