//
//  MainWC.swift
//  Luddite
//
//  Created by Keith Irwin on 10/17/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "MainWC")

class MainWC: NSWindowController {

    private lazy var toolbar = NSToolbar(identifier: "LudditeMainWindowToolbar")

    private let saveName = "LudditeMainWindow"
    private let newPostItem = NSToolbarItem.Identifier("newPostItem")
    private let previewPostItem = NSToolbarItem.Identifier("previewPostItem")
    private let publishSiteItem = NSToolbarItem.Identifier("publishSiteItem")

    private var controller: MainVC!

    convenience init() {
        self.init(windowNibName: "")
        self.controller = MainVC()
    }

    override func loadWindow() {
        let position = NSMakeRect(200, 200, 600, 600)
        let mask: NSWindow.StyleMask = [.closable, .resizable, .titled, .miniaturizable]
        self.window = NSWindow(contentRect: position, styleMask: mask, backing: .buffered, defer: true)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window = window else { return }
        setupToolbar()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = false
        window.contentViewController = self.controller
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName(saveName)
        window.toolbar = toolbar
    }

    private func setupToolbar() {
        toolbar.isVisible = true
        toolbar.displayMode = .iconAndLabel
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.insertItem(withItemIdentifier: .toggleSidebar, at: 0)
        toolbar.insertItem(withItemIdentifier: .flexibleSpace, at: 1)
        toolbar.insertItem(withItemIdentifier: publishSiteItem, at: 2)
        toolbar.insertItem(withItemIdentifier: .space, at: 3)
        toolbar.insertItem(withItemIdentifier: newPostItem, at: 4)
        toolbar.insertItem(withItemIdentifier: previewPostItem, at: 5)
        toolbar.delegate = self
    }

    @objc private func newButtonClicked(_ sender: NSButton) {
        controller.presentAsSheet(CreatePostVC())
    }

    @objc func previewButtonClicked(_ sender: NSButton) {
        controller.toggleEditor()
    }

    @objc func publishSiteButtonClicked(_ sender: NSButton) {
        SiteGenerator.execute(window: window)
    }
}

extension MainWC: NSToolbarDelegate {

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .flexibleSpace, publishSiteItem, .space, newPostItem, previewPostItem]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .space, .flexibleSpace, publishSiteItem, newPostItem, previewPostItem]
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return []
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        switch itemIdentifier {
            case newPostItem:
                let item = NSToolbarItem(itemIdentifier: newPostItem)
                let button = NSButton()
                button.bezelStyle = .texturedRounded
                button.image = NSImage.addButtonImage.scaled(toHeight: 13)
                button.image?.isTemplate = true
                button.imageScaling = .scaleProportionallyDown
                item.maxSize = NSMakeSize(32, 25)
                item.minSize = NSMakeSize(32, 25)
                item.view = button
                item.paletteLabel = "New Post"
                item.label = "New Post"
                item.toolTip = "New Post"
                item.target = self
                item.action = #selector(newButtonClicked(_:))
                return item
            case previewPostItem:
                let item = NSToolbarItem(itemIdentifier: previewPostItem)
                let button = NSButton()
                button.bezelStyle = .texturedRounded
                button.image = NSImage.previewButtonImage.scaled(toHeight: 13)
                button.image?.isTemplate = true
                button.imageScaling = .scaleProportionallyDown
                item.maxSize = NSMakeSize(32, 25)
                item.minSize = NSMakeSize(32, 25)
                item.view = button
                item.paletteLabel = "Editor"
                item.label = "Editor"
                item.toolTip = "Show editor"
                item.target = self
                item.action = #selector(previewButtonClicked(_:))
                return item
            case publishSiteItem:
                let item = NSToolbarItem(itemIdentifier: publishSiteItem)
                let button = NSButton()
                button.bezelStyle = .texturedRounded
                button.image = NSImage.publishButtonImage.scaled(toHeight: 16)
                button.image?.isTemplate = true
                button.imageScaling = .scaleProportionallyDown
                item.maxSize = NSMakeSize(32, 25)
                item.minSize = NSMakeSize(32, 25)
                item.view = button
                item.paletteLabel = "Publish Site"
                item.label = "Publish"
                item.toolTip = "Publish Site"
                item.target = self
                item.action = #selector(publishSiteButtonClicked(_:))
                return item
            default:
                return nil
        }
    }
}

extension MainWC: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        self.window?.saveFrame(usingName: saveName)
    }
}
