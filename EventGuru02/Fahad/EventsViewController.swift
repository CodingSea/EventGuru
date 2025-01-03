//
//  EventsViewController.swift
//  EventGuru02
//
//  Created by Fahad on 03/01/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EventCellDelegate {
    
    @IBOutlet weak var EventTable: UITableView!
    
    var db: Firestore!
    var events = [Event]() // All events
    var filteredEvents = [Event]() // Filtered events
    var userUID = Auth.auth().currentUser?.uid
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? EventTableViewCell
        
        let event = filteredEvents[indexPath.row]
        
        // Load the image from Cloudinary
        if let imageUrl = URL(string: event.imagePath) {
            fetchImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    cell?.EventImage.image = image // Assuming you have an IBOutlet for UIImageView
                }
            }
        }
        
        cell?.EventName.text = event.eventName
        cell?.EventPrice.text = event.price
        cell?.eventId = event.eventID
        cell?.delegate = self
        
        return cell ?? UITableViewCell()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        EventTable.delegate = self
        EventTable.dataSource = self
        
        fetchUserEvents() // Fetch events created by the current user
    }
    
    // Implement the EventCellDelegate method for edit
    func didTapEditButton(eventID: String) {
        // Perform the segue to the EventPosting view controller
        performSegue(withIdentifier: "Fahad-EventEditing", sender: eventID)
    }

    // Prepare for segue to pass the eventID
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Fahad-EventEditing", let destinationVC = segue.destination as? EventEditViewController {
            if let eventID = sender as? String {
                destinationVC.eventID = eventID // Pass the eventID to the destination view controller
            }
        }
    }
    
    // Implement the EventCellDelegate method
    func didTapDeleteButton(eventID: String) {
        deleteEvent(eventID: eventID)
    }
    
    func deleteEvent(eventID: String) {
        db.collection("AddEvents").document(eventID).delete { error in
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
            } else {
                // Remove the event from the local array and reload the table
                self.events.removeAll { $0.eventID == eventID }
                self.fetchUserEvents()
            }
        }
    }
    
    
    // MARK: - Fetch User Events from Firestore
    func fetchUserEvents() {
        guard let userUID = userUID else { return }
        
        db.collection("AddEvents")
            .whereField("uid", isEqualTo: userUID) // Filter events by user UID
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error fetching events: \(error.localizedDescription)")
                    return
                }
                
                self?.events = querySnapshot?.documents.compactMap { document -> Event? in
                    let data = document.data()
                    let eventName = data["eventName"] as? String ?? ""
                    let price = data["price"] as? String ?? ""
                    let imagePath = data["ImagePath"] as? String ?? ""
                    
                    return Event(eventID: document.documentID, eventName: eventName, price: price, imagePath: imagePath, eventPage: self)
                } ?? []
                
                // Set filtered events to the fetched events
                self?.filteredEvents = self?.events ?? []
                
                // Reload table with user events
                self?.EventTable.reloadData()
            }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Function to fetch the image from Cloudinary
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            completion(image)
        }
        
        task.resume()
    }
    
    struct Event
    {
        var eventID: String
        var eventName: String
        var price: String
        var imagePath: String
        var eventPage: EventsViewController?
   }

}
