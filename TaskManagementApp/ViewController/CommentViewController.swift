//
//  CommentViewController.swift
//  TaskManagementApp
//
//  Created by Lidiomar Machado on 20/01/24.
//

import UIKit
import CoreData

protocol CommentViewControllerDelegate: AnyObject {
    func returnComment(comment: Comment, exhibitionMode: ExhibitionMode)
}

class CommentViewController: UIViewController {
    @IBOutlet weak var comment: UITextField!
    weak var delegate: CommentViewControllerDelegate?
    @IBOutlet weak var saveButton: UIButton!
    var viewModel: TaskManagementViewModel<Comment>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView(with: viewModel?.selectedElement)
    }
    
    @IBAction func addComment(_ sender: UIButton) {
        guard let context = viewModel?.context else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        switch viewModel?.exhibitionMode {
        case .create:
            let commentObject = Comment(context: context)
            commentObject.commentDescription = comment.text
            delegate?.returnComment(comment: commentObject, exhibitionMode: .create)
        case .update:
            guard let selectedComment = viewModel?.selectedElement else {
                return
            }
            selectedComment.commentDescription = comment.text
            delegate?.returnComment(comment: selectedComment, exhibitionMode: .update)
        case nil:
            break
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

private extension CommentViewController {
    func configureView(with selectedComment: Comment?) {
        switch viewModel?.exhibitionMode {
        case .create:
            saveButton.setTitle("Save", for: .normal)
        case .update:
            saveButton.setTitle("Update", for: .normal)
        case nil:
            break
        }
        
        guard let selectedComment = selectedComment else { return }
        comment.text = selectedComment.commentDescription
    }
}
