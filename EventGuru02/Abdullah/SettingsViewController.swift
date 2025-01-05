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

    // MARK: - Outlets
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var PhoneNoLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch? // Optional in case it's removed later
    
    // MARK: - Properties
    let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        setupDarkModeSwitch()
    }
    
    // MARK: - Fetch User Data
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            // User is not logged in
            return
        }
        
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
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
                let password = "********" // Placeholder for password
                
                // Update the UI with the fetched data
                self.UsernameLabel.text = username
                self.EmailLabel.text = email
                self.PhoneNoLabel.text = "\(phone)"
                self.PasswordLabel.text = password
            }
        }
    }
    
    // MARK: - Dark Mode Switch
    func setupDarkModeSwitch() {
        guard let darkModeSwitch = darkModeSwitch else { return }
        
        let currentStyle = traitCollection.userInterfaceStyle
        darkModeSwitch.isOn = (currentStyle == .dark)
        
        darkModeSwitch.addTarget(self, action: #selector(toggleDarkMode(_:)), for: .valueChanged)
    }
    
    @objc func toggleDarkMode(_ sender: UISwitch) {
        overrideUserInterfaceStyle = sender.isOn ? .dark : .light
    }
    
    // MARK: - Logout
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "Begin", sender: self)
            } catch let error {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Delete Account
    @IBAction func deleteAccount(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { _ in
            self.deleteUserAccount()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteUserAccount() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user data from Firestore: \(error.localizedDescription)")
                return
            }
            
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    print("Error deleting user from Firebase Authentication: \(error.localizedDescription)")
                    return
                }
                
                self.performSegue(withIdentifier: "Begin", sender: self)
            }
        }
    }
}
