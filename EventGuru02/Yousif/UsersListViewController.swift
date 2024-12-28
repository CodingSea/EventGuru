import UIKit
import FirebaseFirestore

class UsersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dropdownButton: UIButton!

    // MARK: - Properties
    let db = Firestore.firestore()
    var users: [[String: Any]] = [] // Array of dictionaries to hold user data
    var filteredUsers: [[String: Any]] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set table view data source and delegate
        tableView.dataSource = self
        tableView.delegate = self

        // Set search bar delegate
        searchBar.delegate = self

        // Style dropdown button
        styleDropdownButton()

        // Fetch users from Firestore
        fetchUsers()
    }

    func fetchUsers() {
        db.collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            self.users = documents.map { $0.data() } // Store user data as dictionaries
            self.filteredUsers = self.users
            self.tableView.reloadData()
        }
    }

    // MARK: - Styling
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
            nameLabel.text = user["username"] as? String ?? "Unknown"
        }

        if let roleLabel = cell.viewWithTag(2) as? UILabel {
            roleLabel.text = user["role"] as? String ?? "Unknown"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]
        if let userId = user["uid"] as? String {
            performSegue(withIdentifier: "showUserDetails", sender: userId)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserDetails",
           let destinationVC = segue.destination as? UserDetailsViewController,
           let userId = sender as? String {
            destinationVC.userId = userId
        }
    }

    // MARK: - Dropdown Menu
    @IBAction func showDropdown(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Filter Users", message: "Select a role", preferredStyle: .actionSheet)

        let roles = ["All", "Admin", "Event Organizer", "User"]
        for role in roles {
            alertController.addAction(UIAlertAction(title: role, style: .default, handler: { _ in
                self.filterUsers(by: role)
                self.dropdownButton.setTitle(role, for: .normal)
            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }

    // MARK: - Filtering Logic
    func filterUsers(by role: String) {
        if role == "All" {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { $0["role"] as? String == role }
        }
        tableView.reloadData()
    }

    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter {
                ($0["username"] as? String ?? "").lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
