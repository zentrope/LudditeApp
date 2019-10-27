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

    private let searchField = NSSearchField()
    private let controlBar = NSStackView()

    private let scrollView = NSScrollView()
    private let tableView = NSTableView()

    private let cellID = NSUserInterfaceItemIdentifier("sidebar.cell")

    private var controller: NSFetchedResultsController<Post>?

    override func loadView() {
        setupControlBar()
        setupScrollView()
        self.view = NSView(frame: .zero)
            .bottom(subview: controlBar)
            .above(bottom: controlBar, subview: scrollView)
            .width(min: 200, max: 300)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        controller = Environment.database?.getPostController()
        controller?.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    private func setupControlBar() {
        searchField.placeholderString = "Filter"
        searchField.controlSize = .small
        searchField.focusRingType = .none
        searchField.controlSize = .small
        searchField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))

        controlBar.orientation = .horizontal
        controlBar.distribution = .gravityAreas
        controlBar.alignment = .centerY
        controlBar.addView(searchField, in: .leading)
        controlBar.edgeInsets = NSEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        controlBar.spacing = 8
        controlBar.height(24)
    }

    private func setupScrollView() {
        tableView.usesAlternatingRowBackgroundColors = false
        tableView.usesAutomaticRowHeights = false // otherwise table scrolling stutters for large sizes
        tableView.allowsMultipleSelection = false
        tableView.lineBreakMode = .byTruncatingTail
        tableView.usesSingleLineMode = true
        tableView.intercellSpacing = NSSize(width: 3, height: 2) // default 3x2
        tableView.autoresizingMask = .none
        tableView.selectionHighlightStyle = .regular
        tableView.allowsColumnSelection = false
        tableView.rowSizeStyle = .default
        tableView.headerView = nil
        tableView.selectionHighlightStyle = .sourceList
        tableView.addTableColumn(NSTableColumn(identifier: cellID))
        //tableView.sortDescriptors = [NSSortDescriptor(key: ColumnID.id.rawValue, ascending: false)]

        scrollView.documentView = tableView
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
        // gnerates a change causing this method to be invoked and the whole table to
        // be updated. The selection then causes a selectionDidChange even which attempts
        // to set the editor to the "new" content. Where do we avoid this issue?
        let selected = tableView.selectedRowIndexes
        tableView.reloadData()
        tableView.selectRowIndexes(selected, byExtendingSelection: false)
    }
}


// MARK: - Sidebar Table View Data Source

extension SidebarVC: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let c = controller else {
            os_log("%{public}s", log: logger, type: .error, "Unable to obtain a fetched results container.")
            return 0
        }
        guard let posts = c.fetchedObjects else {
            os_log("%{public}s", log: logger, type: .error, "Unable to fetch any posts.")
            return 0
        }
        return posts.count
    }
}

// MARK: - Sidebar Table View Delegate

extension SidebarVC: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var cell: CellView
        if let cached = tableView.makeView(withIdentifier: cellID, owner: self) as? CellView {
            cell = cached
        } else {
            cell = CellView(identifier: cellID)
        }

        if let post = controller?.object(at: IndexPath(item: row, section: 0)) {
            cell.stringValue = post.title ?? "..."
            return cell
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        if row == -1 {
            owner?.setPost(nil)
            return
        }

        let post = controller?.object(at: IndexPath(item: row, section: 0))
        //os_log("%{public}s", log: logger, "Setting post because selection did change.")
        owner?.setPost(post)
    }
}

final class CellView: NSView {

    private var label = NSTextField(wrappingLabelWithString: "")

    var stringValue: String = "" {
        didSet {
            label.stringValue = stringValue
        }
    }

    convenience init(identifier: NSUserInterfaceItemIdentifier) {
        self.init(frame: .zero)
        self.identifier = identifier
        label.isSelectable = false
        label.lineBreakMode = .byTruncatingTail
        label.maximumNumberOfLines = 1
        horizontal(subview: label, leading: 20, trailing: -4)
    }
}
