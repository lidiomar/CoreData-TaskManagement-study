//
//  ViewController.swift
//  TaskManagementApp
//
//  Created by Lidiomar Fernando dos Santos Machado on 06/01/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Private attributes
    private var context: NSManagedObjectContext?
    private var fetchedResultsController: NSFetchedResultsController<Project>?
    private var selectedProject: Project?
    private let modelName = "TaskManagementDataModel"
    private let cellIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sqliteLocation()
        configureContext()
        loadData()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedProject = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addProjectViewController = segue.destination as? ProjectViewController else {
            return
        }
        
        addProjectViewController.viewModel = TaskManagementViewModel(context: self.context,
                                                              selectedElement: selectedProject,
                                                              exhibitionMode: (selectedProject == nil) ? .create : .update)
    }
    
    @IBAction func addProject(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showProject", sender: self)
    }
}

//MARK: Private extension
private extension ViewController {
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureContext() {
        do {
            let container = try NSPersistentContainer.load(modelName: modelName)
            context = container.viewContext
        } catch {
            print("The persistent container has not been loaded.")
            return
        }
    }
    
    private func delete(project: Project) {
        guard let context = context else { return }
        context.performChanges {
            context.delete(project)
        }
    }
    
    private func loadData() {
        guard let context = context else { return }
        let request = Project.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "projectDescription", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error fetching projects")
        }
    }
    
    private func sqliteLocation() {
        if let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            print("SQLite folder path: \(appSupportURL)")
        }
    }
}

//MARK: TableView datasource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let project = fetchedResultsController?.object(at: indexPath) else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = project.projectDescription ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let project = fetchedResultsController?.object(at: indexPath) else {
                return
            }
            delete(project: project)
        }
    }
}

//MARK: TableView delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let project = fetchedResultsController?.object(at: indexPath) else {
            return
        }
        selectedProject = project
        performSegue(withIdentifier: "showProject", sender: self)
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
