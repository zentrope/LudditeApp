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
    private var post: Post?

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

    func set(post: Post?) {
        let prev = self.post
        self.post = post
        if post == nil {
            showEmpty()
        } else if post?.id != prev?.id {
            showPreview()
        } else if currentViewController == preview {
            preview.load(post?.content)
        } else if currentViewController == editor {
            editor.setPost(post)
        }
    }

    func toggleEditorPreview() {
        if currentViewController == empty {
            return
        }
        if currentViewController == preview {
            showEditor()
        } else {
            showPreview()
        }
    }

    private func showPreview() {
        preview.load(post?.content)
        transition(to: preview)
    }

    private func showEditor() {
        editor.setPost(post)
        transition(to: editor)
    }

    private func showEmpty() {
        transition(to: empty)
    }

    private func transition(to: NSViewController) {
        guard let current = currentViewController else { return }
        guard to.view.superview != self.view else { return }
        transition(from: current, to: to, options: []) {
            self.currentViewController = to
            to.view.superview?.fill(subview: to.view)
        }
    }
}

