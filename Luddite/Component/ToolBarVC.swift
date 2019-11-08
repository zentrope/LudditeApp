//
//  ToolBar.swift
//  Luddite
//
//  Created by Keith Irwin on 10/17/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class ToolBarVC: NSViewController { // Should probably be a view controller

    enum Style {
        case top, bottom
    }

    private let stack = NSStackView()
    private var style: Style

    override func loadView() {
        let view = ToolBarView(style: style)
        stack.orientation = .horizontal
        stack.distribution = .gravityAreas
        stack.alignment = .centerY
        stack.edgeInsets = NSEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        view.fill(subview: stack)
        view.height(style == .top ? 30 : 24)
        self.view = view
    }

    init(style: Style) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

class ToolBarView: NSView {

    private let style: ToolBarVC.Style

    init(style: ToolBarVC.Style) {
        self.style = style
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor

        let y = style == .top ? bounds.minY : bounds.maxY
        let start = CGPoint(x: bounds.minX, y: y)
        let end = CGPoint(x: bounds.maxX, y: y)

        ctx.beginPath()
        ctx.move(to: start)
        ctx.addLine(to: end)
        ctx.setLineWidth(1)
        ctx.setStrokeColor(NSColor.gridColor.cgColor)
        ctx.strokePath()
    }

}
