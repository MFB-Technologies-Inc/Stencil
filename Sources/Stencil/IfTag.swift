// IfTag.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

enum Operator {
    case infix(String, Int, InfixOperator.Type)
    case prefix(String, Int, PrefixOperator.Type)

    var name: String {
        switch self {
        case let .infix(name, _, _):
            name
        case let .prefix(name, _, _):
            name
        }
    }

    static let all: [Operator] = [
        .infix("in", 5, InExpression.self),
        .infix("or", 6, OrExpression.self),
        .infix("and", 7, AndExpression.self),
        .prefix("not", 8, NotExpression.self),
        .infix("==", 10, EqualityExpression.self),
        .infix("!=", 10, InequalityExpression.self),
        .infix(">", 10, MoreThanExpression.self),
        .infix(">=", 10, MoreThanEqualExpression.self),
        .infix("<", 10, LessThanExpression.self),
        .infix("<=", 10, LessThanEqualExpression.self),
    ]
}

func findOperator(name: String) -> Operator? {
    for `operator` in Operator.all where `operator`.name == name {
        return `operator`
    }

    return nil
}

indirect enum IfToken {
    case infix(name: String, bindingPower: Int, operatorType: InfixOperator.Type)
    case prefix(name: String, bindingPower: Int, operatorType: PrefixOperator.Type)
    case variable(Resolvable)
    case subExpression(Expression)
    case end

    var bindingPower: Int {
        switch self {
        case let .infix(_, bindingPower, _):
            bindingPower
        case let .prefix(_, bindingPower, _):
            bindingPower
        case .variable:
            0
        case .subExpression:
            0
        case .end:
            0
        }
    }

    func nullDenotation(parser: IfExpressionParser) throws -> Expression {
        switch self {
        case let .infix(name, _, _):
            throw TemplateSyntaxError("'if' expression error: infix operator '\(name)' doesn't have a left hand side")
        case let .prefix(_, bindingPower, operatorType):
            let expression = try parser.expression(bindingPower: bindingPower)
            return operatorType.init(expression: expression)
        case let .variable(variable):
            return VariableExpression(variable: variable)
        case let .subExpression(expression):
            return expression
        case .end:
            throw TemplateSyntaxError("'if' expression error: end")
        }
    }

    func leftDenotation(left: Expression, parser: IfExpressionParser) throws -> Expression {
        switch self {
        case let .infix(_, bindingPower, operatorType):
            let right = try parser.expression(bindingPower: bindingPower)
            return operatorType.init(lhs: left, rhs: right)
        case let .prefix(name, _, _):
            throw TemplateSyntaxError(
                "'if' expression error: prefix operator '\(name)' was called with a left hand side"
            )
        case let .variable(variable):
            throw TemplateSyntaxError("'if' expression error: variable '\(variable)' was called with a left hand side")
        case .subExpression:
            throw TemplateSyntaxError("'if' expression error: sub expression was called with a left hand side")
        case .end:
            throw TemplateSyntaxError("'if' expression error: end")
        }
    }

    var isEnd: Bool {
        switch self {
        case .end:
            true
        default:
            false
        }
    }
}

final class IfExpressionParser {
    let tokens: [IfToken]
    var position: Int = 0

    private init(tokens: [IfToken]) {
        self.tokens = tokens
    }

    static func parser(components: [String], environment: Environment, token: Token) throws -> IfExpressionParser {
        try IfExpressionParser(components: ArraySlice(components), environment: environment, token: token)
    }

    private init(components: ArraySlice<String>, environment: Environment, token: Token) throws {
        var parsedComponents = Set<Int>()
        var bracketsBalance = 0
        tokens = try zip(components.indices, components).compactMap { index, component in
            guard !parsedComponents.contains(index) else { return nil }

            if component == "(" {
                bracketsBalance += 1
                let (expression, parsedCount) = try Self.subExpression(
                    from: components.suffix(from: index + 1),
                    environment: environment,
                    token: token
                )
                parsedComponents.formUnion(Set(index ... (index + parsedCount)))
                return .subExpression(expression)
            } else if component == ")" {
                bracketsBalance -= 1
                if bracketsBalance < 0 {
                    throw TemplateSyntaxError("'if' expression error: missing opening bracket")
                }
                parsedComponents.insert(index)
                return nil
            } else {
                parsedComponents.insert(index)
                if let `operator` = findOperator(name: component) {
                    switch `operator` {
                    case let .infix(name, bindingPower, operatorType):
                        return .infix(name: name, bindingPower: bindingPower, operatorType: operatorType)
                    case let .prefix(name, bindingPower, operatorType):
                        return .prefix(name: name, bindingPower: bindingPower, operatorType: operatorType)
                    }
                }
                return try .variable(environment.compileResolvable(component, containedIn: token))
            }
        }
    }

