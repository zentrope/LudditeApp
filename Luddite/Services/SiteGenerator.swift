//
//  SiteGenerator.swift
//  Luddite
//
//  Created by Keith Irwin on 11/16/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SiteGenerator")

struct SiteGenerator {

    static func execute(window: NSWindow?) {
        guard let window = window else { return }
        askForDirectory(window: window) { result in
            switch result {
                case let .success(url):
                    os_log("%{public}s", log: logger, "Created site directory at '\(url)'.")
                    window.alert(message: "Generating site for not implemented (but dir was created).")
                case let .failure(error):
                    os_log("%{public}s", log: logger, type: .error, error.localizedDescription)
                    window.presentError(error)
            }
        }
    }

    private static func askForDirectory(window: NSWindow, _ completion: @escaping (Result<URL, Error>) -> Void) {
        let fileManager = FileManager.default

        let panel = NSOpenPanel()

        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        panel.title = "Generate Site"
        panel.message = "Pick the folder in which you want to generate the site folder."
        panel.prompt = "Generate"

        panel.beginSheetModal(for: window) { response in
            guard response == .OK else { return }
            guard let url = panel.urls.first else { return }
            do {
                let siteUrl = url.appendingPathComponent(dirName())
                try fileManager.createDirectory(at: siteUrl, withIntermediateDirectories: false, attributes: [:])
                completion(Result.success(siteUrl))
            }

            catch {
                completion(Result.failure(error))
            }
        }
    }

    private static func dirName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh-mm-ss SSSSS"
        let dateString = dateFormatter.string(from: Date())
        return "\(Preferences.siteTitle) \(dateString)"
    }

    private static func dirURL(dirName: String) -> URL {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent(dirName)
    }
}
