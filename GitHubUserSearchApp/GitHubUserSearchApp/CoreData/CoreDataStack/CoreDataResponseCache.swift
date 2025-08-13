//
//  CoreDataResponseCache.swift
//  GitHubUserSearchApp
//
//  Created by Md Mozammil on 13/08/25.
//


import Foundation
import CoreData

protocol ResponseCacheStore {
    func read(for key: String) -> (data: Data, timestamp: Date)?
    func write(_ data: Data, for key: String)
    func delete(for key: String)
}

final class CoreDataResponseCache: ResponseCacheStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func read(for key: String) -> (data: Data, timestamp: Date)? {
        let req: NSFetchRequest<CacheResponse> = CacheResponse.fetchRequest()
        req.predicate = NSPredicate(format: "key == %@", key)
        req.fetchLimit = 1
        guard let obj = try? context.fetch(req).first,
              let data = obj.data, let ts = obj.timestamp else { return nil }
        return (data, ts)
    }

    func write(_ data: Data, for key: String) {
        // Upsert
        let req: NSFetchRequest<CacheResponse> = CacheResponse.fetchRequest()
        req.predicate = NSPredicate(format: "key == %@", key)
        req.fetchLimit = 1

        let obj = (try? context.fetch(req).first) ?? CacheResponse(context: context)
        obj.key = key
        obj.data = data
        obj.timestamp = Date()
        try? context.save()
    }

    func delete(for key: String) {
        let req: NSFetchRequest<NSFetchRequestResult> = CacheResponse.fetchRequest()
        req.predicate = NSPredicate(format: "key == %@", key)
        let delete = NSBatchDeleteRequest(fetchRequest: req)
        _ = try? context.execute(delete)
    }
}

struct CacheKey {
    static func from(url: URL) -> String { url.absoluteString }
    // If needed later: include auth scope, language, etc.
}
