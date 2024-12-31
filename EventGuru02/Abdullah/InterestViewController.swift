
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
                let userUID = Auth.auth().currentUser?.uid // User UID for identifying the current user

                override func viewDidLoad() {
                    super.viewDidLoad()
                    
                    // Fetch the user's interests from Firestore and update the switches
                    if let userUID = userUID {
                        fetchUserInterests(userUID: userUID)
                    } else {
                        print("User is not logged in")
                    }
                }

                // Fetch the interests from Firestore
            func fetchUserInterests(userUID: String) {
                    db.collection("Interests").document(userUID).getDocument { [weak self] (document, error) in
                        if let error = error {
                            self?.showAlert(title: "Error", message: "Failed to fetch interests: \(error.localizedDescription)")
                            return
                        }

                        if let document = document, document.exists {
                            // If the document exists, retrieve the data
                            let data = document.data()
                            self?.updateSwitchesFromFirestore(data: data)
                        } else {
                            // If no document exists for the user, initialize switches to "off" by default
                            self?.initializeDefaultSwitches()
                        }
                    }
                }
                
            func initializeDefaultSwitches() {
                   EntertainmentSwitch.setOn(false, animated: false)
                   SocialGatheringsSwitch.setOn(false, animated: false)
                   OutDoorActivitiesSwitch.setOn(false, animated: false)
                   PersonalDevelopmentSwitch.setOn(false, animated: false)
                   TechnologySwitch.setOn(false, animated: false)
                   FitnessSwitch.setOn(false, animated: false)
                   GamingSwitch.setOn(false, animated: false)
                   SportsSwitch.setOn(false, animated: false)
               }
                
            
                

                // Update the switches based on the fetched data
                func updateSwitchesFromFirestore(data: [String: Any]?) {
                    guard let interests = data else { return }
                    
                    // Update each switch based on the corresponding value in Firestore
                    EntertainmentSwitch.setOn(interests["Entertainment"] as? Bool ?? false, animated: false)
                    SocialGatheringsSwitch.setOn(interests["Social Gatherings"] as? Bool ?? false, animated: false)
                    OutDoorActivitiesSwitch.setOn(interests["Outdoor Activities"] as? Bool ?? false, animated: false)
                    PersonalDevelopmentSwitch.setOn(interests["Personal Development"] as? Bool ?? false, animated: false)
                    TechnologySwitch.setOn(interests["Technology"] as? Bool ?? false, animated: false)
                    FitnessSwitch.setOn(interests["Fitness"] as? Bool ?? false, animated: false)
                    GamingSwitch.setOn(interests["Gaming"] as? Bool ?? false, animated: false)
                    SportsSwitch.setOn(interests["Sports"] as? Bool ?? false, animated: false)
                }

                // Action for "Save" button
                @IBAction func savebtn(_ sender: UIButton) {
                    guard let userUID = userUID else {
                        showAlert(title: "Error", message: "User not logged in.")
                        return
                    }
                    
                    // Capture the state of each switch (true if ON, false if OFF)
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
                    
                    let filteredInterests = interests.filter { $0.value == true }

                           if filteredInterests.isEmpty {
                               // If no interests are selected, do not save anything to Firestore
                               showAlert(title: "No Interests Selected", message: "Please select at least one interest.")
                               return
                           }
                    
                    
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

                // Helper function to show alerts
                func showAlert(title: String, message: String) {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
