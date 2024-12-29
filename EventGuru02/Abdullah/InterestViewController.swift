//
//  InterestViewController.swift
//  EventGuru02
//
//  Created by BP on 29/12/2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class InterestViewController: UIViewController {
    
    @IBOutlet weak var Entertainmentlabel: UILabel!
    @IBOutlet weak var SocialGatheringslabel: UILabel!
    @IBOutlet weak var OutdoorActiviteslabel: UILabel!
    @IBOutlet weak var PersonalDevelopmentlabel: UILabel!
    @IBOutlet weak var Technologylabel: UILabel!
    @IBOutlet weak var Fitnesslabel: UILabel!
    @IBOutlet weak var Gaminglabel: UILabel!
    @IBOutlet weak var Sportslabel: UILabel!
    
    @IBOutlet weak var EntertainmentSwitch: UISwitch!
    @IBOutlet weak var SocialGatheringsSwitch: UISwitch!
    @IBOutlet weak var OutDoorActivitiesSwitch: UISwitch!
    @IBOutlet weak var PersonalDevelopmentSwitch: UISwitch!
    @IBOutlet weak var TechnologySwitch: UISwitch!
    @IBOutlet weak var FitnessSwitch: UISwitch!
    @IBOutlet weak var GamingSwitch: UISwitch!
    @IBOutlet weak var SportsSwitch: UISwitch!
    
    let db = Firestore.firestore()
    let userUID = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetSwitchesToDefault()
    }
    
    func resetSwitchesToDefault() {
        EntertainmentSwitch.setOn(false, animated: false)
        SocialGatheringsSwitch.setOn(false, animated: false)
        OutDoorActivitiesSwitch.setOn(false, animated: false)
        PersonalDevelopmentSwitch.setOn(false, animated: false)
        TechnologySwitch.setOn(false, animated: false)
        FitnessSwitch.setOn(false, animated: false)
        GamingSwitch.setOn(false, animated: false)
        SportsSwitch.setOn(false, animated: false)
    }
    
    
    @IBAction func Savebtn(_ sender: Any) {
        
        guard let userUID = userUID else {
            showAlert(title: "Error", message: "User not logged in.")
            return
            
        }
        let interests: [String: Bool] = [
            "Entertainment": EntertainmentSwitch.isOn,
            "Social Gatherings": SocialGatheringsSwitch.isOn,
            "Outdoor Activities": OutDoorActivitiesSwitch.isOn,
            "Personal Development": PersonalDevelopmentSwitch.isOn,
            "Technology": TechnologySwitch.isOn,
            "Fitness": FitnessSwitch.isOn,
            "Gaming": GamingSwitch.isOn,
            "Sports": SportsSwitch.isOn
        ]
        // Save interests to Firestore
        db.collection("Interests").document(userUID).setData(interests) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save interests: \(error.localizedDescription)")
            } else {
                print("User interests saved successfully!")
                self.showAlert(title: "Success", message: "Your interests have been saved.")
            }
        }
        
        
    }
    
    func showAlert(title: String, message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alert, animated: true, completion: nil)
       }
    
}
