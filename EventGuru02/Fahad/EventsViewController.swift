import UIKit
import FirebaseFirestore
import FirebaseAuth

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EventCellDelegate, EventEditDelegate {
    
    @IBOutlet weak var EventTable: UITableView!
    
    var isSegueActive = false // Track if a segue is in progress
    
    var db: Firestore!
    var events = [Event]() // All events
    var filteredEvents = [Event]() // Filtered events
    var userUID: String? {
        return Auth.auth().currentUser?.uid
    }
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
            print("Error: User UID is nil.")
            completion(nil)
            return
        }
        
        print("Fetching user role for UID: \(userUID)")
        db.collection("users").document(userUID).getDocument { document, error in
            if let error = error {
                print("Error fetching user role: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = document?.data() else {
                print("No data found for user.")
                completion(nil)
                return
            }

            let role = data["role"] as? String
            print("User role: \(role ?? "Unknown")")
            completion(role)
        }
    }
    
    // MARK: - Fetch User Events from Firestore
    func fetchUserEvents() {
        guard let userRole = userRole else {
            print("Error: User role is nil.")
            return
        }
        
        let query: Query
        if userRole == "Administrator" {
            print("Fetching all events for Administrator.")
            query = db.collection("AddEvents") // Fetch all events for admins
        } else {
            guard let userUID = userUID else {
                print("Error: User UID is nil.")
                return
            }
            print("Fetching events for User UID: \(userUID)")
            query = db.collection("AddEvents").whereField("uid", isEqualTo: userUID) // Fetch user's events
        }
        
        query.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            
            self?.events = []
            
            let group = DispatchGroup() // To handle asynchronous calls
            
            querySnapshot?.documents.forEach { document in
                let data = document.data()
                let eventName = data["eventName"] as? String ?? ""
                let imagePath = data["ImagePath"] as? String ?? ""
                let uid = data["uid"] as? String ?? ""
                
                // Ignore events with empty uid
                if uid.isEmpty {
                    print("Skipping event with empty UID: \(document.documentID)")
                    return
                }
                
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
                
                group.enter() // Enter the dispatch group for each event
                
                // Fetch the creator's username using the uid
                self?.db.collection("users").document(uid).getDocument { userDoc, error in
                    if let error = error {
                        print("Error fetching user info for UID (\(uid)): \(error.localizedDescription)")
                        group.leave()
                        return
                    }
                    
                    let creatorName = userDoc?.data()?["username"] as? String ?? "Unknown"
                    let event = Event(
                        eventID: document.documentID,
                        eventName: eventName,
                        status: status,
                        startDate: startDate,
                        endDate: endDate,
                        imagePath: imagePath,
                        creatorName: creatorName
                    )
                    
                    self?.events.append(event)
                    group.leave() // Leave the dispatch group after fetching the username
                }
            }
            
            group.notify(queue: .main) { // Notify when all async calls are done
                self?.filteredEvents = self?.events ?? []
                self?.EventTable.reloadData()
            }
        }
    }
    // MARK: - Table View Data Source and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? EventTableViewCell
        
        let event = filteredEvents[indexPath.row]
        
        // Set the existing connected elements
        cell?.EventImage.image = UIImage(named: "pp") // Placeholder image
        if let imageUrl = URL(string: event.imagePath) {
            fetchImage(from: imageUrl) { [weak tableView] image in
                DispatchQueue.main.async {
                    if let updatedCell = tableView?.cellForRow(at: indexPath) as? EventTableViewCell {
                        updatedCell.EventImage.image = image
                    }
                }
            }
        }
        cell?.EventName.text = event.eventName
        cell?.EventStatus.text = event.status
        cell?.eventId = event.eventID
        cell?.delegate = self
       
        let tagForCreatorName = 1001 
        if let creatorNameLabel = cell?.contentView.viewWithTag(tagForCreatorName) as? UILabel {
            // If the label already exists (cell reused), just update its text
            creatorNameLabel.text = "Created by: \(event.creatorName)"
        } else {
            // Create and add the CreatorName label dynamically
            let creatorNameLabel = UILabel()
            creatorNameLabel.tag = tagForCreatorName // Assign a unique tag
            creatorNameLabel.translatesAutoresizingMaskIntoConstraints = false
            creatorNameLabel.font = UIFont.systemFont(ofSize: 14)
            creatorNameLabel.textColor = .gray
            creatorNameLabel.text = "Created by: \(event.creatorName)"
            cell?.contentView.addSubview(creatorNameLabel)
            
            // Set constraints for the label
            NSLayoutConstraint.activate([
                creatorNameLabel.leadingAnchor.constraint(equalTo: cell!.EventName.leadingAnchor), // Align with EventName label
                creatorNameLabel.topAnchor.constraint(equalTo: cell!.EventStatus.bottomAnchor, constant: 5), // Below EventStatus label
                creatorNameLabel.trailingAnchor.constraint(equalTo: cell!.contentView.trailingAnchor, constant: -10),
                creatorNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: cell!.contentView.bottomAnchor, constant: -10) // Avoid overlap
            ])
        }
        
        return cell ?? UITableViewCell()
    }
    
    // MARK: - Edit Event
    func didTapEditButton(eventID: String) {
        if !isSegueActive {
            isSegueActive = true
            if eventID.isEmpty {
                print("Error: eventID is empty.")
                return
            }
            performSegue(withIdentifier: "Fahad-EventEditing", sender: eventID)
        }
    }
    
    func didUpdateEvent() {
        fetchUserEvents() // Fetch events after updating
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Fahad-EventEditing", let destinationVC = segue.destination as? EventEditViewController {
            if let eventID = sender as? String {
                destinationVC.delegate = self
                destinationVC.eventID = eventID
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSegueActive = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isSegueActive = false
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
        var creatorName: String // New field for creator's username
    }
}
