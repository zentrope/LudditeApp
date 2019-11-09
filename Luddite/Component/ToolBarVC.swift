//
//  ToolBar.swift
//  Luddite
//
//  Created by Keith Irwin on 10/17/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

final class ToolBarVC: NSViewController {

    enum Style {
        case top, bottom
    }

    private let stack = NSStackView()
    private var style: Style = .top

    convenience init(style: Style) {
        self.init(nibName: nil, bundle: nil)
        self.style = style
    }

    override func loadView() {
        stack.orientation = .horizontal
        stack.distribution = .gravityAreas
        stack.alignment = .centerY
        stack.edgeInsets = NSEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let line = LineView().height(1)

        switch style {
            case .bottom:
                self.view = BarView()
                    .top(subview: line)
                    .below(top: line, subview: stack)
                    .height(24)
            case .top:
                self.view = BarView()
                    .bottom(subview: line)
                    .above(bottom: line, subview: stack)
                    .height(30)
        }
    }
}

// MARK: - Public API

extension ToolBarVC {

    @discardableResult
    func space(after view: NSView, value: CGFloat) -> Self {
        guard value > 0 else { return self }
        stack.setCustomSpacing(value, after: view)
        return self
    }

    @discardableResult
    func add(button view: NSButton, in gravity: NSStackView.Gravity, spaceAfter value: CGFloat = 0) -> Self {
        view.bezelStyle = .roundRect
        view.font = NSFont.systemFont(ofSize: 9, weight: .regular)
        view.controlSize = .mini
        stack.addView(view, in: gravity)
        return space(after: view, value: value)
    }

    @discardableResult
    func add(label view: NSTextField, in gravity: NSStackView.Gravity, spaceAfter value: CGFloat = 0) -> Self {
        view.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        view.usesSingleLineMode = true
        stack.addView(view, in: gravity)
        return space(after: view, value: value)
    }

    @discardableResult
    func add(field view: NSTextField, in gravity: NSStackView.Gravity, spaceAfter value: CGFloat = 0) -> Self {
        view.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        view.usesSingleLineMode = true
        view.isEditable = true
        stack.addView(view, in: gravity)
        return space(after: view, value: value)
    }

    @discardableResult
    func add(picker view: NSDatePicker, in gravity: NSStackView.Gravity, spaceAfter value: CGFloat = 0) -> Self {
        view.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        view.controlSize = .small
        view.datePickerMode = .single
        view.datePickerStyle = .textField
        view.isBordered = false
        view.drawsBackground = true
        stack.addView(view, in: gravity)
        return space(after: view, value: value)
    }
}

final private class LineView: NSView {

    var borderColor: NSColor = .gridColor {
        didSet { needsDisplay = true }
    }

    override var wantsUpdateLayer: Bool {
        return true
    }

    override func updateLayer() {
        guard let layer = layer else { return }
        layer.backgroundColor = borderColor.cgColor
    }
}

final private class BarView: NSView {

    override var wantsUpdateLayer: Bool {
        return true
    }

    override func updateLayer() {
        guard let layer = layer else { return }
        layer.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
}
