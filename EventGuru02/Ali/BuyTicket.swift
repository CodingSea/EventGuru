import UIKit
import Firebase
import FirebaseAuth

class BuyTicket: UIViewController {
    var ticketID: String? // Ticket ID passed dynamically
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
        
        // Initialize gestures
        initializeGestures()
    }
    
    // MARK: - Initialize Gestures
    func initializeGestures() {
        Like.image = UIImage(systemName: "hand.thumbsup")
        Like.isUserInteractionEnabled = true
        Like.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikeTap)))
        
        Dislike.image = UIImage(systemName: "hand.thumbsdown")
        Dislike.isUserInteractionEnabled = true
        Dislike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDislikeTap)))
        
        BookMark.image = UIImage(systemName: "bookmark")
        BookMark.isUserInteractionEnabled = true
        BookMark.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBookmarkTap)))
        
        ReportIcon.isUserInteractionEnabled = true
        ReportIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportIconTapped)))
    }
    
    // MARK: - Like and Dislike Actions
    @objc func handleLikeTap() {
        isThumbsUpFilled.toggle()
        Like.image = UIImage(systemName: isThumbsUpFilled ? "hand.thumbsup.fill" : "hand.thumbsup")
        
        if isThumbsUpFilled {
            isDislikeFilled = false
            Dislike.image = UIImage(systemName: "hand.thumbsdown")
            updateCounter(for: "likeCount", increment: true)
        } else {
            updateCounter(for: "likeCount", increment: false)
        }
    }
    
    @objc func handleDislikeTap() {
        isDislikeFilled.toggle()
        Dislike.image = UIImage(systemName: isDislikeFilled ? "hand.thumbsdown.fill" : "hand.thumbsdown")
        
        if isDislikeFilled {
            isThumbsUpFilled = false
            Like.image = UIImage(systemName: "hand.thumbsup")
            updateCounter(for: "dislikeCount", increment: true)
        } else {
            updateCounter(for: "dislikeCount", increment: false)
        }
    }
    
    // MARK: - Counter Update
    func updateCounter(for field: String, increment: Bool) {
        guard let ticketID = ticketID else {
            print("No ticket ID provided.")
            return
        }
        let ticketRef = db.collection("tickets").document(ticketID)
        
        ticketRef.updateData([
            field: FieldValue.increment(increment ? Int64(1) : Int64(-1))
        ]) { error in
            if let error = error {
                print("Error updating \(field): \(error.localizedDescription)")
            } else {
                print("\(field) successfully updated!")
            }
        }
    }
    
    // MARK: - Bookmark Action
    @objc func handleBookmarkTap() {
        isBookmarkFilled.toggle()
        BookMark.image = UIImage(systemName: isBookmarkFilled ? "bookmark.fill" : "bookmark")
    }
    
    // MARK: - Buy Ticket Action
    @IBAction func buyTicket(_ sender: Any) {
        guard let ticketID = ticketID else {
            print("No ticket ID provided.")
            return
        }
        
        let alertController = UIAlertController(
            title: "Ticket Purchase",
            message: "Are you sure you want to buy this ticket?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("User confirmed purchase.")
            
            // Update ticket status in Firestore
            self.db.collection("tickets").document(ticketID).setData([
                "status": "bought",
                "userID": Auth.auth().currentUser?.uid ?? "",
                "timestamp": FieldValue.serverTimestamp()
            ], merge: true) { error in
                if let error = error {
                    print("Error buying ticket: \(error.localizedDescription)")
                } else {
                    print("Ticket purchased successfully!")
                    
                    // Add to history
                    self.db.collection("history").addDocument(data: [
                        "action": "Buy",
                        "ticketID": ticketID,
                        "userID": Auth.auth().currentUser?.uid ?? "",
                        "timestamp": FieldValue.serverTimestamp()
                    ]) { historyError in
                        if let historyError = historyError {
                            print("Error saving to history: \(historyError.localizedDescription)")
                        } else {
                            print("Purchase saved in history successfully!")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Report Icon Action
    @objc func reportIconTapped() {
        let alertController = UIAlertController(
            title: "Report Issue",
            message: "Please describe the issue you want to report:",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Describe the issue"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            let reportText = alertController.textFields?.first?.text ?? "No description provided"
            print("User reported an issue: \(reportText)")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
