//
//  CancelTicket.swift
//  EventGuru02
//
//  Created by Ali Juma on 02/01/2025.
//

import UIKit

class CancelTicket: UIViewController {
    
    @IBOutlet weak var thumbsUpImageView: UIImageView!
    @IBOutlet weak var bookmark: UIImageView!
    @IBOutlet weak var reportIcon: UIImageView!
    
    var isThumbsUpFilled = false
    var isBookmarkFilled = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize thumbs up image and gesture
        thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup")
        thumbsUpImageView.isUserInteractionEnabled = true
        let thumbsUpTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleThumbsUpTap))
        thumbsUpImageView.addGestureRecognizer(thumbsUpTapGestureRecognizer)
        
        // Initialize bookmark image and gesture
        bookmark.image = UIImage(systemName: "bookmark")
        bookmark.isUserInteractionEnabled = true
        let bookmarkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBookmarkTap))
        bookmark.addGestureRecognizer(bookmarkTapGestureRecognizer)
        
        // Initialize report icon gesture
        reportIcon.isUserInteractionEnabled = true
        let reportTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reportIconTapped))
        reportIcon.addGestureRecognizer(reportTapGestureRecognizer)
    }
    
    @IBAction func cancelReservation(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Cancel Reservation",
            message: "Are you sure you want to cancel this ticket?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Ticket canceled!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel reservation cancelled.")
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleThumbsUpTap() {
        isThumbsUpFilled.toggle()
        thumbsUpImageView.image = UIImage(systemName: isThumbsUpFilled ? "hand.thumbsup.fill" : "hand.thumbsup")
    }

    @objc func handleBookmarkTap() {
        isBookmarkFilled.toggle()
        bookmark.image = UIImage(systemName: isBookmarkFilled ? "bookmark.fill" : "bookmark")
    }
    
    @objc func reportIconTapped() {
        let alertController = UIAlertController(
            title: "Report Issue",
            message: "Please describe the issue you want to report:",
            preferredStyle: .alert
        )
        
        // Add a text field to the alert
        alertController.addTextField { textField in
            textField.placeholder = "Describe the issue"
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
