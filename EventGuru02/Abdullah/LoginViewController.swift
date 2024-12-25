//
//  StartViewController.swift
//  EventGuru02
//
//  Created by BP-36-201-05 on 25/12/2024.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        
        guard let username = usernameField.text, let password = passwordField.text,
              !username.isEmpty && !password.isEmpty else {
            
            let alert = UIAlertController(title: "Missing field data", message: "Please fill in the required fields", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            self.present(alert, animated: true)
            
            
            return
        }
        
        
        
        FirebaseAuth.Auth.auth().signIn(withEmail: username, password: password, completion: { (result, error) in
            guard error == nil else {
                
                //show error message
                let alert = UIAlertController(title: "Invalid Credentials", message: "invalid Credentials, please try again", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                self.present(alert, animated: true)
                
                return
                
            }
        
            self.performSegue(withIdentifier: "Home", sender: sender)
            
        })
        
    }
    
}
