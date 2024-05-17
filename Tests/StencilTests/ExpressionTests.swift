// ExpressionTests.swift
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

final class ExpressionsTests: XCTestCase {
    private let parser = TokenParser(tokens: [], environment: Environment())

    private func makeExpression(_ components: [String]) throws -> Expression {
        let parser = try IfExpressionParser.parser(
            components: components,
            environment: Environment(),
            token: .text(value: "", at: .unknown)
        )
        return try parser.parse()
    }

    func testTrueExpressions() throws {
        let expression = VariableExpression(variable: Variable("value"))

        var context = Context(dictionary: ["value": "known"])
        try XCTAssertTrue(
            expression.evaluate(context: context),
            "evaluates to true when value is not nil"
        )

        let items: [[String: Any]] = [["key": "key1", "value": 42], ["key": "key2", "value": 1337]]
        context = Context(dictionary: ["value": [items]])
        try XCTAssertTrue(
            expression.evaluate(context: context),
            "evaluates to true when array variable is not empty"
        )

        let emptyItems = [String: Any]()
        context = Context(dictionary: ["value": emptyItems])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when dictionary value is empty"
        )

        context = Context(dictionary: ["value": 1])
        try XCTAssertTrue(
            expression.evaluate(context: context),
            "evaluates to true when integer value is above 0"
        )

        context = Context(dictionary: ["value": "test"])
        try XCTAssertTrue(
            expression.evaluate(context: context),
            "evaluates to true with string"
        )

        context = Context(dictionary: ["value": Float(0.5)])
        try XCTAssertTrue(
            expression.evaluate(context: context),
            "evaluates to true when float value is above 0"
        )

