import UIKit
import Firebase
import FirebaseAuth

class CancelTicket: UIViewController {
    
    var ticketID: String?
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
        initializeGestures()
    }
    
    // MARK: - Initialize Gestures
    func initializeGestures() {
        setupGesture(for: Like, action: #selector(handleLikeTap), defaultImage: "hand.thumbsup")
        setupGesture(for: Dislike, action: #selector(handleDislikeTap), defaultImage: "hand.thumbsdown")
        setupGesture(for: BookMark, action: #selector(handleBookmarkTap), defaultImage: "bookmark")
        setupGesture(for: ReportIcon, action: #selector(reportIconTapped))
    }
    
    func setupGesture(for imageView: UIImageView, action: Selector, defaultImage: String? = nil) {
        if let defaultImage = defaultImage {
            imageView.image = UIImage(systemName: defaultImage)
        }
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
    }
    
    // MARK: - Like and Dislike Actions
    @objc func handleLikeTap() {
        toggleIconState(for: &isThumbsUpFilled, imageView: Like, filledImage: "hand.thumbsup.fill", defaultImage: "hand.thumbsup")
        
        if isThumbsUpFilled {
            toggleIconState(for: &isDislikeFilled, imageView: Dislike, filledImage: "hand.thumbsdown.fill", defaultImage: "hand.thumbsdown", setTo: false)
            updateCounter(for: "likeCount", increment: true)
        } else {
            updateCounter(for: "likeCount", increment: false)
        }
    }
    
    @objc func handleDislikeTap() {
        toggleIconState(for: &isDislikeFilled, imageView: Dislike, filledImage: "hand.thumbsdown.fill", defaultImage: "hand.thumbsdown")
        
        if isDislikeFilled {
            toggleIconState(for: &isThumbsUpFilled, imageView: Like, filledImage: "hand.thumbsup.fill", defaultImage: "hand.thumbsup", setTo: false)
            updateCounter(for: "dislikeCount", increment: true)
        } else {
            updateCounter(for: "dislikeCount", increment: false)
        }
    }
    
    func toggleIconState(for state: inout Bool, imageView: UIImageView, filledImage: String, defaultImage: String, setTo: Bool? = nil) {
        state = setTo ?? !state
        imageView.image = UIImage(systemName: state ? filledImage : defaultImage)
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
        toggleIconState(for: &isBookmarkFilled, imageView: BookMark, filledImage: "bookmark.fill", defaultImage: "bookmark")
    }
    
    // MARK: - Cancel Ticket Action
    @IBAction func cancelTicket(_ sender: Any) {
        guard let ticketID = ticketID else {
            print("No ticket ID provided.")
            return
        }
        
        let alertController = UIAlertController(
            title: "Cancel Ticket",
            message: "Are you sure you want to cancel this ticket?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("User confirmed cancellation.")
            
            // Update ticket status in Firestore
            self.db.collection("tickets").document(ticketID).setData([
                "status": "available",
                "userID": "",
                "timestamp": FieldValue.serverTimestamp()
            ], merge: true) { error in
                if let error = error {
                    print("Error canceling ticket: \(error.localizedDescription)")
                } else {
                    print("Ticket canceled successfully!")
                    self.deleteFromHistory(ticketID)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteFromHistory(_ ticketID: String) {
        db.collection("history")
            .whereField("ticketID", isEqualTo: ticketID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error deleting from history: \(error.localizedDescription)")
                } else {
                    snapshot?.documents.forEach { $0.reference.delete() }
                    print("Ticket deleted from history successfully!")
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
    
    // MARK: - Report Issue Action
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
