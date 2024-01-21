//
//  Task+CoreDataProperties.swift
//  TaskManagementApp
//
//  Created by Lidiomar Fernando dos Santos Machado on 06/01/24.
//
//

import Foundation
import CoreData


public class Task: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var taskDescription: String?
    @NSManaged public var projectRelationship: Project?
    @NSManaged public var commentRelationship: NSSet?

}

// MARK: Generated accessors for commentRelationship
extension Task {

    @objc(addCommentRelationshipObject:)
    @NSManaged public func addToCommentRelationship(_ value: Comment)

    @objc(removeCommentRelationshipObject:)
    @NSManaged public func removeFromCommentRelationship(_ value: Comment)

    @objc(addCommentRelationship:)
    @NSManaged public func addToCommentRelationship(_ values: NSSet)

    @objc(removeCommentRelationship:)
    @NSManaged public func removeFromCommentRelationship(_ values: NSSet)

}

extension Task : Identifiable {

}
