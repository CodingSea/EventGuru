//
//  TestViewController.swift
//  EventGuru02
//
//  Created by BP-36-201-05 on 25/12/2024.
//

import UIKit
import FirebaseAuth

class TestViewController: UIViewController {
    
    @IBAction func signout(_ sender: Any) {
        
        do {
            try FirebaseAuth.Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error Signing Out")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
}
