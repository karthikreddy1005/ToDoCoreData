// MARK: - Core Data Helper
import UIKit
import CoreData


// MARK: - ViewController
class ViewController: UIViewController {

    private var models = [ToDoListItem]()
    private var isSortedByPriority = true

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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Toggle Sort", style: .plain, target: self, action: #selector(toggleSort))
    }

    @objc private func toggleSort() {
        isSortedByPriority.toggle()
        fetchItems()
    }

    private func fetchItems() {
        models = ToDoDataManager.shared.fetchItems(sortedByPriority: isSortedByPriority)
        tableView.reloadData()
    }

    @objc private func didTapAdd() {
        presentTaskAlert(title: "New Task", message: "Enter task details", task: nil)
    }

    private func presentTaskAlert(title: String, message: String, task: ToDoListItem?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Task name"
            textField.text = task?.name
        }
        alert.addTextField { textField in
            textField.placeholder = "Priority (1-5)"
            textField.keyboardType = .numberPad
            textField.text = task != nil ? "\(task!.priority)" : nil
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let textFields = alert.textFields,
                  let name = textFields[0].text, !name.isEmpty,
                  let priorityText = textFields[1].text, let priority = Int16(priorityText), (1...5).contains(priority) else {
                return
            }
            if let task = task {
                ToDoDataManager.shared.updateItem(task, newName: name, newPriority: Int64(priority))
            } else {
                ToDoDataManager.shared.addItem(name: name, priority: Int64(priority))
            }
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
            self?.presentTaskAlert(title: "Edit Task", message: "Update task details", task: item)
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            ToDoDataManager.shared.deleteItem(item)
            self?.fetchItems()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
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
            ? NSAttributedString(string: "\(item.name ?? "Unnamed Task") (Priority: \(item.priority))", attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.gray
            ])
            : NSAttributedString(string: "\(item.name ?? "Unnamed Task") (Priority: \(item.priority))", attributes: [
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
