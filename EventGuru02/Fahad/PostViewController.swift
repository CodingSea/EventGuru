

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var db: Firestore!
    var uid = Auth.auth().currentUser?.uid

    @IBOutlet weak var Description: UITextView!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var location: UITextField!
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
    }
    
    func uploadImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        cloudinary.createUploader().upload(data: imageData, uploadPreset: "ml_default", completionHandler:  { (result, error) in
            if error != nil {
                print("Upload failed: (error)")
            } else if let result = result {
                let imageUrl = result.secureUrl
                EventHelper.updateImagePath(to: imageUrl!)
                print("Upload successful: \(imageUrl!)")
                print("Upload successful: (result.secureUrl!)")
            }
        })
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
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
              
              // Gather the data from the fields
              guard let eventName = eventName.text,
                    let description = Description.text,
                    let location = location.text,
                    let priceText = price.text,
                    let category = Category.text else {
                  showAlert(title: "Validation Error", message: "Please fill all fields correctly.")
                  return
              }
              
              // Validate the category (it must be one of the predefined valid categories)
              if !validCategories.contains(category) {
                  showAlert(title: "Invalid Category", message: "Please choose a valid category.")
                  return
              }
              
              // Convert the dates to timestamps
              let startDate = startDatePicker.date
              let endDate = endDatePicker.date
        
              
              // Create the event data to store in Firestore
              let eventData: [String: Any] = [
                  "eventName": eventName,
                  "description": description,
                  "location": location,
                  "price": priceText,  // Store price as a string
                  "category": category,
                  "startDate": startDate,
                  "endDate": endDate,
                  "ImagePath": EventHelper.getImagePath(),
                  "uid": uid ?? ""  // Use the current user's UID
              ]
              
              // Save the event in Firestore under the "AddEvents" collection
              db.collection("AddEvents").addDocument(data: eventData) { error in
                  if let error = error {
                      self.showAlert(title: "Error", message: "Failed to create event: \(error.localizedDescription)")
                  } else {
                      self.showAlert(title: "Success", message: "Event created successfully!")
                  }
              }
          }
    func validateFields() -> Bool {
            guard let eventName = eventName.text, !eventName.isEmpty,
                  let description = Description.text, !description.isEmpty,
                  let location = location.text, !location.isEmpty,
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
    }
