//
//  Project+CoreDataProperties.swift
//  TaskManagementApp
//
//  Created by Lidiomar Fernando dos Santos Machado on 06/01/24.
//
//

import Foundation
import CoreData

public class Project: NSManagedObject, Managed {
    @NSManaged public var id: UUID?
    @NSManaged public var projectDescription: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var taskRelationship: NSSet?
    
    @objc(addTaskRelationshipObject:)
    @NSManaged public func addToTaskRelationship(_ value: Task)

    @objc(removeTaskRelationshipObject:)
    @NSManaged public func removeFromTaskRelationship(_ value: Task)

    @objc(addTaskRelationship:)
    @NSManaged public func addToTaskRelationship(_ values: NSSet)

    @objc(removeTaskRelationship:)
    @NSManaged public func removeFromTaskRelationship(_ values: NSSet)
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }
}

extension Project {
    static func insert(context: NSManagedObjectContext, 
                       id: UUID?,
                       projectDescription: String?,
                       startDate: Date?,
                       endDate: Date?,
                       tasks: [Task]) -> Project {
        
        let project = Project(context: context)
        project.id = id
        project.projectDescription = projectDescription
        project.startDate = startDate
        project.endDate = endDate
        
        if !tasks.isEmpty {
            project.addToTaskRelationship(NSSet(array: tasks))
        }
        
        return project
    }
    
    static func update(project: Project,
                       withDescription description: String,
                       startDate: Date,
                       endDate: Date,
                       tasks: [Task]) {
        
        project.projectDescription = description
        project.startDate = startDate
        project.endDate = endDate
        
        if let projectTasks = project.taskRelationship?.allObjects as? [Task] {
            let addedTasks = tasks.filter { !projectTasks.contains($0) }
            let removedTasks = projectTasks.filter { !tasks.contains($0) }
            project.addToTaskRelationship(NSSet(array: addedTasks))
            project.removeFromTaskRelationship(NSSet(array: removedTasks))
        }
        
    }
}

protocol Managed {
    static var entityName: String { get }
}

extension Managed where Self: NSManagedObject {
    static var entityName: String {
        return entity().name ?? String(describing: self)
    }
}
