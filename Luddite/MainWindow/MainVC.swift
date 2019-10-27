//
//  MainVC.swift
//  Luddite
//
//  Created by Keith Irwin on 10/17/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "MainVC")

class MainVC: NSViewController {

    private lazy var sidebar = SidebarVC()
    private let splitView = SplitViewVC()

    private lazy var container = ContainerVC()

    override func loadView() {
        self.view = NSView(frame: .zero)
            .fill(subview: splitView.view)
            .minimum(width: 800, height: 600)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sidebar.owner = self
        splitView.addSplitViewItem(NSSplitViewItem(sidebarWithViewController: sidebar))
        splitView.addSplitViewItem(NSSplitViewItem(viewController: container))
    }

    func showPreview() {
        container.showPreview()
    }

    func setPost(_ post: Post?) {
        container.post = post

        guard let window = view.window else { return }
        let title = post?.title ?? "Luddite"
        var date = ""
        if let text = post?.dateCreated {
            date = " • \(text)"
        }

        window.title = "\(title)\(date)"
    }
}

fileprivate final class SplitViewVC: NSSplitViewController {

    override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        //super.splitView(splitView, canCollapseSubview: subview)
        if splitView.arrangedSubviews.count < 2 { return false }
        return subview === splitView.arrangedSubviews[0]
    }

    override func splitView(_ splitView: NSSplitView, additionalEffectiveRectOfDividerAt dividerIndex: Int) -> NSRect {
        if !splitViewItems[0].isCollapsed {
            return .zero
        }
        return NSMakeRect(0, 0, 10, splitView.bounds.height)
    }
}
