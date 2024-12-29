//
//  PostViewController.swift
//  EventGuru02
//
//  Created by Fahad on 15/12/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class PostViewController: UIViewController {
    
    var db: Firestore!
    var uid = Auth.auth().currentUser?.uid

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var selectedCategory: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.borderWidth = 1
        
        db = Firestore.firestore()
    }
    
    @IBAction func createEventBtn(_ sender: Any)
    {
        let eventData: [String: Any] =
        [
            "EventName": eventName.text ?? "Name test",
            "Description": textView.text ?? "Description",
            "Price": price.text ?? "100 BHD",
            "Location": location.text ?? "Manama",
            "StartDate": startDatePicker.date,
            "EndDate": endDatePicker.date,
            "Category": selectedCategory ?? "None"
        ]
        
        db.collection("Events").document(uid ?? "0").setData(eventData)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