    private static func subExpression(
        from components: ArraySlice<String>,
        environment: Environment,
        token: Token
    ) throws -> (Expression, Int) {
        var bracketsBalance = 1
        let subComponents = components.prefix { component in
            if component == "(" {
                bracketsBalance += 1
            } else if component == ")" {
                bracketsBalance -= 1
            }
            return bracketsBalance != 0
        }
        if bracketsBalance > 0 {
            throw TemplateSyntaxError("'if' expression error: missing closing bracket")
        }

        let expressionParser = try IfExpressionParser(components: subComponents, environment: environment, token: token)
        let expression = try expressionParser.parse()
        return (expression, subComponents.count)
    }

    var currentToken: IfToken {
        if tokens.count > position {
            return tokens[position]
        }

        return .end
    }

    var nextToken: IfToken {
        position += 1
        return currentToken
    }

    func parse() throws -> Expression {
        let expression = try expression()

        if !currentToken.isEnd {
            throw TemplateSyntaxError("'if' expression error: dangling token")
        }

        return expression
    }

    func expression(bindingPower: Int = 0) throws -> Expression {
        var token = currentToken
        position += 1

        var left = try token.nullDenotation(parser: self)

        while bindingPower < currentToken.bindingPower {
            token = currentToken
            position += 1
            left = try token.leftDenotation(left: left, parser: self)
        }

        return left
    }
}

/// Represents an if condition and the associated nodes when the condition
/// evaluates
final class IfCondition {
    let expression: Expression?
    let nodes: [NodeType]

    init(expression: Expression?, nodes: [NodeType]) {
        self.expression = expression
        self.nodes = nodes
    }

    func render(_ context: Context) throws -> String {
        try context.push {
            try renderNodes(nodes, context)
        }
    }
}

class IfNode: NodeType {
    let conditions: [IfCondition]
    let token: Token?

    class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
        var components = token.components
        components.removeFirst()

        let expression = try parser.compileExpression(components: components, token: token)
        let nodes = try parser.parse(until(["endif", "elif", "else"]))
        var conditions: [IfCondition] = [
            IfCondition(expression: expression, nodes: nodes),
        ]

        var nextToken = parser.nextToken()
        while let current = nextToken, current.contents.hasPrefix("elif") {
            var components = current.components
            components.removeFirst()
            let expression = try parser.compileExpression(components: components, token: current)

            let nodes = try parser.parse(until(["endif", "elif", "else"]))
            nextToken = parser.nextToken()
            conditions.append(IfCondition(expression: expression, nodes: nodes))
        }

        if let current = nextToken, current.contents == "else" {
            try conditions.append(IfCondition(expression: nil, nodes: parser.parse(until(["endif"]))))
            nextToken = parser.nextToken()
        }

        guard let current = nextToken, current.contents == "endif" else {
            throw TemplateSyntaxError("`endif` was not found.")
        }

        return IfNode(conditions: conditions, token: token)
    }

    class func parse_ifnot(_ parser: TokenParser, token: Token) throws -> NodeType {
        var components = token.components
        guard components.count == 2 else {
            throw TemplateSyntaxError("'ifnot' statements should use the following syntax 'ifnot condition'.")
        }
        components.removeFirst()
        var trueNodes = [NodeType]()
        var falseNodes = [NodeType]()

        let expression = try parser.compileExpression(components: components, token: token)
        falseNodes = try parser.parse(until(["endif", "else"]))

        guard let token = parser.nextToken() else {
            throw TemplateSyntaxError("`endif` was not found.")
        }

        if token.contents == "else" {
            trueNodes = try parser.parse(until(["endif"]))
            _ = parser.nextToken()
        }

        return IfNode(conditions: [
            IfCondition(expression: expression, nodes: trueNodes),
            IfCondition(expression: nil, nodes: falseNodes),
        ], token: token)
    }

    init(conditions: [IfCondition], token: Token? = nil) {
        self.conditions = conditions
        self.token = token
    }

    func render(_ context: Context) throws -> String {
        for condition in conditions {
            if let expression = condition.expression {
                let truthy = try expression.evaluate(context: context)

                if truthy {
                    return try condition.render(context)
                }
            } else {
                return try condition.render(context)
            }
        }

        return ""
    }
}
