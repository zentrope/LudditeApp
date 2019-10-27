//
//  CreatePostVC.swift
//  Luddite
//
//  Created by Keith Irwin on 10/25/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class CreatePostVC: NSViewController {

    private let save = NSButton()
    private let cancel = NSButton()

    private let titleField = NSTextField(string: "")
    private let titleLabel = NSTextField(labelWithString: "Title:")

    override func loadView() {
        let view = NSView(frame: .zero)

        titleField.placeholderString = "New post title"

        save.title = "Create"
        save.bezelStyle = .rounded
        save.keyEquivalent = "\r"
        save.isHighlighted = true
        save.target = self
        save.action = #selector(buttonClicked(_:))

        cancel.title = "Cancel"
        cancel.bezelStyle = .rounded
        cancel.keyEquivalent = "\u{1b}"
        cancel.target = self
        cancel.action = #selector(buttonClicked(_:))

        let controls = NSStackView()
        controls.orientation = .horizontal
        controls.alignment = .centerY
        controls.distribution = .gravityAreas
        controls.spacing = 10

        controls.addView(cancel, in: .trailing)
        controls.addView(save, in: .trailing)

        let empty = NSGridCell.emptyContentView
        let grid = NSGridView()
        grid.rowSpacing = 20
        grid.addRow(with: [titleLabel, titleField])
        grid.addRow(with: [empty, controls])
        //grid.mergeCells(inHorizontalRange: NSMakeRange(0, 1), verticalRange: NSMakeRange(1, 1))
        grid.yPlacement = .center
        grid.column(at: 0).width = 40
        grid.cell(for: titleLabel)?.xPlacement = .trailing
        grid.cell(for: controls)?.xPlacement = .trailing
        grid.width(min: 300, max: 700)

        view.fill(subview: grid, withMargins: 20)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Prevent sheet resizing
        view.height(view.frame.height)
    }

    enum FooError: Error, LocalizedError {
        case noTitle

        var errorDescription: String? {
            switch self {
                case .noTitle:
                    return "Post requires a title"
            }
        }

        var failureReason: String? {
            return "failure: " + errorDescription!
        }

        var recoverySuggestion: String? {
            switch self {
                case .noTitle:
                    return "Provide a title, even if it won't show up when published. It's useful for the sidebar."
            }
        }
    }

    @objc private func buttonClicked(_ sender: NSButton) {
        switch sender {
            case save:
                let title = titleField.stringValue
                if title.count < 1 {
                    self.presentError(FooError.noTitle)
                } else {
                    Environment.database?.newPost(title: title)
                    self.dismiss(self)
                }
            case cancel:
                self.dismiss(self)
            default:
                break
        }
    }
}
