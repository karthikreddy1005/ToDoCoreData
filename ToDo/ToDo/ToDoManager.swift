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
    
    func fetchItems() -> [ToDoListItem] {
        do {
            let items = try context.fetch(ToDoListItem.fetchRequest())
            return items
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }
    
    func addItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.isCompleted = false
        newItem.createdAt = Date()
        saveContext()
    }
    
    func deleteItem(_ item: ToDoListItem) {
        context.delete(item)
        saveContext()
    }
    
    func updateItem(_ item: ToDoListItem, newName: String) {
        item.name = newName
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

