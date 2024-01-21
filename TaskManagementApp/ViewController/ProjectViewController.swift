//
//  AddTaskViewController.swift
//  TaskManagementApp
//
//  Created by Lidiomar Machado on 20/01/24.
//

import UIKit
import CoreData

class ProjectViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var projectDescription: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private let modelName = "TaskManagementDataModel"
    private let cellIdentifier = "cell"
    private var tasks: [Task] = [Task]()
    var viewModel: TaskManagementViewModel<Project>?
    var selectedTask: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewWith(viewModel?.selectedElement)
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedTask = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addTaskViewController = segue.destination as? TaskViewController else {
            return
        }
        
        addTaskViewController.delegate = self
        addTaskViewController.viewModel = TaskManagementViewModel(context: viewModel?.context,
                                                                  selectedElement: selectedTask,
                                                                  exhibitionMode: selectedTask == nil ? .create : .update)
    }
    
    //MARK: Actions
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addTask", sender: self)
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard 
            let context = viewModel?.context,
            let exhibitionMode = viewModel?.exhibitionMode
        else {
            return
        }
        
        switch exhibitionMode {
        case .create:
            context.performChanges {
                _ = Project.insert(context: context,
                                   id: UUID(),
                                   projectDescription: projectDescription.text,
                                   startDate: startDate.date,
                                   endDate: startDate.date,
                                   tasks: tasks)
            }
        case .update:
            if let project = viewModel?.selectedElement {
                context.performChanges {
                    Project.update(project: project,
                                   withDescription: projectDescription.text ?? "",
                                   startDate: startDate.date,
                                   endDate: startDate.date,
                                   tasks: tasks)
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}

private extension ProjectViewController {
    func configureViewWith(_ project: Project?) {
        switch viewModel?.exhibitionMode {
        case .create:
            saveButton.setTitle("Save", for: .normal)
        case .update:
            saveButton.setTitle("Update", for: .normal)
        default:
            saveButton.setTitle("", for: .normal)
        }
        
        projectDescription.text = project?.projectDescription
        startDate.date = project?.startDate ?? .now
        endDate.date = project?.endDate  ?? .now
        
        if let projectTasks = project?.taskRelationship?.allObjects as? [Task] {
            tasks = projectTasks
        }
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ProjectViewController: AddTaskViewControllerDelegate {
    func returnTask(task: Task, exhibitionMode: ExhibitionMode) {
        switch exhibitionMode {
        case .create:
            tasks.append(task)
            tableView.reloadData()
        case .update:
            if let index = tasks.firstIndex(where: { $0.taskDescription == task.taskDescription }) {
                tasks[index].taskDescription = task.taskDescription
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
}

//MARK: TableView delegate
extension ProjectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTask = tasks[indexPath.row]
        performSegue(withIdentifier: "addTask", sender: self)
    }
}

//MARK: TableView datasource
extension ProjectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = task.taskDescription ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}
