//
//  EventsViewController.swift
//  EventGuru02
//
//  Created by Fahad on 03/01/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EventCellDelegate, EventEditDelegate {
    
    @IBOutlet weak var EventTable: UITableView!
    
    var isSegueActive = false // Track if a segue is in progress
    
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
        
        // Set a placeholder image while loading
        cell?.EventImage.image = UIImage(named: "pp") // Use a placeholder
        
        // Load the image from Cloudinary
        if let imageUrl = URL(string: event.imagePath) {
            // Use a unique identifier to avoid loading the wrong image
            let taskIdentifier = indexPath.row
            fetchImage(from: imageUrl) { [weak self, weak tableView] image in
                DispatchQueue.main.async {
                    // Ensure the cell is still visible and matches the task identifier
                    if let updatedCell = tableView?.cellForRow(at: indexPath) as? EventTableViewCell, indexPath.row == taskIdentifier {
                        cell?.EventImage.image = image // Set the loaded image
                    }
                }
            }
        }
        
        cell?.EventName.text = event.eventName
        cell?.EventStatus.text = event.status
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
        // Check if a segue is already active
        if !isSegueActive {
            isSegueActive = true
            performSegue(withIdentifier: "Fahad-EventEditing", sender: eventID)
        }
    }
    
    func didUpdateEvent() {
        fetchUserEvents() // Fetch events created by the current user
    }

    // Prepare for segue to pass the eventID
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Fahad-EventEditing", let destinationVC = segue.destination as? EventEditViewController {
            if let eventID = sender as? String {
                destinationVC.delegate = self // Set the delegate
                destinationVC.eventID = eventID // Pass the eventID to the destination view controller
            }
        }
    }
    
    // Reset the flag when returning from the segue
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSegueActive = false // Reset the flag
        fetchUserEvents() // Fetch events every time the view appears
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isSegueActive = false // Reset the flag when view disappears
    }
    
    
    // Implement the EventCellDelegate method
    func didTapDeleteButton(eventID: String) {
        // Show confirmation alert
        let alert = UIAlertController(title: "Delete Event",
                                      message: "Are you sure you want to delete this event?",
                                      preferredStyle: .alert)

        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteEvent(eventID: eventID) // Call the delete method if confirmed
        }))

        // Present the alert
        self.present(alert, animated: true, completion: nil)
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
                    let imagePath = data["ImagePath"] as? String ?? ""
                    
                    // Parse the start and end dates
                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Determine the status based on the current date
                    let currentDate = Date()
                    let status: String
                    
                    if currentDate < startDate {
                        status = "coming-soon"
                    } else if currentDate > endDate {
                        status = "completed"
                    } else {
                        status = "on-going"
                    }
                    
                    return Event(eventID: document.documentID, eventName: eventName, status: status, startDate: startDate, endDate: endDate, imagePath: imagePath)
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
    
    
    var imageCache = NSCache<NSString, UIImage>()
    // Function to fetch the image from Cloudinary
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check the cache first
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        
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
            
            // Cache the image
            self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
            
            completion(image)
        }
        
        task.resume()
    }
    
    struct Event
    {
        var eventID: String
        var eventName: String
        var status: String
        var startDate: Date
        var endDate: Date
        var imagePath: String
   }

}
