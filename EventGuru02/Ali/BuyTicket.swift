import UIKit
import Firebase
import FirebaseAuth



class BuyTicket: UIViewController {
    // MARK: - Properties
    var ticketID: String? // Ticket ID passed dynamically
    var eventName: String?
    var eventData: [String: Any]?
    
    let db = Firestore.firestore()
    
    // MARK: - Outlets
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var Like: UIImageView!
    @IBOutlet weak var Dislike: UIImageView!
    @IBOutlet weak var ReportIcon: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var isThumbsUpFilled = false
    var isDislikeFilled = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        displayEventData()
        initializeGestures()
        print("Ticket ID: \(ticketID ?? "None")")
        print("Event Name: \(eventName ?? "None")")
    }
    
    // MARK: - Display Event Data
    func displayEventData() {
        guard let eventData = eventData else {
            print("No event data provided.")
            return
        }
        
        // Extract and display data
        let eventName = eventData["eventName"] as? String ?? "Event"
        let location = eventData["location"] as? String ?? "No location"
        let description = eventData["description"] as? String ?? "No description"
        let category = eventData["category"] as? String ?? "No category"
        let price = eventData["price"] as? String ?? "0"
        let endDate = formatDate(eventData["startDate"] as? Timestamp)
        
        
        eventNameLabel.text = eventName
        locationLabel.text = location
        descriptionLabel.text = description
        categoryLabel.text = category
        dateLabel.text = endDate
        priceLabel.text = price
    }
    
    
    
    // MARK: - Format Date
    func formatDate(_ timestamp: Timestamp?) -> String {
        guard let timestamp = timestamp else { return "No date available" }
        
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Initialize Gestures
    func initializeGestures() {
        Like.image = UIImage(systemName: "hand.thumbsup")
        Like.isUserInteractionEnabled = true
        Like.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLikeTap)))
        
        Dislike.image = UIImage(systemName: "hand.thumbsdown")
        Dislike.isUserInteractionEnabled = true
        Dislike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDislikeTap)))
        
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
    
    // MARK: - Buy Ticket Action
    @IBAction func buyTicket(_ sender: Any) {
        guard let ticketID = ticketID, let eventName = eventName else {
            print("No ticket ID or event name provided.")
            return
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated.")
            return
        }
        
        let userDocRef = db.collection("users").document(currentUser.uid)
        userDocRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }
            
            let userName = document?.data()?["name"] as? String ?? currentUser.displayName ?? "Unknown User"
            let userEmail = document?.data()?["email"] as? String ?? currentUser.email ?? "No Email"
            
            let alertController = UIAlertController(
                title: "Ticket Purchase",
                message: "Are you sure you want to buy the ticket for \(eventName)?",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                self.saveTicketPurchase(ticketID: ticketID, eventName: eventName, userName: userName, userEmail: userEmail)
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alertController, animated: true)
        }
    }
    
    // MARK: - Save Ticket Purchase
    func saveTicketPurchase(ticketID: String, eventName: String, userName: String, userEmail: String) {
        db.collection("tickets").document(ticketID).setData([
            "status": "bought",
            "userID": Auth.auth().currentUser?.uid ?? "Unknown User",
            "userName": userName,
            "userEmail": userEmail,
            "timestamp": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Error saving ticket: \(error.localizedDescription)")
                return
            }
            print("Ticket saved successfully.")
            
            self.db.collection("history").addDocument(data: [
                "action": "Bought \(eventName)",
                "ticketID": ticketID,
                "userID": Auth.auth().currentUser?.uid ?? "Unknown User",
                "userName": userName,
                "timestamp": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    print("Error saving to history: \(error.localizedDescription)")
                } else {
                    print("Purchase history saved successfully.")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
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
        
        // Submit action to save the report
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            
            let reportText = alertController.textFields?.first?.text ?? "No description provided"
            print("User reported an issue: \(reportText)")
            
            
            self.saveReport(reportText)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        
        present(alertController, animated: true)
    }
    
    // MARK: - Save Report to Firestore
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
        
        // Save the report as a new document in the "reports" collection
        db.collection("reports").addDocument(data: reportData) { error in
            if let error = error {
                print("Error saving report: \(error.localizedDescription)")
            } else {
                print("Report saved successfully.")
                
                // Show confirmation alert
                let confirmationAlert = UIAlertController(
                    title: "Thank You",
                    message: "Your report has been submitted successfully.",
                    preferredStyle: .alert
                )
                confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(confirmationAlert, animated: true)
            }
        }
    }
}
