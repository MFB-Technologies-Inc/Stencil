// Errors.swift
// Stencil
//
// Copyright (c) 2022, Kyle Fuller
// All rights reserved.
//
// Copyright 2024 MFB Technologies, Inc.
//
// This source code is licensed under the BSD-2-Clause License found in the
// LICENSE file in the root directory of this source tree.

public final class TemplateDoesNotExist: Error, CustomStringConvertible {
    let templateNames: [String]
    let loader: (any Loader & Sendable)?

    public init(templateNames: [String], loader: (any Loader & Sendable)? = nil) {
        self.templateNames = templateNames
        self.loader = loader
    }

    public var description: String {
        let templates = templateNames.joined(separator: ", ")

        if let loader {
            return "Template named `\(templates)` does not exist in loader \(loader)"
        }

        return "Template named `\(templates)` does not exist. No loaders found"
    }
}

public struct TemplateSyntaxError: Error, Equatable, CustomStringConvertible {
    public let reason: String
    public var description: String { reason }
    public internal(set) var token: Token?
    public internal(set) var stackTrace: [Token]
    public var templateName: String? { token?.sourceMap.filename }
    var allTokens: [Token] {
        stackTrace + (token.map { [$0] } ?? [])
    }

    public init(reason: String, token: Token? = nil, stackTrace: [Token] = []) {
        self.reason = reason
        self.stackTrace = stackTrace
        self.token = token
    }

    public init(_ description: String) {
        self.init(reason: description)
    }
}

extension Error {
    func withToken(_ token: Token?) -> Error {
        if var error = self as? TemplateSyntaxError {
            error.token = error.token ?? token
            return error
        } else {
            return TemplateSyntaxError(reason: "\(self)", token: token)
        }
    }
}

public protocol ErrorReporter: AnyObject {
    func renderError(_ error: Error) -> String
}

open class SimpleErrorReporter: ErrorReporter {
    open func renderError(_ error: Error) -> String {
        guard let templateError = error as? TemplateSyntaxError else { return error.localizedDescription }

        func describe(token: Token) -> String {
            let templateName = token.sourceMap.filename ?? ""
            let location = token.sourceMap.location
            let highlight = """
            \(String(Array(repeating: " ", count: location.lineOffset)))\
            ^\(String(Array(repeating: "~", count: max(token.contents.count - 1, 0))))
            """

            return """
            \(templateName)\(location.lineNumber):\(location.lineOffset): error: \(templateError.reason)
            \(location.content)
            \(highlight)
            """
        }

        var descriptions = templateError.stackTrace.reduce(into: []) { $0.append(describe(token: $1)) }
        let description = templateError.token.map(describe(token:)) ?? templateError.reason
        descriptions.append(description)
        return descriptions.joined(separator: "\n")
    }
}
