import UIKit
import Firebase
import FirebaseAuth

class CancelTicket: UIViewController {

    var ticketID: String?
    let db = Firestore.firestore()
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var Like: UIImageView!
    @IBOutlet weak var Dislike: UIImageView!
    @IBOutlet weak var ReportIcon: UIImageView!

    var isThumbsUpFilled = false
    var isDislikeFilled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGestures()
        fetchTicketDetails()
    }

    // Fetch ticket details from Firestore
    func fetchTicketDetails() {
        guard let ticketID = ticketID else {
            print("No ticket ID provided.")
            return
        }

        db.collection("AddEvents").document(ticketID).getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching ticket details: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("No ticket found with the provided ID.")
                return
            }

            // Populate UI with fetched data
            self.populateData(with: data)
        }
    }

    // Populate the UI labels with fetched data
    func populateData(with data: [String: Any]) {
        eventNameLabel.text = data["eventName"] as? String ?? "N/A"
        locationLabel.text = data["location"] as? String ?? "N/A"
        descriptionLabel.text = data["description"] as? String ?? "N/A"
        categoryLabel.text = data["category"] as? String ?? "N/A"
        priceLabel.text = "\(data["price"] as? String ?? "0.0")"
        dateLabel.text = formatDate(data["startDate"] as? Timestamp)
    }

    // Format Firestore timestamp to a readable date string
    func formatDate(_ timestamp: Timestamp?) -> String {
        guard let timestamp = timestamp else { return "N/A" }
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Initialize gestures for Like, Dislike, and Report
    func initializeGestures() {
        setupGesture(for: Like, action: #selector(handleLikeTap), defaultImage: "hand.thumbsup")
        setupGesture(for: Dislike, action: #selector(handleDislikeTap), defaultImage: "hand.thumbsdown")
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
    

    func toggleIconState(for state: inout Bool, imageView: UIImageView, filledImage: String, defaultImage: String) {
        state.toggle()
        imageView.image = UIImage(systemName: state ? filledImage : defaultImage)
    }

    @objc func reportIconTapped() {
        let alertController = UIAlertController(title: "Report Issue", message: "Please describe the issue you want to report:", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Describe the issue"
        }

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let reportText = alertController.textFields?.first?.text ?? "No description provided"
            self.saveReport(reportText)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // Save a report to Firestore
    func saveReport(_ report: String) {
        guard let ticketID = ticketID else {
            print("No ticket ID provided.")
            return
        }

        let currentUserID = Auth.auth().currentUser?.uid ?? "Unknown User"
        let reportData: [String: Any] = [
            "ticketID": ticketID,
            "userID": currentUserID,
            "report": report,
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("reports").addDocument(data: reportData) { error in
            if let error = error {
                print("Error saving report: \(error.localizedDescription)")
            } else {
                print("Report saved successfully.")
                let confirmationAlert = UIAlertController(title: "Thank You", message: "Your report has been submitted successfully.", preferredStyle: .alert)
                confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(confirmationAlert, animated: true)
            }
        }
    }
    
    
    
    
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
    
}
