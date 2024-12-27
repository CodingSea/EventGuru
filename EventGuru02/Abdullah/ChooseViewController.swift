//
//  ChooseViewController.swift
//  EventGuru02
//
//  Created by BP-36-201-07 on 27/12/2024.
//

import UIKit

class ChooseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func AdminBtn(_ sender: Any) {
        performSegue(withIdentifier: "Admin", sender: self)
    }
    
    @IBAction func OrganaizerBtn(_ sender: Any) {
        performSegue(withIdentifier: "Organizer", sender: self)
    }
    
    
    @IBAction func UserBtn(_ sender: Any) {
        performSegue(withIdentifier: "User", sender: self)
    }
    
}
