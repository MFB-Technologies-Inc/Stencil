// VariableTests.swift
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

final class VariableTests: XCTestCase {
    private let context: Context = {
        let ext = Extension()
        ext.registerFilter("incr") { arg in
            (arg.flatMap { toNumber(value: $0) } ?? 0) + 1
        }
        let environment = Environment(extensions: [ext])

        var context = Context(dictionary: [
            "name": "Kyle",
            "contacts": ["Katie", "Carlton"],
            "profiles": [
                "github": "kylef",
            ],
            "counter": [
                "count": "kylef",
            ],
            "article": Article(author: Person(name: "Kyle")),
            "blog": Blog(),
            "tuple": (one: 1, two: 2),
            "dynamic": [
                "enum": DynamicEnum.someValue,
                "struct": DynamicStruct(),
            ],
        ], environment: environment)
        #if os(OSX)
            context["object"] = Object()
        #endif
        return context
    }()

    func testLiterals() throws {
        _ = try {
            let variable = Variable("\"name\"")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "name",
                "can resolve a string literal with double quotes"
            )
        }()

        _ = try {
            let variable = Variable("\"")
            let result = try variable.resolve(self.context) as? String
            XCTAssertNil(
                result,
                "can resolve a string literal with one double quote"
            )
        }()

        _ = try {
            let variable = Variable("'name'")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "name",
                "can resolve a string literal with single quotes"
            )
        }()

        _ = try {
            let variable = Variable("'")
            let result = try variable.resolve(self.context) as? String
            XCTAssertNil(
                result,
                "can resolve a string literal with one single quote"
            )
        }()

        _ = try {
            let variable = Variable("5")
            let result = try variable.resolve(self.context) as? Int
            XCTAssertEqual(
                result,
                5,
                "can resolve an integer literal"
            )
        }()

        _ = try {
            let variable = Variable("3.14")
            let result = try variable.resolve(self.context) as? Number
            XCTAssertEqual(
                result,
                3.14,
                "can resolve an float literal"
            )
        }()

        _ = try {
            try XCTAssertEqual(
                Variable("true").resolve(self.context) as? Bool,
                true,
                "can resolve boolean literal"
            )
            try XCTAssertEqual(
                Variable("false").resolve(self.context) as? Bool,
                false,
                "can resolve boolean literal"
            )
            try XCTAssertEqual(
                Variable("0").resolve(self.context) as? Int,
                0,
                "can resolve boolean literal"
            )
            try XCTAssertEqual(
                Variable("1").resolve(self.context) as? Int,
                1,
                "can resolve boolean literal"
            )
        }()
    }

    func testVariable() throws {
        _ = try {
            let variable = Variable("name")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Kyle",
                "can resolve a string variable"
            )
        }()
    }

    func testDictionary() throws {
        _ = try {
            let variable = Variable("profiles.github")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "kylef",
                "can resolve an item from a dictionary"
            )
        }()

        _ = try {
            let variable = Variable("profiles.count")
            let result = try variable.resolve(self.context) as? Int
            XCTAssertEqual(
                result,
                1,
                "can get the count of a dictionary"
            )
        }()
    }

    func testArray() throws {
        _ = try {
            let variable = Variable("contacts.0")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Katie",
                "can resolve an item from an array via it's index"
            )

            let variable1 = Variable("contacts.1")
            let result1 = try variable1.resolve(self.context) as? String
            XCTAssertEqual(
                result1,
                "Carlton",
                "can resolve an item from an array via it's index"
            )
        }()

        _ = try {
            let variable = Variable("contacts.5")
            let result = try variable.resolve(self.context) as? String
            XCTAssertNil(result, "can resolve an item from an array via unknown index")

            let variable1 = Variable("contacts.-5")
            let result1 = try variable1.resolve(self.context) as? String
            XCTAssertNil(result1, "can resolve an item from an array via unknown index")
        }()

        _ = try {
            let variable = Variable("contacts.first")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Katie",
                "can resolve the first item from an array"
            )
        }()

        _ = try {
            let variable = Variable("contacts.last")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Carlton",
                "can resolve the last item from an array"
            )
        }()
    }

    func testDynamicMemberLookup() throws {
        _ = try {
            let variable = Variable("dynamic.struct.test")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "this is a dynamic response",
                "can resolve dynamic member lookup"
            )
        }()

        _ = try {
            let variable = Variable("dynamic.enum.rawValue")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "this is raw value",
                "can resolve dynamic enum rawValue"
            )
        }()
    }

    func testReflection() throws {
        _ = try {
            let variable = Variable("article.author.name")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Kyle",
                "can resolve a property with reflection"
            )
        }()

        _ = try {
            let variable = Variable("blog.articles.0.author.name")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Kyle",
                "can resolve a value via reflection"
            )
        }()

        _ = try {
            let variable = Variable("blog.url")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "blog.com",
                "can resolve a superclass value via reflection"
            )
        }()

        _ = try {
            let variable = Variable("blog.featuring.author.name")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Jhon",
                "can resolve optional variable property using reflection"
            )
        }()
    }

    func testKVO() throws {
        #if os(OSX)
            _ = try {
                let variable = Variable("object.title")
                let result = try variable.resolve(self.context) as? String
                XCTAssertEqual(
                    result,
                    "Hello World",
                    "can resolve a value via KVO"
                )
            }()

            _ = try {
                let variable = Variable("object.name")
                let result = try variable.resolve(self.context) as? String
                XCTAssertEqual(
                    result,
                    "Foo",
                    "can resolve a superclass value via KVO"
                )
            }()

            _ = try {
                let variable = Variable("object.fullname")
                let result = try variable.resolve(self.context) as? String
                XCTAssertNil(result, "does not crash on KVO")
            }()
        #endif
    }

    func testTuple() throws {
        _ = try {
            let variable = Variable("tuple.0")
            let result = try variable.resolve(self.context) as? Int
            XCTAssertEqual(
                result,
                1,
                "can resolve tuple by index"
            )
        }()

        _ = try {
            let variable = Variable("tuple.two")
            let result = try variable.resolve(self.context) as? Int
            XCTAssertEqual(
                result,
                2,
                "can resolve tuple by label"
            )
        }()
    }

    func testOptional() throws {
        _ = try {
            var array: [Any?] = [1, nil]
            array.append(array)
            let context = Context(dictionary: ["values": array])

            try XCTAssertEqual(
                VariableNode(variable: "values").render(context),
                "[1, nil, [1, nil]]",
                "does not render Optional"
            )
            try XCTAssertEqual(
                VariableNode(variable: "values.1").render(context),
                "",
                "does not render Optional"
            )
        }()
    }

    func testSubscripting() throws {
        _ = try context.push(dictionary: ["property": "name"]) {
            let variable = Variable("article.author[property]")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Kyle",
                "can resolve a property subscript via reflection"
            )
        }

        _ = try context.push(dictionary: ["property": 0]) {
            let variable = Variable("contacts[property]")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Katie",
                "can subscript an array with a valid index"
            )
        }

        _ = try context.push(dictionary: ["property": 5]) {
            let variable = Variable("contacts[property]")
            let result = try variable.resolve(self.context) as? String
            XCTAssertNil(result, "can subscript an array with an unknown index")
        }

        #if os(OSX)
            _ = try context.push(dictionary: ["property": "name"]) {
                let variable = Variable("object[property]")
                let result = try variable.resolve(self.context) as? String
                XCTAssertEqual(
                    result,
                    "Foo",
                    "can resolve a subscript via KVO"
                )
            }
        #endif

        _ = try context.push(dictionary: ["property": "featuring"]) {
            let variable = Variable("blog[property].author.name")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Jhon",
                "can resolve an optional subscript via reflection"
            )
        }
    }

    func testMultipleSubscripting() throws {
        _ = try context.push(dictionary: [
            "prop1": "articles",
            "prop2": 0,
            "prop3": "name",
        ]) {
            let variable = Variable("blog[prop1][prop2].author[prop3]")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Kyle",
                "can resolve multiple subscripts"
            )
        }

        _ = try context.push(dictionary: [
            "prop1": "prop2",
            "ref": ["prop2": "name"],
        ]) {
            let variable = Variable("article.author[ref[prop1]]")
            let result = try variable.resolve(self.context) as? String
            XCTAssertEqual(
                result,
                "Kyle",
                "can resolve nested subscripts"
            )
        }

        _ = try context.push(dictionary: ["prop": "name"]) {
            let samples = [
                ".",
                "..",
                ".test",
                "test..test",
                "[prop]",
                "article.author[prop",
                "article.author[[prop]",
                "article.author[prop]]",
                "article.author[]",
                "article.author[[]]",
                "article.author[prop][]",
                "article.author[prop]comments",
                "article.author[.]",
            ]

            for lookup in samples {
                let variable = Variable(lookup)
                try XCTAssertThrowsError(
                    variable.resolve(self.context),
                    "throws for invalid keypath syntax"
                )
            }
        }
    }

    func testRangeVariable() throws {
        func makeVariable(_ token: String) throws -> RangeVariable? {
            let token = Token.variable(value: token, at: .unknown)
            return try RangeVariable(token.contents, environment: context.environment, containedIn: token)
        }

        _ = try {
            let result = try makeVariable("1...3")?.resolve(self.context) as? [Int]
            XCTAssertEqual(
                result, [1, 2, 3],
                "can resolve closed range as array"
            )
        }()

        _ = try {
            let result = try makeVariable("3...1")?.resolve(self.context) as? [Int]
            XCTAssertEqual(
                result, [3, 2, 1],
                "can resolve decreasing closed range as reversed array"
            )
        }()

        _ = try {
            let result = try makeVariable("1|incr...3|incr")?.resolve(self.context) as? [Int]
            XCTAssertEqual(
                result, [2, 3, 4],
                "can use filter on range variables"
            )
        }()

        _ = try {
            let template: Template = "{% for i in k...j %}{{ i }}{% endfor %}"
            try XCTAssertThrowsError(
                template.render(Context(dictionary: ["j": 3, "k": "1"])),
                "throws when left value is not int"
            )
        }()

        _ = try {
            let variable = try makeVariable("k...j")
            try XCTAssertThrowsError(
                variable?.resolve(Context(dictionary: ["j": "3", "k": 1])),
                "throws when right value is not int"
            )
        }()

        _ = try XCTAssertThrowsError(
            makeVariable("...1"),
            "throws is left range value is missing"
        )

        _ = try XCTAssertThrowsError(
            makeVariable("1..."),
            "throws is right range value is missing"
        )
    }
}

// MARK: - Helpers

#if os(OSX)
    @objc
    class Superclass: NSObject {
        @objc let name = "Foo"
    }

    @objc
    class Object: Superclass {
        @objc let title = "Hello World"
    }
#endif

private struct Person {
    let name: String
}

private struct Article {
    let author: Person
}

private class WebSite {
    let url: String = "blog.com"
}

private class Blog: WebSite {
    let articles: [Article] = [Article(author: Person(name: "Kyle"))]
    let featuring: Article? = Article(author: Person(name: "Jhon"))
}

@dynamicMemberLookup
private struct DynamicStruct: DynamicMemberLookup {
    subscript(dynamicMember member: String) -> Any? {
        member == "test" ? "this is a dynamic response" : nil
    }
}

private enum DynamicEnum: String, DynamicMemberLookup {
    case someValue = "this is raw value"
}
