import UIKit
import Firebase

class Histroy: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var options: [String] = []
    var ticketIDs: [String] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchDataFromFirestore()
    }
    
    // MARK: - Fetch Data from Firestore
    func fetchDataFromFirestore() {
        db.collection("AddEvents").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }
            
            // Map Firestore data to options and ticketIDs
            self.options = documents.compactMap { $0.data()["eventName"] as? String }
            self.ticketIDs = documents.map { $0.documentID }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBuyTicket",
           let destinationVC = segue.destination as? BuyTicket,
           let eventData = sender as? [String: Any] {
            destinationVC.eventData = eventData
            destinationVC.ticketID = eventData["ticketID"] as? String
            destinationVC.eventName = eventData["eventName"] as? String
        }
    }
}

// MARK: - UITableViewDelegate
extension Histroy: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTicketID = ticketIDs[indexPath.row]
        let selectedEventName = options[indexPath.row]
        
        print("Selected Ticket ID: \(selectedTicketID), Event Name: \(selectedEventName)")
        
        // Fetch event data from Firestore
        db.collection("AddEvents").document(selectedTicketID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching event data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("Event document does not exist.")
                return
            }
            
            print("Fetched event data: \(data)")
            
            // Add ticketID and eventName to the data dictionary
            var eventData = data
            eventData["ticketID"] = selectedTicketID
            eventData["eventName"] = selectedEventName
            
            // Perform segue and pass the data
            self.performSegue(withIdentifier: "showBuyTicket", sender: eventData)
        }
    }
}

// MARK: - UITableViewDataSource
extension Histroy: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
}
