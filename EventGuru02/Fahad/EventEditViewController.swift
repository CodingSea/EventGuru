

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Cloudinary

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
            print(eventID)
            EventName.text = eventID
            // Load the existing event data for editing
            loadEventData(eventID: eventID)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    
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
            "price": price.text ?? "",
            // Add other fields as necessary
        ]
        
        db.collection("AddEvents").document(eventID).updateData(updatedEventData) { error in
            if let error = error {
                print("Error updating event: \(error.localizedDescription)")
            } else {
                print("Event updated successfully!")
                // Optionally, navigate back or clear fields
                self.navigationController?.popViewController(animated: true)
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
            
            // No need to validate price as a number anymore, it's stored as a string
            return true
        }
        
        // Helper function to show alerts
        func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
            self?.price.text = data["price"] as? String
            // Load other fields as necessary
        }
    }
        
}
