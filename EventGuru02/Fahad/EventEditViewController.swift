

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Cloudinary

protocol EventEditDelegate: AnyObject {
    func didUpdateEvent()
}

class EventEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var eventID: String?
    
    var db: Firestore!
    var uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var EventName: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var Location: UITextField!
    @IBOutlet weak var Category: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    @IBOutlet weak var textView: UITextView!
    var selectedCategory: String?
    
    weak var delegate: EventEditDelegate?
    
    let validCategories = [
        "Entertainment",
        "Social Gatherings",
        "Outdoor Activities",
        "Personal Development",
        "Technology",
        "Fitness",
        "Gaming",
        "Sports"
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        
        if let eventID = eventID {
            
            loadEventData(eventID: eventID)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let eventID = eventID {
            loadEventData(eventID: eventID) // Load data every time the view appears
        }
    }
    
    
    @IBAction func selectPhotoTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func createEventBtn(_ sender: Any)
    {
        guard validateFields() else { return }
        
        if let eventID = eventID {
            // Update the existing event
            updateEvent(eventID: eventID)
        }
    }
    
    func updateEvent(eventID: String) {
        let updatedEventData: [String: Any] = [
            "eventName": EventName.text ?? "",
            "description": Description.text ?? "",
            "price": price.text ?? "",
            "location": Location.text ?? "",
            "category": Category.text ?? "",
            "startDate": startDatePicker.date,
            "endDate": endDatePicker.date,
            //"ImagePath": EventHelper.getImagePath()
        ]
        
        db.collection("AddEvents").document(eventID).updateData(updatedEventData) { error in
            if let error = error {
                print("Error updating event: \(error.localizedDescription)")
            } else {
                print("Event updated successfully!")
                self.delegate?.didUpdateEvent() // Notify delegate
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    
    func validateFields() -> Bool {
        guard let eventName = EventName.text, !eventName.isEmpty,
              let description = Description.text, !description.isEmpty,
              let location = Location.text, !location.isEmpty,
              let priceText = price.text, !priceText.isEmpty,
              let category = Category.text, !category.isEmpty else {
            showAlert(title: "Validation Error", message: "All fields are required.")
            return false
        }
        
        // Check start and end dates
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        if endDate < startDate {
            showAlert(title: "Validation Error", message: "End date cannot be before start date.")
            return false
        }
        
        return true
    }
        
        // Helper function to show alerts
        func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    
    
    @IBAction func back(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
        
        func uploadImage(image: UIImage, completion: @escaping (String?) -> Void) {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(nil)
                return
            }
            
            let uploadParams = CLDUploadRequestParams().setResourceType(.image)
            
            cloudinary.createUploader().upload(data: imageData, uploadPreset: "ml_default", completionHandler:  { result, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let secureUrl = result?.secureUrl {
                    print("Uploaded image URL: \(secureUrl)")
                    completion(secureUrl)
                    
                } else {
                    completion(nil)
                }
            })
        }
        
    func loadEventData(eventID: String) {
        db.collection("AddEvents").document(eventID).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error loading event data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("Event does not exist")
                return
            }
            
            // Load data into UI elements
            self?.EventName.text = data["eventName"] as? String
            self?.Description.text = data["description"] as? String
            self?.price.text = data["price"] as? String
            self?.Location.text = data["location"] as? String
            self?.Category.text = data["category"] as? String
            
            
            // Get startDate and endDate from Firestore
            if let startDateTimestamp = data["startDate"] as? Timestamp {
                self?.startDatePicker.date = startDateTimestamp.dateValue()
            }
            
            if let endDateTimestamp = data["endDate"] as? Timestamp {
                self?.endDatePicker.date = endDateTimestamp.dateValue()
            }
            
            
            // Load the image from Cloudinary
            if let imageUrl = URL(string: data["ImagePath"] as! String) {
                self?.fetchImage(from: imageUrl) { image in
                    DispatchQueue.main.async {
                        self?.imageView.image = image // Assuming you have an IBOutlet for UIImageView
                    }
                }
            }
            
            
        }
    }
    
    
    
    
    // Function to fetch the image from Cloudinary
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            completion(image)
        }
        
        task.resume()
    }
    
    
        
}
