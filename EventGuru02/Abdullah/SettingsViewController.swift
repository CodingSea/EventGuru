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

    
    @IBAction func logout(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            // Redirect to Login screen or show a logged-out UI
            self.performSegue(withIdentifier: "Begin", sender: self)
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}
