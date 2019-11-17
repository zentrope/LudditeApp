//
//  EditorVC.swift
//  Luddite
//
//  Created by Keith Irwin on 10/26/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "EditorVC")

class EditingTextView: NSTextView {

    override func paste(_ sender: Any?) {
        super.paste(sender)
        self.colorize()
    }
}

class EditorVC: NSViewController {

    // Top
    private let titleField = NSTextField(wrappingLabelWithString: "")
    private let draftCheck = NSButton()
    private let draftLabel = NSTextField(labelWithString: " Draft?")
    private let pickerLabel = NSTextField(labelWithString: "Posted:")
    private let picker = NSDatePicker()

    // Middle
    private let textView = EditingTextView()
    private let scrollView = NSScrollView()

    // Bottom
    private let createdField = NSTextField(labelWithString: "Date Created")
    private let createdLabel = NSTextField(labelWithString: "Created: ")
    private let updatedField = NSTextField(labelWithString: "…")
    private let updatedLabel = NSTextField(labelWithString: "Updated: ")
    private let position = NSTextField(wrappingLabelWithString: "…")
    private let stats = NSTextField(wrappingLabelWithString: "…")

    private var previousContentLength = -1
    private var appearanceObservation: NSKeyValueObservation?

    private var post: Post?
}

// MARK: - Editor View Lifecycle

extension EditorVC {

