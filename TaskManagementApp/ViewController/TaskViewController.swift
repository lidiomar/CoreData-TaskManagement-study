//
//  AddTaskViewController.swift
//  TaskManagementApp
//
//  Created by Lidiomar Machado on 20/01/24.
//

import UIKit
import CoreData

protocol AddTaskViewControllerDelegate: AnyObject {
    func returnTask(task: Task, exhibitionMode: ExhibitionMode)
}

class TaskViewController: UIViewController {
    private var comments: [Comment] = [Comment]()
    private var cellIdentifier = "cell"
    weak var delegate: AddTaskViewControllerDelegate?
    var viewModel: TaskManagementViewModel<Task>?
    var selectedComment: Comment?
    
    //MARK: Outlets
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var taskDescription: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView(with: viewModel?.selectedElement)
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedComment = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let commentViewController = segue.destination as? CommentViewController else {
            return
        }
        let exhibitionMode: ExhibitionMode = selectedComment == nil ? .create : .update
        commentViewController.delegate = self
        commentViewController.viewModel = TaskManagementViewModel(context: viewModel?.context,
                                                                  selectedElement: selectedComment,
                                                                  exhibitionMode: exhibitionMode)
    }
    
    @IBAction func save() {
        switch viewModel?.exhibitionMode {
        case .create:
            guard let context = viewModel?.context else { return }
            let task = Task(context: context)
            task.taskDescription = taskDescription.text
            task.addToCommentRelationship(NSSet(array: comments))
            self.delegate?.returnTask(task: task, exhibitionMode: .create)
        case .update:
            guard let task = viewModel?.selectedElement else { return }
            task.taskDescription = taskDescription.text
            task.commentRelationship = NSSet(array: comments)
            self.delegate?.returnTask(task: task, exhibitionMode: .update)
        case nil:
            break
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Actions
    @IBAction func addComment(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addComment", sender: self)
    }
}

private extension TaskViewController {
    func configureView(with task: Task?) {
        if task != nil {
            addButton.setTitle("Update", for: .normal)
        } else {
            addButton.setTitle("Save", for: .normal)
        }
        
        taskDescription.text = task?.taskDescription
        comments = task?.commentRelationship?.allObjects as? [Comment] ?? []
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

//MARK: TableView datasource
extension TaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let comment = comments[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = comment.commentDescription
        return cell
    }
}

//MARK: TableView delegate
extension TaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedComment = comments[indexPath.row]
        performSegue(withIdentifier: "addComment", sender: self)
    }
}

extension TaskViewController: CommentViewControllerDelegate {
    func returnComment(comment: Comment, exhibitionMode: ExhibitionMode) {
        switch exhibitionMode {
        case .create:
            comments.append(comment)
            tableView.reloadData()
        case .update:
            if let index = comments.firstIndex(where: { $0.commentDescription == comment.commentDescription }) {
                comments[index].commentDescription = comment.commentDescription
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
}
