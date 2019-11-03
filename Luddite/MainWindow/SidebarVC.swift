//
//  SidebarVC.swift
//  Luddite
//
//  Created by Keith Irwin on 10/25/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SidebarVC")

// MARK: - Sidebar View Controller

class SidebarVC: NSViewController {

    weak var owner: MainVC?

    private var outline = Outline()
    private var outlineView = NSOutlineView()
    private let scrollView = NSScrollView()

    private var controller: NSFetchedResultsController<Post>?

    override func loadView() {
        setupScrollView()
        self.view = NSView(frame: .zero)
            .fill(subview: scrollView)
            .width(min: 200, max: 300)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        controller = Environment.database?.getPostController()
        controller?.delegate = self

        outlineView.delegate = self
        outlineView.dataSource = self

        outline.rebuild(controller!)
        outlineView.reloadData()

        if outline.headings.count > 0 {
            outlineView.expandItem(outline.headings[0])
        }
    }

    private func setupScrollView() {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("column"))
        column.maxWidth = 10000
        column.minWidth = 200
        outlineView.addTableColumn(column)
        outlineView.outlineTableColumn = column
        outlineView.allowsColumnResizing = false
        outlineView.selectionHighlightStyle = .sourceList
        outlineView.headerView = nil
        outlineView.floatsGroupRows = false // rethink this
        outlineView.rowSizeStyle = .default
        outlineView.indentationPerLevel = 16.0
        outlineView.rowHeight = 24.0
        outlineView.gridStyleMask = []
        outlineView.autoresizesOutlineColumn = false

        scrollView.documentView = outlineView
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
    }

    @objc func newPost(_ sender: Any) {
        presentAsSheet(CreatePostVC())
    }
}

// MARK: - Fetched Request Delegate

extension SidebarVC: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        // Problem: user types a character, gets saved to the managed object, which then
        // generates a change causing this method to be invoked and the whole outline to
        // be updated. The selection then causes a selectionDidChange event which attempts
        // to set the editor to the "new" content. Where do we avoid this issue?

        // Could use the finer grained callbacks for this delgate and if the "changed"
        // object is the same as the currently selected object, don't do anything. Thing
        // is, the change might be the result of a cloud event. What then?

        self.outline.rebuild(self.controller!)

        let selected = outlineView.selectedRowIndexes
        outlineView.reloadData()
        outlineView.selectRowIndexes(selected, byExtendingSelection: false)
    }
}

// MARK: - NSOutlineViewDataSource

extension SidebarVC: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        switch item {
            case nil:
                return outline.headings.count
            case let header as Outline.Header:
                return header.posts.count
            default:
                return 0
        }
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        switch item {
            case nil:
                return outline.headings[index]
            case let header as Outline.Header:
                return header.posts[index]
            default:
                return "N/A"
        }
    }
}

// MARK: - NSOutlineViewDelegate

extension SidebarVC: NSOutlineViewDelegate {

    func outlineViewSelectionDidChange(_ notification: Notification) {
        let row = outlineView.selectedRow
        if row < 0 {
            owner?.setPost(nil)
            return
        }

        if let object = outlineView.item(atRow: row) as? Post {
            owner?.setPost(object)
        } else {
            owner?.setPost(nil)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is Outline.Header
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is Outline.Header
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        switch item {
            case let header as Outline.Header:
                let id = NSUserInterfaceItemIdentifier("HeaderCell")
                if let cell = outlineView.makeView(withIdentifier: id, owner: self) as? HeadCell {
                    cell.textField?.stringValue = header.name
                    return cell
                }
                return HeadCell(identifier: id, stringValue: header.name)
            case let post as Post:
                let id = NSUserInterfaceItemIdentifier("BodyCell")
                if let cell = outlineView.makeView(withIdentifier: id, owner: self) as? BodyCell {
                    cell.textField?.stringValue = post.title ?? "untitled"
                    return cell
                }
                return BodyCell(identifier: id, stringValue: post.title ?? "untitled")
            default:
                return nil
        }
    }
}

// MARK: - Outline State Management

fileprivate struct Outline {

    struct Header: Hashable, CustomStringConvertible {

        var date: Date
        var name: String
        var posts: [Post]

        init(date: Date, posts: [Post]) {
            self.date = date
            self.posts = posts
            self.name = date.formatted(pattern: "MMMM yyyy")
        }

        // Hashable
        func hash(into hasher: inout Hasher) {
            hasher.combine(date)
        }

        // Equatable
        static func == (lhs: Outline.Header, rhs: Outline.Header) -> Bool {
            return lhs.date == rhs.date
        }

        // CustomStringConvertible
        var description: String {
            return "Header<\(hashValue)>: \(name)"
        }
    }

    var headings = [Header]()

    mutating func rebuild(_ controller: NSFetchedResultsController<Post>) {
        guard let posts = controller.fetchedObjects else { return }
        // Fetched results are in reverse date-created order.
        headings = Dictionary(grouping: posts, by: { $0.month })
            .map { Header(date: $0!, posts: $1) }
            .sorted(by: {$0.date > $1.date })
    }
}


// MARK: - Custom Table Cells

// Right now, these are the same, but eventually the body cell will be different, so I'm going to let the duplication stand until then.

fileprivate final class HeadCell: NSTableCellView {

    private let label = NSTextField(labelWithString: "Header")

    convenience init(identifier: NSUserInterfaceItemIdentifier, stringValue: String = "") {
        self.init(frame: .zero)
        self.identifier = identifier
        label.stringValue = stringValue
        self.textField = label
        horizontal(subview: label, leading: 4, trailing: -4)
    }
}

fileprivate final class BodyCell: NSTableCellView {

    private let label = NSTextField(labelWithString: "Body")

    convenience init(identifier: NSUserInterfaceItemIdentifier, stringValue: String = "") {
        self.init(frame: .zero)
        self.identifier = identifier
        label.stringValue = stringValue
        self.textField = label
        horizontal(subview: label, leading: 4, trailing: -4)
    }
}
