//
//  ToDoManager.swift
//  ToDo
//
//  Created by Karthik Reddy on 18/12/24.
//

import Foundation
import UIKit
import CoreData

class ToDoDataManager {
    static let shared = ToDoDataManager()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func fetchItems(sortedByPriority: Bool = false) -> [ToDoListItem] {
        let fetchRequest: NSFetchRequest<ToDoListItem> = ToDoListItem.fetchRequest()
        fetchRequest.sortDescriptors = sortedByPriority
            ? [NSSortDescriptor(key: "priority", ascending: false)]
            : [NSSortDescriptor(key: "createdAt", ascending: true)]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }

    func addItem(name: String, priority: Int64) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.isCompleted = false
        newItem.createdAt = Date()
        newItem.priority = priority
        saveContext()
    }

    func deleteItem(_ item: ToDoListItem) {
        context.delete(item)
        saveContext()
    }

    func updateItem(_ item: ToDoListItem, newName: String, newPriority: Int64) {
        item.name = newName
        item.priority = newPriority
        saveContext()
    }

    func toggleCompletion(for item: ToDoListItem) {
        item.isCompleted.toggle()
        saveContext()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
