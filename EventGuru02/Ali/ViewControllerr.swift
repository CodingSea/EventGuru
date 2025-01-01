//
//  ViewControllerr.swift
//  EventGuru02
//
//  Created by Ali Juma on 29/12/2024.
//


import UIKit

class ViewControllerr: UIViewController {
    
    
    @IBOutlet weak var thumbsUpImageView: UIImageView!
    
    @IBOutlet weak var bookmark: UIImageView!
    
    
    var isThumbsUpFilled = false
    var isBookmarkFilled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup")
        thumbsUpImageView.isUserInteractionEnabled = true
        
        
        let thumbsUpTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleThumbsUpTap))
        thumbsUpImageView.addGestureRecognizer(thumbsUpTapGestureRecognizer)
        
        
        bookmark.image = UIImage(systemName: "bookmark")
        bookmark.isUserInteractionEnabled = true
        
        let bookmarkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBookmarkTap))
        bookmark.addGestureRecognizer(bookmarkTapGestureRecognizer)
        
        reportIcon.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reportIconTapped))
        reportIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    


  
    @objc func handleThumbsUpTap() {
        
        isThumbsUpFilled.toggle()

    
        if isThumbsUpFilled {
            thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup.fill")
        } else {
            thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup")
        }
    }

    @objc func handleBookmarkTap() {
      
        isBookmarkFilled.toggle()

        
        if isBookmarkFilled {
            bookmark.image = UIImage(systemName: "bookmark.fill")
        } else {
            bookmark.image = UIImage(systemName: "bookmark")  //
        }
    }

    @IBAction func BuyTicket(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Ticket Purchase",
            message: "Are you sure you want to buy this ticket?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Ticket purchased!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Purchase cancelled.")
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func CancelReservation(_ sender: Any) {
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

    // Notify User Action
    @IBAction func Notify(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Notify if Available",
            message: "Are you sure you want an Email to be sent once tickets are available?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Email will be sent!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Email notification cancelled.")
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var reportIcon: UIImageView!
    
    @objc func reportIconTapped() {
           
            let alertController = UIAlertController(title: "Report Issue", message: "Please describe the issue you want to report:", preferredStyle: .alert)
            
            let textView = UITextView(frame: CGRect(x: 10, y: 60, width: 250, height: 50))
            textView.font = UIFont.systemFont(ofSize: 14)
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 5
            alertController.view.addSubview(textView)
            
            
            let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
                let reportText = textView.text
                print("User submitted a report: \(reportText ?? "")")
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(submitAction)
            alertController.addAction(cancelAction)
            
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    

