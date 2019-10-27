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

    private let statusBar = ToolBarVC(style: .bottom)
    private let textView = EditingTextView()
    private let scrollView = NSScrollView()

    private let newButton = NSButton()
    private let previewButton = NSButton()

    private let position = NSTextField(wrappingLabelWithString: "...")
    private let stats = NSTextField(wrappingLabelWithString: "...")

    private var previousContentLength = -1
    private var appearanceObservation: NSKeyValueObservation?

    private var post: Post?
}

// MARK: - Editor View Lifecycle

extension EditorVC {

    override func loadView() {

        statusBar.add(label: position, in: .leading)
        statusBar.add(label: stats, in: .trailing)

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

        self.view = NSView(frame: .zero)
            .bottom(subview: statusBar.view)
            .above(bottom: statusBar.view, subview: scrollView)
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

// MARK: - Public API

extension EditorVC {
    func setContent(_ content: String) {
        textView.string = content
        textView.colorize()
    }

    func setPost(_ post: Post?) {
        if post == self.post {
            //os_log("%{public}s", log: logger, "Replacing post with identical post.")
            self.post = post // pick up other metadata changes?
            if let txt = post?.content {
                if txt != textView.string {
                    textView.string = txt
                    textView.colorize()
                }
            }
            return
        }

        if let post = post {
            os_log("%{public}s", log: logger, "Editor: setting new post.")
            self.post = post
            textView.string = post.content ?? ""
            textView.colorize()
            return
        }
        os_log("%{public}s", log: logger, "Editor: clearing post.")
        textView.string = ""
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
        post?.content = textView.string
        Environment.database?.commit()
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        if textView.selectedRange().length < 1 {
            setPosition()
        }
    }

    func textDidChange(_ notification: Notification) {
        post?.content = textView.string
        setStats()

        guard let container = textView.textContainer else { return }
        guard let textStorage = textView.textStorage else { return }
        guard let layoutManager = textView.layoutManager else { return }

        let glyphRange = layoutManager.glyphRange(forBoundingRect: scrollView.documentVisibleRect, in: container)
        let visibleRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        textView.colorize(text: textStorage, range: visibleRange)
    }
}
