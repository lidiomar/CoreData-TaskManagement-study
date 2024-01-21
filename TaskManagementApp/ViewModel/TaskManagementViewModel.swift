//
//  ProjectViewModel.swift
//  TaskManagementApp
//
//  Created by Lidiomar Machado on 20/01/24.
//

import Foundation
import CoreData

struct TaskManagementViewModel<T> where T: NSManagedObject {
    var context: NSManagedObjectContext?
    var selectedElement: T?
    var exhibitionMode: ExhibitionMode
}
