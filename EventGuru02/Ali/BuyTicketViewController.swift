

import UIKit
import FirebaseFirestore

class BuyTicketViewController: UIViewController {

    
    @IBOutlet weak var Locationlabel: UILabel!
    @IBOutlet weak var DateandTimelabel: UILabel!
    @IBOutlet weak var Descriptionlabel: UILabel!
    @IBOutlet weak var Categorylabel: UILabel!
    @IBOutlet weak var Pricelabel: UILabel!
    
    var db: Firestore!
    var eventID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
               
               // If we have an event ID, fetch the event details from Firestore
        if let eventID = eventID {
            fetchEventDetails(eventID: eventID)
            
        }
    }
    func fetchEventDetails(eventID: String) {
           // Fetch event data from Firestore (Assuming the events are stored in the "AddEvents" collection)
           db.collection("AddEvents").document(eventID).getDocument { [weak self] (document, error) in
               if let error = error {
                   self?.showAlert(title: "Error", message: "Failed to fetch event details: \(error.localizedDescription)")
                   return
               }
               
               if let document = document, document.exists {
                   // If the document exists, retrieve the data
                   let data = document.data()
                   
                   // Update the UI labels with the event data
                   self?.updateUI(with: data)
               } else {
                   self?.showAlert(title: "Error", message: "Event not found.")
               }
           }
       }
       
       func updateUI(with data: [String: Any]?) {
           guard let data = data else { return }
           
           // Update labels with event data
           Locationlabel.text = data["location"] as? String ?? "N/A"
           Descriptionlabel.text = data["description"] as? String ?? "N/A"
           Categorylabel.text = data["category"] as? String ?? "N/A"
           Pricelabel.text = data["price"] as? String ?? "N/A" // Assuming price is stored as a string
           
           // Format the start and end date into a readable string
           if let startDate = data["startDate"] as? Timestamp, let endDate = data["endDate"] as? Timestamp {
               let startDateFormatted = formatDateToString(timestamp: startDate)
               let endDateFormatted = formatDateToString(timestamp: endDate)
               
               // Combine the start and end date into one string
               DateandTimelabel.text = "Start: \(startDateFormatted) - End: \(endDateFormatted)"
           }
       }
       
       func formatDateToString(timestamp: Timestamp) -> String {
           let date = timestamp.dateValue() // Convert Firestore timestamp to Date
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .short
           return formatter.string(from: date)
       }
       
    
    @IBAction func ButTicketbtn(_ sender: Any) {
        // Navigate to the next screen, assuming you have a segue or another view controller
                // We will just show a placeholder alert for now
                showAlert(title: "Ticket Purchase", message: "Proceed to purchase the ticket.")
            }
    // Helper function to show alerts
       func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alert, animated: true, completion: nil)
       }
    
    }
    

