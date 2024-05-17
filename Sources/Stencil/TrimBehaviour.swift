// TrimBehaviour.swift
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

public struct TrimBehaviour: Equatable, Sendable {
    var leading: Trim
    var trailing: Trim

    public enum Trim: Sendable {
        /// nothing
        case nothing

        /// tabs and spaces
        case whitespace

        /// tabs and spaces and a single new line
        case whitespaceAndOneNewLine

        /// all tabs spaces and newlines
        case whitespaceAndNewLines
    }

    public init(leading: Trim, trailing: Trim) {
        self.leading = leading
        self.trailing = trailing
    }

    /// doesn't touch newlines
    public static let nothing = TrimBehaviour(leading: .nothing, trailing: .nothing)

    /// removes whitespace before a block and whitespace and a single newline after a block
    public static let smart = TrimBehaviour(leading: .whitespace, trailing: .whitespaceAndOneNewLine)

    /// removes all whitespace and newlines before and after a block
    public static let all = TrimBehaviour(leading: .whitespaceAndNewLines, trailing: .whitespaceAndNewLines)

    static func leadingRegex(trim: Trim) -> NSRegularExpression {
        switch trim {
        case .nothing:
            fatalError("No RegularExpression for none")
        case .whitespace:
            leadingWhitespace
        case .whitespaceAndOneNewLine:
            leadingWhitespaceAndOneNewLine
        case .whitespaceAndNewLines:
            leadingWhitespaceAndNewlines
        }
    }

    static func trailingRegex(trim: Trim) -> NSRegularExpression {
        switch trim {
        case .nothing:
            fatalError("No RegularExpression for none")
        case .whitespace:
            trailingWhitespace
        case .whitespaceAndOneNewLine:
            trailingWhitespaceAndOneNewLine
        case .whitespaceAndNewLines:
            trailingWhitespaceAndNewLines
        }
    }

    // swiftlint:disable force_try
    private static let leadingWhitespaceAndNewlines = try! NSRegularExpression(pattern: "^\\s+")
    private static let trailingWhitespaceAndNewLines = try! NSRegularExpression(pattern: "\\s+$")

    private static let leadingWhitespaceAndOneNewLine = try! NSRegularExpression(pattern: "^[ \t]*\n")
    private static let trailingWhitespaceAndOneNewLine = try! NSRegularExpression(pattern: "\n[ \t]*$")

    private static let leadingWhitespace = try! NSRegularExpression(pattern: "^[ \t]*")
    private static let trailingWhitespace = try! NSRegularExpression(pattern: "[ \t]*$")
    // swiftlint:enable force_try
}
