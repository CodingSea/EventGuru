import UIKit

class Histroy: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let options = ["Buy Ticket", "Cancel Ticket", "Notify Me if Available"]
    let ticketIDs = ["ticket1", "ticket2", "ticket3"] // Example ticket IDs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBuyTicket",
           let destinationVC = segue.destination as? BuyTicket,
           let ticketID = sender as? String {
            destinationVC.ticketID = ticketID
        } else if segue.identifier == "showCancelTicket",
                  let destinationVC = segue.destination as? CancelTicket,
                  let ticketID = sender as? String {
            destinationVC.ticketID = ticketID
        }
    }
}

// MARK: - UITableViewDelegate
extension Histroy: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTicketID = ticketIDs[indexPath.row] // Get the ticket ID
        
        switch indexPath.row {
        case 0: // Buy Ticket
            performSegue(withIdentifier: "showBuyTicket", sender: selectedTicketID)
        case 1: // Cancel Ticket
            performSegue(withIdentifier: "showCancelTicket", sender: selectedTicketID)
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource
extension Histroy: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
}
