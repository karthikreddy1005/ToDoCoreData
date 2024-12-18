//
//  ViewController.swift
//  ToDo
//
//  Created by Karthik Reddy on 16/12/24.
//

import UIKit

class ViewController: UIViewController {
    
    private var models = [ToDoListItem]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchItems()
    }
    
    private func setupUI() {
        title = "To Do List"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    private func fetchItems() {
        models = ToDoDataManager.shared.fetchItems()
        tableView.reloadData()
    }
    
    @objc private func didTapAdd() {
        presentAddAlert()
    }
    
    private func presentAddAlert() {
        let alert = UIAlertController(title: "New Task", message: "Enter a task", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Task name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            ToDoDataManager.shared.addItem(name: text)
            self?.fetchItems()
        }))
        present(alert, animated: true)
    }
    
    private func presentEditAlert(for item: ToDoListItem) {
        let alert = UIAlertController(title: "Edit Task", message: "Update the task name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = item.name
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let newName = alert.textFields?.first?.text, !newName.isEmpty else { return }
            ToDoDataManager.shared.updateItem(item, newName: newName)
            self?.fetchItems()
        }))
        present(alert, animated: true)
    }
    
    private func presentActionSheet(for item: ToDoListItem) {
        let actionSheet = UIAlertController(title: "Task Actions", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Mark as \(item.isCompleted ? "Incomplete" : "Complete")", style: .default, handler: { [weak self] _ in
            ToDoDataManager.shared.toggleCompletion(for: item)
            self?.fetchItems()
        }))
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            self?.presentEditAlert(for: item)
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            ToDoDataManager.shared.deleteItem(item)
            self?.fetchItems()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
}

// MARK: - TableView DataSource and Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = models[indexPath.row]
        cell.textLabel?.attributedText = item.isCompleted
        ? NSAttributedString(string: item.name ?? "", attributes: [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.gray
        ])
        : NSAttributedString(string: item.name ?? "", attributes: [
            .foregroundColor: UIColor.black
        ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        presentActionSheet(for: item)
    }
}

