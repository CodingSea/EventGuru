import UIKit

class Histroy: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let options = ["AWS", "MOVEON", "2025", "SWIFT BASICS", "Learn how to Read"]
    let ticketIDs = ["ticket1", "ticket2", "ticket3", "ticket4", "ticket5"] // Adjusted to match options count
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBuyTicket",
           let destinationVC = segue.destination as? BuyTicket,
           let data = sender as? (ticketID: String, eventName: String) {
            destinationVC.ticketID = data.ticketID
            destinationVC.eventName = data.eventName // Pass the event name
        }
    }
}

// MARK: - UITableViewDelegate
extension Histroy: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTicketID = ticketIDs[indexPath.row]
        let selectedEventName = options[indexPath.row] // Get the corresponding event name
        performSegue(withIdentifier: "showBuyTicket", sender: (selectedTicketID, selectedEventName))
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