        context = Context(dictionary: ["value": Double(0.5)])
        try XCTAssertTrue(
            expression.evaluate(context: context),
            "evaluates to true when double value is above 0"
        )
    }

    func testFalseExpressions() throws {
        let expression = VariableExpression(variable: Variable("value"))

        var context = Context()
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when value is unset"
        )

        let emptyArrayOfDict = [[String: Any]]()
        context = Context(dictionary: ["value": emptyArrayOfDict])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when array value is empty"
        )

        let emptyDict = [String: Any]()
        context = Context(dictionary: ["value": emptyDict])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when dictionary value is empty"
        )

        context = Context(dictionary: ["value": [] as [Any]])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when Array<Any> value is empty"
        )

        context = Context(dictionary: ["value": ""])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when empty string"
        )

        context = Context(dictionary: ["value": 0])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when integer value is below 0 or below"
        )
        context = Context(dictionary: ["value": -1])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when integer value is below 0 or below"
        )

        context = Context(dictionary: ["value": Float(0)])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when float is 0 or below"
        )

        context = Context(dictionary: ["value": Double(0)])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when double is 0 or below"
        )

        context = Context(dictionary: ["value": UInt(0)])
        try XCTAssertFalse(
            expression.evaluate(context: context),
            "evaluates to false when uint is 0"
        )
    }

    func testNotExpression() throws {
        var expression = NotExpression(expression: VariableExpression(variable: Variable("true")))
        try XCTAssertFalse(
            expression.evaluate(context: Context()),
            "returns truthy for positive expressions"
        )

        expression = NotExpression(expression: VariableExpression(variable: Variable("false")))
        try XCTAssertTrue(
            expression.evaluate(context: Context()),
            "returns falsy for negative expressions"
        )
    }

    func testExpressionParsing() throws {
        var expression = try makeExpression(["value"])
        try XCTAssertFalse(
            expression.evaluate(context: Context()),
            "can parse a variable expression"
        )
        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["value": true])),
            "can parse a variable expression"
        )

        expression = try makeExpression(["not", "value"])
        try XCTAssertTrue(
            expression.evaluate(context: Context()),
            "can parse a not expression"
        )
        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["value": true])),
            "can parse a not expression"
        )
    }

    func testAndExpression() throws {
        let expression = try makeExpression(["lhs", "and", "rhs"])

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true])),
            "evaluates to false with lhs false"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])),
            "evaluates to false with rhs false"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false])),
            "evaluates to false with lhs and rhs false"
        )

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])),
            "evaluates to true with lhs and rhs true"
        )
    }

    func testOrExpression() throws {
        let expression = try makeExpression(["lhs", "or", "rhs"])

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])),
            "evaluates to true with lhs true"
        )

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": true])),
            "evaluates to true with rhs true"
        )

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])),
            "evaluates to true with lhs and rhs true"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": false, "rhs": false])),
            "evaluates to false with lhs and rhs false"
        )
    }

    func testEqualityExpression() throws {
        let expression = try makeExpression(["lhs", "==", "rhs"])

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "a"])),
            "evaluates to true with equal lhs/rhs"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "b"])),
            "evaluates to false with non equal lhs/rhs"
        )

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: [:])),
            "evaluates to true with nils"
        )

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 1.0])),
            "evaluates to true with numbers"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": 1, "rhs": 1.1])),
            "evaluates to false with non equal numbers"
        )

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": true])),
            "evaluates to true with booleans"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": false])),
            "evaluates to false with falsy booleans"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": true, "rhs": 1])),
            "evaluates to false with different types"
        )
    }

    func testInequalityExpression() throws {
        let expression = try makeExpression(["lhs", "!=", "rhs"])

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": "a", "rhs": "b"])),
            "evaluates to true with inequal lhs/rhs"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": "b", "rhs": "b"])),
            "evaluates to false with equal lhs/rhs"
        )
    }

    func testMoreThanExpression() throws {
        let expression = try makeExpression(["lhs", ">", "rhs"])

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 4])),
            "evaluates to true with lhs > rhs"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.0])),
            "evaluates to false with lhs == rhs"
        )
    }

    func testMoreThanEqualExpression() throws {
        let expression = try makeExpression(["lhs", ">=", "rhs"])

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5])),
            "evaluates to true with lhs == rhs"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.1])),
            "evaluates to false with lhs < rhs"
        )
    }

    func testLessThanExpression() throws {
        let expression = try makeExpression(["lhs", "<", "rhs"])

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": 4, "rhs": 4.5])),
            "evaluates to true with lhs < rhs"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5.0])),
            "evaluates to false with lhs == rhs"
        )
    }

    func testLessThanEqualExpression() throws {
        let expression = try makeExpression(["lhs", "<=", "rhs"])

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["lhs": 5.0, "rhs": 5])),
            "evaluates to true with lhs == rhs"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["lhs": 5.1, "rhs": 5.0])),
            "evaluates to false with lhs > rhs"
        )
    }

    func testMultipleExpressions() throws {
        let expression = try makeExpression(["one", "or", "two", "and", "not", "three"])

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["one": true])),
            "evaluates to true with one"
        )

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["one": true, "three": true])),
            "evaluates to true with one and three"
        )

        try XCTAssertTrue(
            expression.evaluate(context: Context(dictionary: ["two": true])),
            "evaluates to true with two"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["two": true, "three": true])),
            "evaluates to false with two and three"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context(dictionary: ["two": true, "three": true])),
            "evaluates to false with two and three"
        )

        try XCTAssertFalse(
            expression.evaluate(context: Context()),
            "evaluates to false with nothing"
        )
    }

    func testTrueInExpression() throws {
        let expression = try makeExpression(["lhs", "in", "rhs"])

        try XCTAssertTrue(expression.evaluate(context: Context(dictionary: [
            "lhs": 1,
            "rhs": [1, 2, 3],
        ])))

        try XCTAssertTrue(expression.evaluate(context: Context(dictionary: [
            "lhs": "a",
            "rhs": ["a", "b", "c"],
        ])))

        try XCTAssertTrue(expression.evaluate(context: Context(dictionary: [
            "lhs": "a",
            "rhs": "abc",
        ])))

        try XCTAssertTrue(expression.evaluate(context: Context(dictionary: [
            "lhs": 1,
            "rhs": 1 ... 3,
        ])))

        try XCTAssertTrue(expression.evaluate(context: Context(dictionary: [
            "lhs": 1,
            "rhs": 1 ..< 3,
        ])))
    }

    func testFalseInExpression() throws {
        let expression = try makeExpression(["lhs", "in", "rhs"])

        try XCTAssertFalse(expression.evaluate(context: Context(dictionary: [
            "lhs": 1,
            "rhs": [2, 3, 4],
        ])))

        try XCTAssertFalse(expression.evaluate(context: Context(dictionary: [
            "lhs": "a",
            "rhs": ["b", "c", "d"],
        ])))

        try XCTAssertFalse(expression.evaluate(context: Context(dictionary: [
            "lhs": "a",
            "rhs": "bcd",
        ])))

        try XCTAssertFalse(expression.evaluate(context: Context(dictionary: [
            "lhs": 4,
            "rhs": 1 ... 3,
        ])))

        try XCTAssertFalse(expression.evaluate(context: Context(dictionary: [
            "lhs": 3,
            "rhs": 1 ..< 3,
        ])))
    }
}
