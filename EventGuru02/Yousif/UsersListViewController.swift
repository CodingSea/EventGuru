import UIKit

class UsersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dropdownButton: UIButton!

    // MARK: - Properties
    var users: [User] = [
        User(name: "User 1", role: "Admin", location: "Bahrain, Muharraq", joinDate: "2024/1/1"),
        User(name: "User 2", role: "Event Organizer", location: "Bahrain, Riffa", joinDate: "2024/1/2"),
        User(name: "User 3", role: "User", location: "Bahrain, Isa Town", joinDate: "2024/1/3")
    ]

    var filteredUsers: [User] = []


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self

        // Set search bar delegate
        searchBar.delegate = self

        // Initialize filteredUsers with all users
        filteredUsers = users
    }
    func filterUsers(by role: String) {
        if role == "All" {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { $0.role == role }
        }
        tableView.reloadData()
    }

    func styleDropdownButton() {
           dropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
           dropdownButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
           dropdownButton.titleLabel?.adjustsFontSizeToFitWidth = true
           dropdownButton.titleLabel?.minimumScaleFactor = 0.5
           dropdownButton.setTitle("All", for: .normal)
       }
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = filteredUsers[indexPath.row]

        if let nameLabel = cell.viewWithTag(1) as? UILabel {
            nameLabel.text = user.name
        }

        if let roleLabel = cell.viewWithTag(2) as? UILabel {
            roleLabel.text = user.role
        }

        return cell
    }

    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Show all users when the search text is empty
            filteredUsers = users
        } else {
            // Filter users by their name
            filteredUsers = users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }

    @IBAction func showDropdown(_ sender: Any) {
        let alertController = UIAlertController(title: "Filter Users", message: "Select a role", preferredStyle: .actionSheet)

        let roles = ["All", "Admin", "Event Organizer", "User"]
        for role in roles {
            alertController.addAction(UIAlertAction(title: role, style: .default, handler: { _ in
                // Apply filtering logic
                self.filterUsers(by: role)

                // Update the dropdown button title
                if let button = sender as? UIButton {
                    button.setTitle(role, for: .normal)
                }
                if let button = sender as? UIButton {
                    print("Updating button title to: \(role)")
                    button.setTitle(role, for: .normal)
                }

            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true)
    }





    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Dismiss the keyboard when the search button is clicked
        searchBar.resignFirstResponder()
    }
}
