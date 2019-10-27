//
//  Database.swift
//  Luddite
//
//  Created by Keith Irwin on 10/25/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Foundation
import CoreData

class Database {

    private var app: AppDelegate!

    init(_ app: AppDelegate) {
        self.app = app
    }

    func commit() {
        app.saveAction(nil)
    }

    func newPost(title: String) {
        let context = app.persistentContainer.viewContext
        context.perform {
            let post = Post(context: context)
            post.id = UUID()
            post.dateCreated = Date()
            post.title = title
            post.content = "<h1>\(title)</h1>\n\n<p>When you're thinking about '\(title)' the other day...</p>"
            self.app.saveAction(self)
        }
    }

    func fetchPosts(_ completion: @escaping (Result<[Post],Error>) -> Void) {
        let context = app.persistentContainer.viewContext
        context.perform {
            do {
                let request: NSFetchRequest<Post> = Post.fetchRequest()
                let posts = try context.fetch(request)
                completion(Result.success(posts))
            } catch {
                completion(Result.failure(error))
            }
        }
    }

    func getPostController() -> NSFetchedResultsController<Post> {
        let context = app.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try controller.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        return controller
    }
}
