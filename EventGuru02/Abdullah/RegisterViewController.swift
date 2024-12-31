//
//  RegisterViewController.swift
//  EventGuru02
//
//  Created by BP-36-201-05 on 25/12/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phonenumberField: UITextField!
    @IBOutlet weak var dateofbirthField: UITextField!
    
    
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func Register(_ sender: Any) {
        
                // Validate the input fields
                if validateFields() {
                    guard let email = emailField.text, let password = passwordField.text, let username = usernameField.text, let phone = phonenumberField.text,
                          let dateOfBirth = dateofbirthField.text else { return }
                    
                    // Convert phone number to a number type (assuming the phone number is numeric)
                    guard let phoneNumber = Int(phone) else {
                        self.showAlert(title: "Invalid Phone Number", message: "Please enter a valid phone number.")
                        return
                    }
                    
                    // Create a new user using Firebase Authentication
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                            return
                        }
                        
                        // Successfully registered, now store additional user data in Firestore
                        guard let user = authResult?.user else { return }
                        
                        let userData: [String: Any] = [
                            "username": username,
                            "email": email,
                            "phone": phoneNumber,  // Storing phone as an integer
                            "uid": user.uid,
                            "dateofbirth": dateOfBirth,
                            "role": "User" // Adding role to the user data
                        ]
                        
                        // Store data in Firestore
                        self.db.collection("users").document(user.uid).setData(userData) { error in
                            if let error = error {
                                self.showAlert(title: "Error storing user data", message: error.localizedDescription)
                            } else {
                                print("User data stored in Firestore")
                                
                                // Redirect the user after successful registration and data storage
                                self.handleUserRedirection()
                            }
                        }
                    }
                }
            }
            
            // Function for handling user redirection after successful registration
            func handleUserRedirection() {
                // Since only normal users are allowed to register, we can now just perform the segue to the UserHome
                self.performSegue(withIdentifier: "UserHome", sender: self)
            }
            
            func validateFields() -> Bool {
                guard let email = emailField.text, !email.isEmpty,
                      let password = passwordField.text, !password.isEmpty,
                      let username = usernameField.text, !username.isEmpty,
                      let phone = phonenumberField.text, !phone.isEmpty,
                      let dateOfBirth = dateofbirthField.text, !dateOfBirth.isEmpty else {
                    showAlert(title: "Validation Error", message: "All fields are required.")
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
                
                if !isValidPhone(phone) {
                    showAlert(title: "Invalid Phone", message: "Please enter a valid phone number.")
                    return false
                }
                
                if !isValidDateOfBirth(dateOfBirth) {
                    showAlert(title: "Invalid Date of Birth", message: "Please enter a valid date of birth. YYYY/MM/DD")
                    return false
                }
                
                return true
            }
            
            // Functions to check if the email is valid
            func isValidEmail(_ email: String) -> Bool {
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
                return emailPred.evaluate(with: email)
            }
            
            // Function to check if the password is valid (at least 6 characters)
            func isValidPassword(_ password: String) -> Bool {
                return password.count >= 6
            }
            
            // Function to check if the phone number is valid (basic validation for this example)
            func isValidPhone(_ phone: String) -> Bool {
                // For simplicity, we can check if the phone number has a reasonable length
                // You can adjust this to suit your requirements (e.g., check for specific country codes)
                return phone.count >= 10
            }
            
            // Function to check if the date of birth is valid (simple format check)
            func isValidDateOfBirth(_ dateOfBirth: String) -> Bool {
                // Example check: You can refine this to validate the format more rigorously (e.g., yyyy-mm-dd)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                return dateFormatter.date(from: dateOfBirth) != nil
            }
            
            // Helper function for showing alerts to make error handling easier
            func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

        
