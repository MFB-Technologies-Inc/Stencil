// LexerTests.swift
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

final class LexerTests: StencilTestCase {
    override class func setUp() {
        super.setUp()
        try! setupFixtures()
    }

    func testText() throws {
        let lexer = Lexer(templateString: "Hello World")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .text(value: "Hello World", at: makeSourceMap("Hello World", for: lexer)))
    }

    func testComment() throws {
        let lexer = Lexer(templateString: "{# Comment #}")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .comment(value: "Comment", at: makeSourceMap("Comment", for: lexer)))
    }

    func testVariable() throws {
        let lexer = Lexer(templateString: "{{ Variable }}")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .variable(value: "Variable", at: makeSourceMap("Variable", for: lexer)))
    }

    func testTokenWithoutSpaces() throws {
        let lexer = Lexer(templateString: "{{Variable}}")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .variable(value: "Variable", at: makeSourceMap("Variable", for: lexer)))
    }

    func testUnclosedTag() throws {
        let templateString = "{{ thing"
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first, .text(value: "", at: makeSourceMap("{{ thing", for: lexer)))
    }

    func testContentMixture() throws {
        let templateString = "My name is {{ myname }}."
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(tokens[0], .text(value: "My name is ", at: makeSourceMap("My name is ", for: lexer)))
        XCTAssertEqual(tokens[1], .variable(value: "myname", at: makeSourceMap("myname", for: lexer)))
        XCTAssertEqual(tokens[2], .text(value: ".", at: makeSourceMap(".", for: lexer)))
    }

    func testVariablesWithoutBeingGreedy() throws {
        let templateString = "{{ thing }}{{ name }}"
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0], .variable(value: "thing", at: makeSourceMap("thing", for: lexer)))
        XCTAssertEqual(tokens[1], .variable(value: "name", at: makeSourceMap("name", for: lexer)))
    }

    func testUnclosedBlock() throws {
        let lexer = Lexer(templateString: "{%}")
        _ = lexer.tokenize()
    }

    func testTokenizeIncorrectSyntaxWithoutCrashing() throws {
        let lexer = Lexer(templateString: "func some() {{% if %}")
        _ = lexer.tokenize()
    }

    func testEmptyVariable() throws {
        let lexer = Lexer(templateString: "{{}}")
        _ = lexer.tokenize()
    }

    func testNewlines() throws {
        // swiftlint:disable indentation_width
        let templateString = """
        My name is {%
            if name
             and
            name
        %}{{
        name
        }}{%
        endif %}.
        """
        // swiftlint:enable indentation_width
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 5)
        XCTAssertEqual(tokens[0], .text(value: "My name is ", at: makeSourceMap("My name is", for: lexer)))
        XCTAssertEqual(tokens[1], .block(value: "if name and name", at: makeSourceMap("{%", for: lexer)))
        XCTAssertEqual(tokens[2], .variable(value: "name", at: makeSourceMap("name", for: lexer, options: .backwards)))
        XCTAssertEqual(tokens[3], .block(value: "endif", at: makeSourceMap("endif", for: lexer)))
        XCTAssertEqual(tokens[4], .text(value: ".", at: makeSourceMap(".", for: lexer)))
    }

    func testTrimSymbols() throws {
        let fBlock = "if hello"
        let sBlock = "ta da"
        let lexer = Lexer(templateString: "{%+ \(fBlock) -%}{% \(sBlock) -%}")
        let tokens = lexer.tokenize()
        let behaviours = (
            WhitespaceBehaviour(leading: .keep, trailing: .trim),
            WhitespaceBehaviour(leading: .unspecified, trailing: .trim)
        )

        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(
            tokens[0],
            .block(value: fBlock, at: makeSourceMap(fBlock, for: lexer), whitespace: behaviours.0)
        )
        XCTAssertEqual(
            tokens[1],
            .block(value: sBlock, at: makeSourceMap(sBlock, for: lexer), whitespace: behaviours.1)
        )
    }

    func testEscapeSequence() throws {
        let templateString = "class Some {{ '{' }}{% if true %}{{ stuff }}{% endif %}"
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 5)
        XCTAssertEqual(tokens[0], .text(value: "class Some ", at: makeSourceMap("class Some ", for: lexer)))
        XCTAssertEqual(tokens[1], .variable(value: "'{'", at: makeSourceMap("'{'", for: lexer)))
        XCTAssertEqual(tokens[2], .block(value: "if true", at: makeSourceMap("if true", for: lexer)))
        XCTAssertEqual(tokens[3], .variable(value: "stuff", at: makeSourceMap("stuff", for: lexer)))
        XCTAssertEqual(tokens[4], .block(value: "endif", at: makeSourceMap("endif", for: lexer)))
    }

    func testPerformance() throws {
        let path = Path(Self.fixtures.appending("/huge.html"))
        let content: String = try path.read()

        measure {
            let lexer = Lexer(templateString: content)
            _ = lexer.tokenize()
        }
    }

    func testCombiningDiaeresis() throws {
        // the symbol "ü" in the `templateString` is unusually encoded as 0x75 0xCC 0x88 (LATIN SMALL LETTER U +
        // COMBINING
        // DIAERESIS) instead of 0xC3 0xBC (LATIN SMALL LETTER U WITH DIAERESIS)
        let templateString = "ü\n{% if test %}ü{% endif %}\n{% if ü %}ü{% endif %}\n"
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 9)
        assert(tokens[1].contents == "if test")
    }

    private func makeSourceMap(_ token: String, for lexer: Lexer, options: String.CompareOptions = []) -> SourceMap {
        guard let range = lexer.templateString.range(of: token, options: options) else { fatalError("Token not found") }
        return SourceMap(location: lexer.rangeLocation(range))
    }
}
