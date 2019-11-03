//
//  ContainerVC.swift
//  Luddite
//
//  Created by Keith Irwin on 10/27/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ContainerVC")

final class ContainerVC: NSViewController {

    private lazy var editor = EditorVC()
    private lazy var empty = EmptyVC()
    private lazy var preview = PreviewVC()

    private var currentViewController: NSViewController?

    var post: Post? {
        didSet {
            updateView()
        }
    }

    override func loadView() {
        self.view = NSView(frame: .zero)
            .fill(subview: empty.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(empty)
        addChild(editor)
        addChild(preview)
        currentViewController = empty
    }

    private func updateView() {
        if post == nil {
            os_log("%{public}s", log: logger, type: .debug, "Post is nil, showing empty view")
            showEmpty()
            return
        }

        if post != nil && currentViewController == empty {
//            os_log("%{public}s", log: logger, type: .debug, "Post is present, view is empty, so showing editor")
            showEditor()
            return
        }

        if post != nil && currentViewController == editor {
//            os_log("%{public}s", log: logger, type: .debug, "Post and showing editor, so set post in editor")
            editor.setPost(post)
            return
        }

        if post != nil && currentViewController == preview {
//            os_log("%{public}s", log: logger, type: .debug, "post and preview, so load preview")
            preview.load(post?.content)
        }
    }

    /// FIXME: These show methods can be generic.
    func showPreview() {
        if currentViewController == preview {
            showEditor()
            return
        }
        preview.load(post?.content)
        guard let current = currentViewController else { return }
        guard preview.view.superview != self.view else { return }
        transition(from: current, to: preview, options: []) {
            self.currentViewController = self.preview
            self.preview.view.superview?.fill(subview: self.preview.view)
        }
    }

    private func showEditor() {
        guard let current = currentViewController else { return }
        editor.setPost(post)
        if current != editor {
            transition(from: current, to: editor, options: []) {
                self.currentViewController = self.editor
                self.editor.view.superview?.fill(subview: self.editor.view)
            }
        }
    }

    private func showEmpty() {
        guard let current = currentViewController else { return }
        guard current != empty else { return }
        transition(from: current, to: empty, options: []) {
            self.currentViewController = self.empty
            self.empty.view.superview?.fill(subview: self.empty.view)
        }
    }
}

