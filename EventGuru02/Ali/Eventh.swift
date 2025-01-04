import UIKit
import Firebase

class Eventh: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var historyData: [(action: String, ticketID: String)] = [] // Dynamic history data
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchHistory()
    }
    
    func fetchHistory() {
        // Fetch history from Firestore
        db.collection("history").order(by: "timestamp", descending: true).addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching history: \(error.localizedDescription)")
                return
            }
            
            self.historyData = []
            snapshot?.documents.forEach { document in
                let data = document.data()
                if let action = data["action"] as? String,
                   let ticketID = data["ticketID"] as? String {
                    self.historyData.append((action: action, ticketID: ticketID))
                }
            }
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let history = historyData[indexPath.row]
        cell.textLabel?.text = "\(history.action) Ticket (\(history.ticketID))"
        return cell
    }
}
