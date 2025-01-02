//
//  Notify.swift
//  EventGuru02
//
//  Created by Ali Juma on 02/01/2025.
//

import UIKit
import Firebase

class Notify: UIViewController {
    let db = Firestore.firestore()
    
    @IBOutlet weak var Like: UIImageView!
    @IBOutlet weak var Dislike: UIImageView!
    @IBOutlet weak var BookMark: UIImageView!
    @IBOutlet weak var ReportIcon: UIImageView!
    
    var isThumbsUpFilled = false
    var isDislikeFilled = false
    var isBookmarkFilled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Like (thumbs up) image and gesture
        Like.image = UIImage(systemName: "hand.thumbsup")
        Like.isUserInteractionEnabled = true
        let likeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLikeTap))
        Like.addGestureRecognizer(likeTapGestureRecognizer)
        
        // Initialize Dislike image and gesture
        Dislike.image = UIImage(systemName: "hand.thumbsdown")
        Dislike.isUserInteractionEnabled = true
        let dislikeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDislikeTap))
        Dislike.addGestureRecognizer(dislikeTapGestureRecognizer)
        
        // Initialize Bookmark image and gesture
        BookMark.image = UIImage(systemName: "bookmark")
        BookMark.isUserInteractionEnabled = true
        let bookmarkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBookmarkTap))
        BookMark.addGestureRecognizer(bookmarkTapGestureRecognizer)
        
        // Initialize ReportIcon gesture
        ReportIcon.isUserInteractionEnabled = true
        let reportTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reportIconTapped))
        ReportIcon.addGestureRecognizer(reportTapGestureRecognizer)
    }
    
    @objc func handleLikeTap() {
        isThumbsUpFilled.toggle()
        Like.image = UIImage(systemName: isThumbsUpFilled ? "hand.thumbsup.fill" : "hand.thumbsup")
        
        if isThumbsUpFilled {
            // If Like is selected, unselect Dislike
            isDislikeFilled = false
            Dislike.image = UIImage(systemName: "hand.thumbsdown")
            
            // Update Firestore counters
            updateCounter(for: "likeCount", increment: true)
            if isDislikeFilled {
                updateCounter(for: "dislikeCount", increment: false)
            }
        } else {
            // Decrement the like counter
            updateCounter(for: "likeCount", increment: false)
        }
    }
    
    @objc func handleDislikeTap() {
        isDislikeFilled.toggle()
        Dislike.image = UIImage(systemName: isDislikeFilled ? "hand.thumbsdown.fill" : "hand.thumbsdown")
        
        if isDislikeFilled {
            // If Dislike is selected, unselect Like
            isThumbsUpFilled = false
            Like.image = UIImage(systemName: "hand.thumbsup")
            
            // Update Firestore counters
            updateCounter(for: "dislikeCount", increment: true)
            if isThumbsUpFilled {
                updateCounter(for: "likeCount", increment: false)
            }
        } else {
            // Decrement the dislike counter
            updateCounter(for: "dislikeCount", increment: false)
        }
    }
    
    func updateCounter(for field: String, increment: Bool) {
        let postID = "postID1" // Replace with the actual post ID
        let postRef = db.collection("posts").document(postID)
        
        // Check if the document exists
        postRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // If the document exists, update the specified counter
                postRef.updateData([
                    field: FieldValue.increment(increment ? Int64(1) : Int64(-1))
                ]) { error in
                    if let error = error {
                        print("Error updating \(field): \(error)")
                    } else {
                        print("\(field) successfully updated!")
                    }
                }
            } else {
                // If the document doesn't exist, create it with initial values
                let initialData: [String: Any] = [
                    "likeCount": field == "likeCount" && increment ? 1 : 0,
                    "dislikeCount": field == "dislikeCount" && increment ? 1 : 0
                ]
                postRef.setData(initialData) { error in
                    if let error = error {
                        print("Error creating document: \(error)")
                    } else {
                        print("Document created with initial data: \(initialData)")
                    }
                }
            }
        }
    }
    
    @objc func handleBookmarkTap() {
        isBookmarkFilled.toggle()
        BookMark.image = UIImage(systemName: isBookmarkFilled ? "bookmark.fill" : "bookmark")
    }
    
    @IBAction func CancelTicket(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Cancel Ticket",
            message: "Are you sure you want to cancel this ticket?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Ticket has been canceled successfully!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func reportIconTapped() {
        let alertController = UIAlertController(
            title: "Report Issue",
            message: "Please describe the issue you want to report:",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Describe the issue"
            textField.font = UIFont.systemFont(ofSize: 14)
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let reportText = alertController.textFields?.first?.text
            print("User submitted a report: \(reportText ?? "")")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
