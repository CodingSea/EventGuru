//
//  History.swift
//  EventGuru02
//
//  Created by Ali Juma on 03/01/2025.
//

import UIKit

class Histroy: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Define the options for the table view
    let options = ["Buy Ticket", "Cancel Ticket", "Notify Me if Available"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the table view's delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register the UITableViewCell if not using a storyboard prototype cell
        // Uncomment the following line if you don't use a prototype cell in storyboard:
        // tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
    }
}

// MARK: - UITableViewDelegate
extension Histroy: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle navigation based on selected row
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "showBuyTicket", sender: self)
        case 1:
            performSegue(withIdentifier: "showCancelTicket", sender: self)
        case 2:
            performSegue(withIdentifier: "showNotifyMe", sender: self)
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource
extension Histroy: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count // Number of rows = options count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row] // Set the cell text
        return cell
    }
}

// MARK: - Pass Data (Optional)
extension Histroy {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBuyTicket" {
            // Pass data to BuyTicketViewController if needed
        } else if segue.identifier == "showCancelTicket" {
            // Pass data to CancelTicketViewController if needed
        } else if segue.identifier == "showNotifyMe" {
            // Pass data to NotifyMeViewController if needed
        }
    }
}
