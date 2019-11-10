//
//  Database.swift
//  Luddite
//
//  Created by Keith Irwin on 10/25/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Foundation
import CoreData
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Database")

class Database {

    private var app: AppDelegate!

    init(_ app: AppDelegate) {
        self.app = app
    }

    func commit() {
        os_log("%{public}s", log: logger, "Requesting a commit of recent changes.")
        app.saveAction(nil)
    }

    func newPost(title: String) {
        let context = app.persistentContainer.viewContext
        context.perform {
            let post = Post(context: context)
            post.id = UUID()
            post.dateCreated = Date()
            post.datePublished = post.dateCreated
            post.dateUpdated = post.dateCreated
            post.title = title
            post.content = "<h1>\(title)</h1>\n\n<p>When you're thinking about '\(title)' the other day...</p>"
            post.isDraft = true
            self.app.saveAction(self)
        }
    }

    func delete(post: Post) {
        let context = app.persistentContainer.viewContext
        context.perform {
            context.delete(post)
            self.app.saveAction(self)
        }
    }

    func getPostController() -> NSFetchedResultsController<Post> {
        let context = app.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try controller.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        return controller
    }
}
