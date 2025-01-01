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
        
        let currentStyle = traitCollection.userInterfaceStyle
        
        
        darkModeSwitch.isOn = (currentStyle == .dark)
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
                self.UsernameLabel.text = "  \(username) "
                self.EmailLabel.text = "  \(email) "
                self.PhoneNoLabel.text = " \(phone)"  // Convert phone number to String for display
                self.PasswordLabel.text = "  \(password)" // Display a placeholder for the password
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                // Redirect to Login screen after successful logout
                self.performSegue(withIdentifier: "Begin", sender: self)
            } catch let error {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func DeleteBtn(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { _ in
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            // First, delete user data from Firestore
            self.db.collection("users").document(userId).delete { error in
                if let error = error {
                    print("Error deleting user data from Firestore: \(error.localizedDescription)")
                    return
                }
                
                // Delete the user from Firebase Authentication
                Auth.auth().currentUser?.delete { error in
                    if let error = error {
                        print("Error deleting user from Firebase Authentication: \(error.localizedDescription)")
                        return
                    }
                    
                    // Successfully deleted user, redirect to login screen
                    self.performSegue(withIdentifier: "Begin", sender: self)
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var darkModeSwitch: UISwitch!

    
    @IBAction func darkModeSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
              overrideUserInterfaceStyle = .dark
          } else {
              overrideUserInterfaceStyle = .light
          }
      }
        
        
    }
    
    
    
    
    
    

         
    
    
    
    
    
    
