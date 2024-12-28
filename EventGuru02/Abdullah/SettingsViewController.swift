//
//  SettingsViewController.swift
//  EventGuru02
//
//  Created by BP-36-201-05 on 25/12/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var PhoneNoLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
    }
    
    func fetchUserData() {
           guard let userId = Auth.auth().currentUser?.uid else {
               // User is not logged in
               return
           }

           // Fetch user document from Firestore
           db.collection("users").document(userId).getDocument { (document, error) in
               if let error = error {
                   print("Error getting user document: \(error.localizedDescription)")
                   return
               }

               guard let document = document, document.exists else {
                   print("User document does not exist")
                   return
               }
               
               // Extract user data from Firestore document
               if let data = document.data() {
                   let username = data["username"] as? String ?? "No Username"
                   let email = data["email"] as? String ?? "No Email"
                   let phone = data["phone"] as? Int ?? 0
                   let password = "********"  // Since password is not stored in Firestore, use a placeholder
                   
                   // Update the UI with the fetched data
                   self.UsernameLabel.text = username
                   self.EmailLabel.text = email
                   self.PhoneNoLabel.text = "\(phone)"  // Convert phone number to String for display
                   self.PasswordLabel.text = password // Display a placeholder for the password
               }
           }
       }
    
    @IBAction func logout(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            // Redirect to Login screen or show a logged-out UI
            self.performSegue(withIdentifier: "Begin", sender: self)
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
        
    }

}








    //func loadData() {
       // guard let uid = Auth.auth().currentUser?.uid else { return }
       // db.collection("users").document(uid).getDocument { (document, error) in
          //  if let error = error {
              //  print("Error fetching user data: \(error.localizedDescription)")
             //   return
          //  }
           // if let document = document, document.exists {
             //   let data = document.data()
            //    self.UsernameLabel.text = data?["username"] as? String ?? "N/A"
             //   self.EmailLabel.text = data?["email"] as? String ?? "N/A"
             //   self.PhoneNoLabel.text = String(data?["phone"] as? Int ?? 0) // Since passwords are typically not stored in a retrievable format for security reasons,
                // consider providing a placeholder or indication of a password reset option instead.
             //   self.PasswordLabel.text = "******" // Placeholder for the password } }
                
         //   }
      //  }
//}
