//
//  StartViewController.swift
//  EventGuru02
//
//  Created by BP-36-201-05 on 25/12/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
           fetchUserRoleAndRedirect(user: user)
            
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        
       
                if validateFields() {
                    guard let email = emailField.text, let password = passwordField.text else { return }
                    
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            self.showAlert(title: "Login Failed", message: error.localizedDescription)
                            return
                        }
                        if let user = authResult?.user {
                            self.fetchUserRoleAndRedirect(user: user)
                        }
                    }
                }
            }
            
            func fetchUserRoleAndRedirect(user: User) {
                let userDocRef = db.collection("users").document(user.uid)
                
                userDocRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let role = document.data()?["role"] as? String {
                            self.handleUserRedirection(role: role)
                        }
                    } else {
                        self.showAlert(title: "Error", message: "User role not found.")
                    }
                }
            }
            
            // Function for handling user redirection based on role
            func handleUserRedirection(role: String) {
                switch role {
                case "Admin":
                    print("Redirecting to Admin Home")
                    self.performSegue(withIdentifier: "AdminHome", sender: self)
                case "Organizer":
                    print("Redirecting to Organizer Home")
                    self.performSegue(withIdentifier: "OrgHome", sender: self)
                case "User":
                    print("Redirecting to User Home")
                    self.performSegue(withIdentifier: "UserHome", sender: self)
                default:
                    print("Unknown role")
                    self.showAlert(title: "Error", message: "Unknown role.")
                }
            }
            
            // Function for input validation
            func validateFields() -> Bool {
                guard let email = emailField.text, !email.isEmpty,
                      let password = passwordField.text, !password.isEmpty else {
                    showAlert(title: "Validation Error", message: "Email and Password cannot be empty.")
                    return false
                }
                if !isValidEmail(email) {
                    showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
                    return false
                }
                if !isValidPassword(password) {
                    showAlert(title: "Invalid Password", message: "Password must be at least 6 characters long.")
                    return false
                }
                return true
            }
            
            // Functions for having valid email and password
            func isValidEmail(_ email: String) -> Bool {
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
                return emailPred.evaluate(with: email)
            }
            
            // Making a function to make sure the password length is 6 or bigger than 6
            func isValidPassword(_ password: String) -> Bool {
                return password.count >= 6
            }
            
            // Helper function for the alert to make my life easier
            func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

