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
    private let controlFont = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)

    convenience init(style: Style) {
        self.init(nibName: nil, bundle: nil)
        self.style = style
    }

    override func loadView() {
        stack.orientation = .horizontal
        stack.distribution = .gravityAreas
        stack.alignment = .centerY
        stack.edgeInsets = NSEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        stack.spacing = 0

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
        view.font = controlFont
        //view.controlSize = .small
        stack.addView(view, in: gravity)
        return space(after: view, value: value)
    }

    @discardableResult
    func add(label view: NSTextField, in gravity: NSStackView.Gravity, spaceAfter value: CGFloat = 0) -> Self {
        view.font = controlFont
        view.usesSingleLineMode = true
        view.isBordered = false
        view.isEditable = false
        view.isSelectable = false
        stack.addView(view, in: gravity)
        return space(after: view, value: value)
    }

    @discardableResult
    func add(field view: NSTextField, in gravity: NSStackView.Gravity, spaceAfter value: CGFloat = 0) -> Self {
        view.font = controlFont
        view.usesSingleLineMode = true
        view.isEditable = true
        stack.addView(view, in: gravity)
        return space(after: view, value: value)
    }

    @discardableResult
    func add(picker view: NSDatePicker, in gravity: NSStackView.Gravity, spaceAfter value: CGFloat = 0) -> Self {
        view.font = controlFont
        view.datePickerMode = .single
        view.datePickerStyle = .textField
        view.datePickerElements = [.yearMonthDay, .hourMinute]
        view.isBordered = false
        view.isBezeled = false
        view.drawsBackground = false

        // Picker text doesn't align properly.
        let wrap = NSView()
            .fill(subview: view, top: 3)

        stack.addView(wrap, in: gravity)
        return space(after: wrap, value: value)
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
