//
//  Comment+CoreDataProperties.swift
//  TaskManagementApp
//
//  Created by Lidiomar Fernando dos Santos Machado on 06/01/24.
//
//

import Foundation
import CoreData


public class Comment: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var commentDescription: String?
    @NSManaged public var taskRelationship: Task?

}

extension Comment : Identifiable {

}
