//
//  HomeViewController.swift
//  EventGuru02
//
//  Created by Mac on 28/12/2024.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var EventTable: UITableView!
    
    var db: Firestore!
       var events = [Event]() // All events
       var filteredEvents = [Event]() // Filtered events
       var userUID = Auth.auth().currentUser?.uid
       var userInterests = [String]() // User's interests

       override func viewDidLoad() {
           super.viewDidLoad()
           
           db = Firestore.firestore()
           EventTable.delegate = self
           EventTable.dataSource = self
           
           fetchEvents() // Fetch all events initially
       }
       
       // MARK: - Fetch Events from Firestore (All Events Initially)
       func fetchEvents() {
           db.collection("AddEvents").getDocuments { [weak self] (querySnapshot, error) in
               if let error = error {
                   print("Error fetching events: \(error.localizedDescription)")
                   return
               }
               
               self?.events = querySnapshot?.documents.compactMap { document -> Event? in
                   let data = document.data()
                   let eventName = data["eventName"] as? String ?? ""
                   let price = data["price"] as? String ?? ""
                   let category = data["category"] as? String ?? ""
                   
                   return Event(eventName: eventName, price: price, category: category)
               } ?? []
               
               // Initially, show all events (no filtering yet)
               self?.filteredEvents = self?.events ?? []
               
               // Reload table with all events
               self?.EventTable.reloadData()
           }
       }
       
       // MARK: - Fetch User Interests When Filter Button is Clicked
       func fetchUserInterestsAndFilter() {
           guard let userUID = userUID else { return }
           
           db.collection("Interests").document(userUID).getDocument { [weak self] (document, error) in
               if let error = error {
                   print("Error fetching interests: \(error.localizedDescription)")
                   return
               }
               
               if let document = document, document.exists {
                   let interestsData = document.data()
                   self?.userInterests = interestsData?.filter { $0.value as? Bool == true }.map { $0.key } ?? []
                   
                   print("User Interests: \(self?.userInterests ?? [])")
                   
                   // Filter events based on user interests
                   self?.filterEvents()
               } else {
                   print("No interests found for the user.")
                   self?.userInterests = [] // If no interests, show all events
                   self?.filterEvents()
               }
           }
       }

       // MARK: - Filter Events Based on User Interests
       func filterEvents() {
           print("Filtering events based on user interests: \(userInterests)")
           
           if userInterests.isEmpty {
               // If no interests, show all events
               filteredEvents = events
           } else {
               // Filter events based on user interests
               filteredEvents = events.filter { event in
                   return userInterests.contains(event.category)
               }
           }
           
           print("Filtered events: \(filteredEvents)")
           
           // Reload the table with filtered events
           EventTable.reloadData()
       }

       // MARK: - TableView DataSource Methods
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return filteredEvents.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HomeTableViewCell
           
           let event = filteredEvents[indexPath.row]
           
           cell?.EventName.text = event.eventName
           cell?.EventPrice.text = event.price
           
           return cell ?? UITableViewCell()
       }
       
    
    @IBAction func filterButton(_ sender: Any) {
        
        fetchUserInterestsAndFilter()
    }
    
    
    @IBAction func allEvents(_ sender: Any) {
        
        // Reset filteredEvents to show all events again
               filteredEvents = events
               
               // Reload the table view to display all events
               EventTable.reloadData()
        
    }
    
    
    
    struct Event {
           var eventName: String
           var price: String
           var category: String
       }

}