    override func loadView() {

        setupTextView()

        draftCheck.setButtonType(.switch)
        draftCheck.imagePosition = .imageOnly
        draftCheck.target = self
        draftCheck.action = #selector(draftStatusChanged(_:))

        titleField.placeholderString = "Post title"
        titleField.width(min: 200)
        titleField.delegate = self

        draftLabel.textColor = .controlAccentColor
        createdField.textColor = .controlAccentColor
        updatedField.textColor = .controlAccentColor
        pickerLabel.textColor = .controlAccentColor

        picker.dateValue = Date()
        picker.target = self
        picker.action = #selector(pubDateChanged(_:))
        picker.toolTip = "Set the post's date as it will appear when published."

        let updateBar = ToolBarVC(style: .top)
            // .setSize(.regular)
            .add(field: titleField, in: .leading, spaceAfter: 20)
            .add(button: draftCheck, in: .leading, spaceAfter: 4)
            .add(label: draftLabel, in: .trailing, spaceAfter: 20)
            .add(label: pickerLabel, in: .trailing)
            .add(picker: picker, in: .trailing, spaceAfter: 20)

        let statusBar = ToolBarVC(style: .bottom)
            .add(label: position, in: .leading)
            .add(label: createdLabel, in: .center)
            .add(label: createdField, in: .center, spaceAfter: 20)
            .add(label: updatedLabel, in: .center)
            .add(label: updatedField, in: .center)
            .add(label: stats, in: .trailing)

        titleField.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        self.view = NSView(frame: .zero)
            .top(subview: updateBar.view)
            .bottom(subview: statusBar.view)
            .between(top: updateBar.view, subview: scrollView, bottom: statusBar.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPosition()
        setStats()

        textView.textStorage?.delegate = self
        appearanceObservation = textView.observe(\.effectiveAppearance, options: []) { [weak self] (_, _) in
            self?.textView.colorize()
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        appearanceObservation = nil
        os_log("%{public}s", log: logger, type: .debug, "View disappeared.")
        Environment.database?.commit()
    }
}

// MARK: - NSTextFieldDelegate (& actions)

extension EditorVC: NSTextFieldDelegate {

    @objc private func draftStatusChanged(_ sender: NSButton) {
        post?.isDraft = sender.state == .on
        post?.dateUpdated = Date()
    }

    @objc private func pubDateChanged(_ sender: NSDatePicker) {
        post?.datePublished = sender.dateValue
        post?.dateUpdated = Date()
    }

    func controlTextDidChange(_ notification: Notification) {
        if (notification.object as? NSTextField) == titleField {
            post?.title = titleField.stringValue
            post?.dateUpdated = Date()
        }
    }
}

// MARK: - UI Configuration

extension EditorVC {

    private func setupTextView() {
        textView.isEditable = true
        textView.isRichText = false
        textView.textContainerInset = NSMakeSize(20, 20)
        textView.autoresizingMask = [.width, .height]
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.allowsUndo = true
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.delegate = self

        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
    }
}

// MARK: - Public API

extension EditorVC {

    func setPost(_ post: Post?) {

        // A request to set the post to the one we're already editing.
        if post == self.post {

            // Assign it anyway: voodoo.
            self.post = post // Does this pick up other metadata changes?

            // If the content of the post has changed, that means the cloud
            // updated it, so (for now) just replace it.
            if let txt = post?.content {
                if txt != textView.string {
                    textView.string = txt
                    textView.colorize()
                }
            }
            // At least update the date as that has probably changed.
            updateMetadata()
            return
        }

        if let post = post {
            os_log("%{public}s", log: logger, "Editor: setting new post.")
            self.post = post
            textView.string = post.content ?? ""
            textView.colorize()
            updateMetadata()
            return
        }
        os_log("%{public}s", log: logger, "Editor: clearing post.")
        textView.string = ""
    }

    private func updateMetadata() {
        guard let post = self.post else { return }

        titleField.stringValue = post.title ?? ""
        createdField.stringValue = post.dateCreated?.formatted(pattern: "MMM dd, yyyy") ?? "..."
        updatedField.stringValue = post.dateUpdated?.formatted(pattern: "MMM dd, yyyy @ hh:mm:ss") ?? "..."
        draftCheck.state = post.isDraft ? .on : .off

        if let pubDate = post.datePublished {
            picker.dateValue = pubDate
        } else {
            picker.dateValue = Date.init(timeIntervalSinceNow: 60 * 60)
        }
    }
}

// MARK: - Editor View Implementation

extension EditorVC {

    private func setPosition() {
        guard let textStorage = textView.textStorage else {
            position.stringValue = "..."
            return
        }

        let range = textView.selectedRange()
        let string = textStorage.string

        DispatchQueue.global().async {
            let text = string as NSString

            let lineRange = text.lineRange(for: range)
            let col = range.location - lineRange.location + 1

            let uptoText = text.substring(to: range.location)
            var lines = uptoText.count == 0 ? 1 : 0
            uptoText.enumerateLines { (_, _) in
                lines += 1
            }
            if uptoText.hasSuffix("\n") {
                lines += 1
            }

            DispatchQueue.main.async {
                self.position.stringValue = "L: \(lines) C: \(col)"
            }
        }
    }

    private func setStats() {
        guard let textStorage = textView.textStorage else {
            stats.stringValue = "..."
            return
        }

        let s = textStorage.string
        if s.count == previousContentLength {
            return
        }
        previousContentLength = s.count

        DispatchQueue.global().async {
            let words = s.components(separatedBy: .whitespacesAndNewlines).filter { $0.isEmpty }.count
            let chars = s.count
            var lines = 0
            (s as NSString).enumerateLines { (_, _) in lines += 1 }
            lines += s.count == 0 ? 1 : 0
            lines += s.hasSuffix("\n") ? 1 : 0
            DispatchQueue.main.async {
                self.stats.stringValue = "\(chars) / \(words) / \(lines)"
            }
        }
    }

    private func updatePost() {
        post?.content = textView.string
        post?.dateUpdated = Date()
        if post?.datePublished == nil {
            post?.datePublished = post?.dateCreated
        }
        if post?.isDraft == nil {
            post?.isDraft = true
        }
    }
}

// MARK: - NSTextStorageDelegate (unused)

extension EditorVC: NSTextStorageDelegate {
    // https://stackoverflow.com/q/8854688

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {

    }
}

// MARK: - NSTextViewDelegate

extension EditorVC: NSTextViewDelegate {

    func textDidEndEditing(_ notification: Notification) {
        updatePost()
        Environment.database?.commit()
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        if textView.selectedRange().length < 1 {
            setPosition()
        }
    }

    func textDidChange(_ notification: Notification) {
        updatePost()
        setStats()

        guard let container = textView.textContainer else { return }
        guard let textStorage = textView.textStorage else { return }
        guard let layoutManager = textView.layoutManager else { return }

        let glyphRange = layoutManager.glyphRange(forBoundingRect: scrollView.documentVisibleRect, in: container)
        let visibleRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        textView.colorize(text: textStorage, range: visibleRange)
    }
}
