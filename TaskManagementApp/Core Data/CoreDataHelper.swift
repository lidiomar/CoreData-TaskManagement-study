//
//  CoreDataHelpers.swift
//  TaskManagementApp
//
//  Created by Lidiomar Fernando dos Santos Machado on 06/01/24.
//

import CoreData

extension NSPersistentContainer {
    static func load(modelName: String) throws -> NSPersistentContainer  {
        let persistentContainer = NSPersistentContainer(name: modelName)
        var error: Swift.Error?
        
        persistentContainer.loadPersistentStores { error = $1 }
        
        try error.map { throw $0 }
        return persistentContainer
    }
}

extension NSManagedObjectContext {
    func performFetch<T>(request: NSFetchRequest<T>) -> [T] {
        performAndWait {
            do {
                let results = try fetch(request)
                return results
            } catch {
                return []
            }
        }
    }
    
    func performChanges(block: ()->()) {
        performAndWait {
            block()
            saveOrRollback()
        }
    }
    
    func saveOrRollback() {
        do {
            try save()
        } catch {
            print(error)
            rollback()
        }
    }
}
