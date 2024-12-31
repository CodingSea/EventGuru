import UIKit
import FirebaseFirestore

class EventEditingViewController: UIViewController {
    
    // Outlets for the text fields and image view
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventPriceTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextField: UITextField!
    @IBOutlet weak var eventCategoryTextField: UITextField!
    @IBOutlet weak var eventStartDateTextField: UITextField!
    @IBOutlet weak var eventImageView: UIImageView!
    
    let db = Firestore.firestore()
    
    // Event ID to fetch the specific event
    var eventId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEventData()
    }
    
    func fetchEventData() {
        // Fetch event data from Firestore
        db.collection("events").document(eventId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.eventNameTextField.text = data?["eventName"] as? String
                self.eventPriceTextField.text = "\(data?["eventPrice"] as? Double ?? 0.0)"
                self.eventDescriptionTextField.text = data?["eventDescription"] as? String
                self.eventCategoryTextField.text = data?["eventCategory"] as? String
                self.eventStartDateTextField.text = data?["startDate"] as? String
                
                // Load the image from Cloudinary
                if let imageUrl = data?["eventImageURL"] as? String {
                    if let image = GetImage(string: imageUrl) {
                        self.eventImageView.image = image
                    }
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
}
