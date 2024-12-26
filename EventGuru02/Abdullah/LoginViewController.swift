//
//  StartViewController.swift
//  EventGuru02
//
//  Created by BP-36-201-05 on 25/12/2024.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        if validateFields() {
                    guard let email = emailField.text, let password = passwordField.text else { return }
                    
                    //
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            self.showAlert(title: "Login Failed", message: error.localizedDescription)
                            return
                        }
                        self.handleUserRedirection()
                    }
                }
            }
            
            //functino for handling user redirection
            func handleUserRedirection() {
                guard let user = Auth.auth().currentUser, let email = user.email else { return }
                let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmedEmail.contains("@eventguru.admin") {
                    print("Redirecting to Admin Home")
                    self.performSegue(withIdentifier: "AdminHome", sender: self)
                } else if trimmedEmail.contains("@eventguru.organizer") {
                    print("Redirecting to Organizer Home")
                    self.performSegue(withIdentifier: "OrgHome", sender: self)
                } else {
                    print("Redirecting to User Home")
                    self.performSegue(withIdentifier: "UserHome", sender: self)
                }
            }
            
            //a function for input validation
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
            
            //functions for having valid email and password
            func isValidEmail(_ email: String) -> Bool {
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
                return emailPred.evaluate(with: email)
            }
            
            //making a function to make sure thet the password lenght is 6 or biggeer than 6
            func isValidPassword(_ password: String) -> Bool {
                return password.count >= 6
            }
            
            //helper function for the alert to make my life easier
            func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        
        
        
        }
    


