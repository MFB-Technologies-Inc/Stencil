// ForNodeTests.swift
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

final class ForNodeTests: StencilTestCase {
    private let context = Context(dictionary: [
        "items": [1, 2, 3],
        "anyItems": [1, 2, 3] as [Any],
        // swiftlint:disable:next legacy_objc_type
        "nsItems": NSArray(array: [1, 2, 3]),
        "emptyItems": [Int](),
        "dict": [
            "one": "I",
            "two": "II",
        ],
        "tuples": [(1, 2, 3), (4, 5, 6)],
    ])

    func testForNode() throws {
        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item")]
            let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
            try XCTAssertEqual(
                node.render(self.context),
                "123",
                "renders the given nodes for each item"
            )
        }()

        _ = try {
            let node = ForNode(
                resolvable: Variable("emptyItems"),
                loopVariables: ["item"],
                nodes: [VariableNode(variable: "item")],
                emptyNodes: [TextNode(text: "empty")]
            )
            try XCTAssertEqual(
                node.render(self.context),
                "empty",
                "renders the given empty nodes when no items found item"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item")]
            let node = ForNode(resolvable: Variable("anyItems"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
            try XCTAssertEqual(
                node.render(self.context),
                "123",
                "renders a context variable of type Array<Any>"
            )
        }()

        #if os(OSX)
            _ = try {
                let nodes: [NodeType] = [VariableNode(variable: "item")]
                let node = ForNode(
                    resolvable: Variable("nsItems"),
                    loopVariables: ["item"],
                    nodes: nodes,
                    emptyNodes: []
                )
                try XCTAssertEqual(
                    node.render(self.context),
                    "123",
                    "renders a context variable of type NSArray"
                )
            }()
        #endif

        _ = try {
            let template = Template(templateString: """
            {% for article in ars | default: a, b , articles %}\
            - {{ article.title }} by {{ article.author }}.
            {% endfor %}
            """)
            let context = Context(dictionary: [
                "articles": [
                    Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
                    Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
                ],
            ])
            let result = try template.render(context)
            let expectedResult = """
            - Migrating from OCUnit to XCTest by Kyle Fuller.
            - Memory Management with ARC by Kyle Fuller.

            """
            XCTAssertEqual(
                result,
                expectedResult,
                "can render a filter with spaces"
            )
        }()
    }

    func testLoopMetadata() throws {
        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.first")]
            let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
            try XCTAssertEqual(
                node.render(self.context),
                "1true2false3false",
                "renders the given nodes while providing if the item is first in the context"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.last")]
            let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
            try XCTAssertEqual(
                node.render(self.context),
                "1false2false3true",
                "renders the given nodes while providing if the item is last in the context"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter")]
            let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
            try XCTAssertEqual(
                node.render(self.context),
                "112233",
                "renders the given nodes while providing item counter"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter0")]
            let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
            try XCTAssertEqual(
                node.render(self.context),
                "102132",
                "renders the given nodes while providing item counter"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.length")]
            let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
            try XCTAssertEqual(
                node.render(self.context),
                "132333",
                "renders the given nodes while providing loop length"
            )
        }()
    }

    func testWhereExpression() throws {
        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter")]
            let parser = TokenParser(tokens: [], environment: Environment())
            let `where` = try parser.compileExpression(
                components: ["item", ">", "1"],
                token: .text(value: "", at: .unknown)
            )
            let node = ForNode(
                resolvable: Variable("items"),
                loopVariables: ["item"],
                nodes: nodes,
                emptyNodes: [],
                where: `where`
            )
            try XCTAssertEqual(
                node.render(self.context),
                "2132",
                "renders the given nodes while filtering items using where expression"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [VariableNode(variable: "item")]
            let emptyNodes: [NodeType] = [TextNode(text: "empty")]
            let parser = TokenParser(tokens: [], environment: Environment())
            let `where` = try parser.compileExpression(
                components: ["item", "==", "0"],
                token: .text(value: "", at: .unknown)
            )
            let node = ForNode(
                resolvable: Variable("emptyItems"),
                loopVariables: ["item"],
                nodes: nodes,
                emptyNodes: emptyNodes,
                where: `where`
            )
            try XCTAssertEqual(
                node.render(self.context),
                "empty",
                "renders the given empty nodes when all items filtered out with where expression"
            )
        }()
    }

    func testArrayOfTuples() throws {
        _ = try {
            let template = Template(templateString: """
            {% for first,second,third in tuples %}\
            {{ first }}, {{ second }}, {{ third }}
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                1, 2, 3
                4, 5, 6

                """,
                "can iterate over all tuple values"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% for first,second in tuples %}\
            {{ first }}, {{ second }}
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                1, 2
                4, 5

                """,
                "can iterate with less number of variables"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% for first,_,third in tuples %}\
            {{ first }}, {{ third }}
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                1, 3
                4, 6

                """,
                "can use _ to skip variables"
            )
        }()

        _ = try {
            let template = Template(templateString: #"{% for key,value,smth in dict %}{% endfor %}"#)

            try XCTAssertThrowsError(
                template.render(self.context),
                "throws when number of variables is more than number of tuple values"
            )
        }()
    }

    func testIterateDictionary() throws {
        _ = try {
            let template = Template(templateString: """
            {% for key, value in dict %}\
            {{ key }}: {{ value }},\
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                #"one: I,two: II,"#,
                "can iterate over dictionary"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [
                VariableNode(variable: "key"),
                TextNode(text: ","),
            ]
            let emptyNodes: [NodeType] = [TextNode(text: "empty")]
            let node = ForNode(
                resolvable: Variable("dict"),
                loopVariables: ["key"],
                nodes: nodes,
                emptyNodes: emptyNodes
            )

            try XCTAssertEqual(
                node.render(self.context),
                "one,two,",
                "renders supports iterating over dictionary"
            )
        }()

        _ = try {
            let nodes: [NodeType] = [
                VariableNode(variable: "key"),
                TextNode(text: "="),
                VariableNode(variable: "value"),
                TextNode(text: ","),
            ]
            let emptyNodes: [NodeType] = [TextNode(text: "empty")]
            let node = ForNode(
                resolvable: Variable("dict"),
                loopVariables: ["key", "value"],
                nodes: nodes,
                emptyNodes: emptyNodes
            )

            try XCTAssertEqual(
                node.render(self.context),
                "one=I,two=II,",
                "renders supports iterating over dictionary with values"
            )
        }()
    }

    func testIterateUsingMirroring() throws {
        let nodes: [NodeType] = [
            VariableNode(variable: "label"),
            TextNode(text: "="),
            VariableNode(variable: "value"),
            TextNode(text: "\n"),
        ]
        let node = ForNode(
            resolvable: Variable("item"),
            loopVariables: ["label", "value"],
            nodes: nodes,
            emptyNodes: []
        )

        _ = try {
            let context = Context(dictionary: [
                "item": MyStruct(string: "abc", number: 123),
            ])
            try XCTAssertEqual(
                node.render(context),
                """
                string=abc
                number=123

                """,
                "can iterate over struct properties"
            )
        }()

        _ = try {
            let context = Context(dictionary: [
                "item": (one: 1, two: "dva"),
            ])
            try XCTAssertEqual(
                node.render(context),
                """
                one=1
                two=dva

                """,
                "can iterate tuple items"
            )
        }()

        _ = try {
            let context = Context(dictionary: [
                "item": MySubclass("child", "base", 1),
            ])
            try XCTAssertEqual(
                node.render(context),
                """
                childString=child
                baseString=base
                baseInt=1

                """,
                "can iterate over class properties"
            )
        }()
    }

    func testIterateRange() throws {
        _ = try {
            let context = Context(dictionary: ["range": 1 ... 3])
            let nodes: [NodeType] = [VariableNode(variable: "item")]
            let node = ForNode(resolvable: Variable("range"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])

            XCTAssertEqual(
                try node.render(context),
                "123",
                "renders a context variable of type CountableClosedRange<Int>"
            )
        }()

        _ = try {
            let context = Context(dictionary: ["range": 1 ..< 4])
            let nodes: [NodeType] = [VariableNode(variable: "item")]
            let node = ForNode(resolvable: Variable("range"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])

            XCTAssertEqual(
                try node.render(context),
                "123",
                "renders a context variable of type CountableRange<Int>"
            )
        }()

        _ = try {
            let template: Template = "{% for i in 1...j %}{{ i }}{% endfor %}"
            XCTAssertEqual(
                try template.render(Context(dictionary: ["j": 3])),
                "123",
                "can iterate in range of variables"
            )
        }()
    }

    func testHandleInvalidInput() throws {
        let token = Token.block(value: "for i", at: .unknown)
        let parser = TokenParser(tokens: [token], environment: Environment())
        let expectedError = TemplateSyntaxError(
            reason: "'for' statements should use the syntax: `for <x> in <y> [where <condition>]`.",
            token: token
        )
        try XCTAssertThrowsError(parser.parse()) { error in
            XCTAssertEqual(error as? TemplateSyntaxError, expectedError)
        }
    }

    func testBreak() throws {
        _ = try {
            let template = Template(templateString: """
            {% for item in items %}\
            {{ item }}{% break %}\
            {% endfor %}
            """)
            let expectedValue = #"1"#
            try XCTAssertEqual(
                template.render(self.context),
                expectedValue,
                "can break from loop"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% for item in items %}\
            {{ item }}\
            {% if forloop.first %}<{% break %}>{% endif %}!\
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                #"1<"#,
                "can break from inner node"
            )
        }()

        _ = try {
            let template = Template(templateString: "{% for item in items %}{% endfor %}{% break %}")
            let expectedError = self.expectedSyntaxError(
                token: "break",
                template: template,
                description: "'break' can be used only inside loop body"
            )
            try XCTAssertThrowsError(
                template.render(self.context),
                "does not allow break outside loop"
            ) { error in
                XCTAssertEqual(error as? TemplateSyntaxError, expectedError)
            }
        }()
    }

    func testBreakNested() throws {
        _ = try {
            let template = Template(templateString: """
            {% for item in items %}\
            outer: {{ item }}
            {% for item in items %}\
            inner: {{ item }}
            {% endfor %}\
            {% break %}\
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                outer: 1
                inner: 1
                inner: 2
                inner: 3

                """,
                "breaks outer loop"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% for item in items %}\
            outer: {{ item }}
            {% for item in items %}\
            inner: {{ item }}
            {% break %}\
            {% endfor %}\
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                outer: 1
                inner: 1
                outer: 2
                inner: 1
                outer: 3
                inner: 1

                """,
                "breaks inner loop"
            )
        }()
    }

    func testBreakLabeled() throws {
        _ = try {
            let template = Template(templateString: """
            {% outer: for item in items %}\
            outer: {{ item }}
            {% for item in items %}\
            {% break outer %}\
            inner: {{ item }}
            {% endfor %}\
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                outer: 1

                """,
                "breaks labeled loop"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% outer: for item in items %}
            {% break inner %}
            {% endfor %}
            """)
            try XCTAssertThrowsError(
                template.render(self.context),
                "throws when breaking with unknown label"
            )
        }()
    }

    func testContinue() throws {
        _ = try {
            let template = Template(templateString: """
            {% for item in items %}\
            {{ item }}{% continue %}!\
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                "123",
                "can continue loop"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% for item in items %}\
            {% if forloop.last %}<{% continue %}>{% endif %}!\
            {{ item }}\
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                "!1!2<",
                "can continue from inner node"
            )
        }()

        _ = try {
            let template = Template(templateString: "{% for item in items %}{% endfor %}{% continue %}")
            let expectedError = self.expectedSyntaxError(
                token: "continue",
                template: template,
                description: "'continue' can be used only inside loop body"
            )
            try XCTAssertThrowsError(
                template.render(self.context),
                "does not allow continue outside loop"
            ) { error in
                XCTAssertEqual(error as? TemplateSyntaxError, expectedError)
            }
        }()
    }

    func testContinueNested() throws {
        _ = try {
            let template = Template(templateString: """
            {% for item in items %}\
            {% for item in items %}\
            inner: {{ item }}\
            {% endfor %}
            {% continue %}
            outer: {{ item }}
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                inner: 1inner: 2inner: 3
                inner: 1inner: 2inner: 3
                inner: 1inner: 2inner: 3

                """,
                "breaks outer loop"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% for item in items %}\
            {% for item in items %}\
            {% continue %}\
            inner: {{ item }}
            {% endfor %}\
            outer: {{ item }}
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                outer: 1
                outer: 2
                outer: 3

                """,
                "breaks inner loop"
            )
        }()
    }

    func testContinueLabeled() throws {
        _ = try {
            let template = Template(templateString: """
            {% outer: for item in items %}\
            {% for item in items %}\
            inner: {{ item }}
            {% continue outer %}\
            {% endfor %}\
            outer: {{ item }}
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                inner: 1
                inner: 1
                inner: 1

                """,
                "continues labeled loop"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% outer: for item in items %}
            {% continue inner %}
            {% endfor %}
            """)
            try XCTAssertThrowsError(
                template.render(self.context),
                "throws when continuing with unknown label"
            )
        }()
    }

    func testAccessLabeled() throws {
        _ = try {
            let template = Template(templateString: """
            {% outer: for item in 1...2 %}\
            {% for item in items %}\
            {{ forloop.counter }}-{{ forloop.outer.counter }},\
            {% endfor %}---\
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                #"1-1,2-1,3-1,---1-2,2-2,3-2,---"#,
                "can access labeled outer loop context from inner loop"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% outer: for item in 1...2 %}{% for item in 1...2 %}\
            {% for item in items %}\
            {{ forloop.counter }}-{{ forloop.outer.counter }},\
            {% endfor %}---{% endfor %}
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                1-1,2-1,3-1,---1-1,2-1,3-1,---
                1-2,2-2,3-2,---1-2,2-2,3-2,---

                """,
                "can access labeled outer loop from double inner loop"
            )
        }()

        _ = try {
            let template = Template(templateString: """
            {% outer1: for item in 1...2 %}{% outer2: for item in 1...2 %}\
            {% for item in items %}\
            {{ forloop.counter }}-{{ forloop.outer2.counter }}-{{ forloop.outer1.counter }},\
            {% endfor %}---{% endfor %}
            {% endfor %}
            """)
            try XCTAssertEqual(
                template.render(self.context),
                """
                1-1-1,2-1-1,3-1-1,---1-2-1,2-2-1,3-2-1,---
                1-1-2,2-1-2,3-1-2,---1-2-2,2-2-2,3-2-2,---

                """,
                "can access two labeled outer loop contexts from inner loop"
            )
        }()
    }
}

// MARK: - Helpers

private struct MyStruct {
    let string: String
    let number: Int
}

private struct Article {
    let title: String
    let author: String
}

private class MyClass {
    var baseString: String
    var baseInt: Int
    init(_ string: String, _ int: Int) {
        baseString = string
        baseInt = int
    }
}

private class MySubclass: MyClass {
    var childString: String
    init(_ childString: String, _ string: String, _ int: Int) {
        self.childString = childString
        super.init(string, int)
    }
}
