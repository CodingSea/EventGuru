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
    var userRole: String? // User role (e.g., "Administrator" or "User")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        db = Firestore.firestore()
        EventTable.delegate = self
        EventTable.dataSource = self
        
        // Fetch the user's role and events
        fetchUserRole { [weak self] role in
            self?.userRole = role
            self?.fetchUserEvents() // Fetch events after determining the role
        }
    }
    
    // MARK: - Fetch User Role
    func fetchUserRole(completion: @escaping (String?) -> Void) {
        guard let userUID = userUID else {
            completion(nil)
            return
        }
        
        db.collection("users").document(userUID).getDocument { document, error in
            if let error = error {
                print("Error fetching user role: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let role = document?.data()?["role"] as? String
            completion(role)
        }
    }
    
    // MARK: - Fetch User Events from Firestore
    func fetchUserEvents() {
        guard let userRole = userRole else {
            print("Error: User role is nil.")
            return
        }
        
        // Fetch all events if the user is an Administrator
        let query: Query
        if userRole == "Administrator" {
            query = db.collection("AddEvents") // Fetch all events
        } else {
            guard let userUID = userUID else { return }
            query = db.collection("AddEvents").whereField("uid", isEqualTo: userUID) // Fetch only user's events
        }
        
        query.getDocuments { [weak self] (querySnapshot, error) in
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
            
            // Reload table with events
            self?.EventTable.reloadData()
        }
    }
    
    // MARK: - Table View Data Source and Delegate
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
                        updatedCell.EventImage.image = image // Set the loaded image
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
    
    // MARK: - Edit Event
    func didTapEditButton(eventID: String) {
        // Check if a segue is already active
        if !isSegueActive {
            isSegueActive = true
            performSegue(withIdentifier: "Fahad-EventEditing", sender: eventID)
        }
    }
    
    func didUpdateEvent() {
        fetchUserEvents() // Fetch events after updating
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSegueActive = false // Reset the flag
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isSegueActive = false // Reset the flag when view disappears
    }
    
    // MARK: - Delete Event
    func didTapDeleteButton(eventID: String) {
        let alert = UIAlertController(title: "Delete Event",
                                      message: "Are you sure you want to delete this event?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteEvent(eventID: eventID)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteEvent(eventID: String) {
        db.collection("AddEvents").document(eventID).delete { error in
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
            } else {
                self.events.removeAll { $0.eventID == eventID }
                self.fetchUserEvents()
            }
        }
    }
    
    // MARK: - Fetch Image
    var imageCache = NSCache<NSString, UIImage>()
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
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
            
            self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
            completion(image)
        }
        task.resume()
    }
    
    struct Event {
        var eventID: String
        var eventName: String
        var status: String
        var startDate: Date
        var endDate: Date
        var imagePath: String
    }
}
