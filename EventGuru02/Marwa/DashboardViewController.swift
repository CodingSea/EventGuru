/*

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Sample data for table
    var events: [[String: String]] = [
        ["eventName": "Birthday Party", "price": "10 BHD", "reuse": "Reuse"],
        ["eventName": "Tech Conference", "price": "20 BHD", "reuse": "Reuse"],
        ["eventName": "Music Festival", "price": "15 BHD", "reuse": "Reuse"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
/*    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DashboardTableViewCell else {
            fatalError("Unable to dequeue DashboardTableViewCell")
        }
        
        // Configure the cell
        let event = events[indexPath.row]
        cell.eventName.text = event["eventName"]
        cell.price.text = event["price"]
        cell.reuse.setTitle(event["reuse"], for: .normal)
        
        // Add target for the reuse button
        cell.reuse.tag = indexPath.row
        cell.reuse.addTarget(self, action: #selector(handleReuseButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
   */
    // MARK: - Reuse Button Action
    
    
    
  /*/  @IBAction func handleReuseButtonTapped(_ sender: Any) {
        let selectedEvent = events[(sender as AnyObject).tag]
        print("Reuse button tapped for event: \(selectedEvent["eventName"] ?? "Unknown")")
        
        // Navigate to Event Editing screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let eventEditingVC = storyboard.instantiateViewController(withIdentifier: "EventEditingViewController") as? EventEditingViewController {
            eventEditingVC.selectedEvent = selectedEvent // Pass selected event details
            self.navigationController?.pushViewController(eventEditingVC, animated: true)
        }
    }*/
}

*/
