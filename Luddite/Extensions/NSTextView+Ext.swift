//
//  NSTextView+Ext.swift
//  Luddite
//
//  Created by Keith Irwin on 10/19/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

fileprivate let tagRE = try! NSRegularExpression(pattern: "<[^>]+>", options: [.dotMatchesLineSeparators, .caseInsensitive])
fileprivate let attrRE = try! NSRegularExpression(pattern: "[^ ](\\S+=)", options: [.dotMatchesLineSeparators, .caseInsensitive])
fileprivate let valueRE = try! NSRegularExpression(pattern: "[\"].*?[\"]", options: [.dotMatchesLineSeparators, .caseInsensitive])

extension NSTextView {

    private func syntax(color: NSColor, forRange range: NSRange, inString text: NSMutableAttributedString, usingRE re: NSRegularExpression) {
        let attrMatches = re.matches(in: text.string, options: [], range: range)
        attrMatches.forEach { m in
            text.removeAttribute(.foregroundColor, range: m.range)
            text.addAttribute(.foregroundColor, value: color, range: m.range)
        }
    }

    private struct Theme {
        var tag, attr, value: NSColor

        static let dark = Theme(tag: .systemTeal, attr: .systemGray, value: .systemPurple)
        static let light = Theme(tag: .systemBlue, attr: .systemPurple, value: .systemGray)
    }

    func colorize(text: NSTextStorage, range: NSRange) {
        let theme = effectiveAppearance.bestMatch(from: [.darkAqua]) == .darkAqua ? Theme.dark : Theme.light
        text.removeAttribute(.foregroundColor, range: range)
        text.addAttribute(.foregroundColor, value: NSColor.controlTextColor, range: range)
        let matches = tagRE.matches(in: text.string, options: [], range: range)
        matches.forEach { m in
            text.removeAttribute(.foregroundColor, range: m.range)
            text.addAttribute(.foregroundColor, value: theme.tag, range: m.range)

            syntax(color: theme.attr, forRange: m.range, inString: text, usingRE: attrRE)
            syntax(color: theme.value, forRange: m.range, inString: text, usingRE: valueRE)
        }
    }

    func colorize() {
        colorize(text: textStorage!, range: NSMakeRange(0, textStorage!.string.count))
    }
}
