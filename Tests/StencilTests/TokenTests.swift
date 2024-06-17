// TokenTests.swift
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

final class TokenTests: XCTestCase {
    func testToken() throws {
        _ = {
            let token = Token.text(value: "hello world", at: .unknown)
            let components = token.components()

            XCTAssertEqual(
                components.count,
                2,
                "can split the contents into components"
            )
            XCTAssertEqual(
                components[0],
                "hello",
                "can split the contents into components"
            )
            XCTAssertEqual(
                components[1],
                "world",
                "can split the contents into components"
            )
        }()

        _ = {
            let token = Token.text(value: "hello 'kyle fuller'", at: .unknown)
            let components = token.components()

            XCTAssertEqual(
                components.count,
                2,
                "can split the contents into components with single quoted strings"
            )
            XCTAssertEqual(
                components[0],
                "hello",
                "can split the contents into components with single quoted strings"
            )
            XCTAssertEqual(
                components[1],
                "'kyle fuller'",
                "can split the contents into components with single quoted strings"
            )
        }()

        _ = {
            let token = Token.text(value: "hello \"kyle fuller\"", at: .unknown)
            let components = token.components()

            XCTAssertEqual(
                components.count,
                2,
                "can split the contents into components with double quoted strings"
            )
            XCTAssertEqual(
                components[0],
                "hello",
                "can split the contents into components with double quoted strings"
            )
            XCTAssertEqual(
                components[1],
                "\"kyle fuller\"",
                "can split the contents into components with double quoted strings"
            )
        }()
    }
}
