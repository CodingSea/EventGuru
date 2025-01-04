import UIKit
import Firebase

class Eventh: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var historyData: [(action: String, ticketID: String)] = [] // Dynamic history data
    let db = Firestore.firestore()
    var listener: ListenerRegistration? // To manage Firestore listener
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchHistory()
    }
    
    deinit {
        // Remove Firestore listener when the view controller is deallocated
        listener?.remove()
    }
    
    func fetchHistory() {
        // Add Firestore snapshot listener
        listener = db.collection("history")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching history: \(error.localizedDescription)")
                    return
                }
                
                self.historyData = [] // Reset history data
                
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let action = data["action"] as? String,
                       action == "Buy",
                       let ticketID = data["ticketID"] as? String {
                        self.historyData.append((action: action, ticketID: ticketID))
                    }
                }
                
                // Reload tableView data on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension Eventh: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") else {
            fatalError("Cell with identifier 'historyCell' not found")
        }
        let history = historyData[indexPath.row]
        cell.textLabel?.text = "\(history.action) Ticket (\(history.ticketID))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect row after tap
        let selectedTicket = historyData[indexPath.row]
        performSegue(withIdentifier: "showCancelTicket", sender: selectedTicket)
    }
}

// MARK: - Segue Preparation
extension Eventh {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCancelTicket",
           let destinationVC = segue.destination as? CancelTicket,
           let selectedTicket = sender as? (action: String, ticketID: String) {
            destinationVC.ticketID = selectedTicket.ticketID
        }
    }
}
