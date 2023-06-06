//
//  ViewController.swift
//  SwiftDataExample_UIKit
//
//  Created by J_Min on 2023/06/06.
//

import UIKit
import SwiftData
import Combine

let container = try? ModelContainer(for: [TodoItem.self])

class ViewController: UIViewController {
    
    @IBOutlet weak var completedSwitch: UISwitch!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let context = container?.mainContext
    var todoItems: [TodoItem] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        fetchContext()
    }
    
    func fetchContext() {
        let fetchDescriptor = FetchDescriptor<TodoItem>(sortBy: [SortDescriptor<TodoItem>(\TodoItem.title, order: .forward), SortDescriptor<TodoItem>(\TodoItem.createdAt, order: .forward)])
        self.todoItems = (try? context?.fetch(fetchDescriptor)) ?? []
        self.tableView.reloadData()
    }
    
    func clear() {
        textField.text?.removeAll()
        completedSwitch.isOn = false
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        guard let title = textField.text, !title.isEmpty else {
            return
        }
        let item = TodoItem(title: title, isCompleted: completedSwitch.isOn, createdAt: Date())
        context?.insert(item)
        fetchContext()
        clear()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoItemTableViewCell.identifier,
            for: indexPath
        ) as? TodoItemTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(todoItem: todoItems[indexPath.row])
        cell.completedHandler = { [weak self] in
            self?.todoItems[indexPath.row].isCompleted.toggle()
            self?.fetchContext()
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context?.delete(todoItems[indexPath.row])
            fetchContext()
        }
    }
}

final class TodoItemTableViewCell: UITableViewCell {
    static let identifier = "TodoItemTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var isCompletedButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var completedHandler: (() -> Void)?
    
    func configureCell(todoItem: TodoItem) {
        titleLabel.text = todoItem.title
        dateLabel.text = todoItem.createdAt.toString()
        isCompletedButton.setTitle("", for: .normal)
        isCompletedButton.layer.borderColor = UIColor.lightGray.cgColor
        isCompletedButton.layer.borderWidth = 1
        isCompletedButton.layer.cornerRadius = 15
        if todoItem.isCompleted {
            isCompletedButton.backgroundColor = .blue
        } else {
            isCompletedButton.backgroundColor = .clear
        }
    }
    
    @IBAction func isCompletedButtonAction(_ sender: Any) {
        completedHandler?()
    }
}
