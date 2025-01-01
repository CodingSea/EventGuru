import UIKit
import FirebaseFirestore

class UsersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

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

        // Add the dropdown UIBarButtonItem
        addDropdownButton()

        // Fetch users from Firestore
        fetchUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh users list each time the view appears
        fetchUsers()
    }

    // MARK: - Fetch Users
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

    // MARK: - Add Dropdown UIBarButtonItem
    func addDropdownButton() {
        let dropdownButton = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(showDropdown))
        dropdownButton.tintColor = .systemBlue // Set the button text color
        self.navigationItem.rightBarButtonItem = dropdownButton
    }

    // MARK: - Dropdown Menu
    @objc func showDropdown() {
        let alertController = UIAlertController(title: "Filter Users", message: "Select a role", preferredStyle: .actionSheet)

        let roles = ["All", "Admin", "Event Organizer", "User"]
        for role in roles {
            alertController.addAction(UIAlertAction(title: role, style: .default, handler: { _ in
                self.filterUsers(by: role)

                // Update the UIBarButtonItem title
                if let barButtonItem = self.navigationItem.rightBarButtonItem {
                    barButtonItem.title = role
                }
            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }

    // MARK: - Filtering Logic
    func filterUsers(by role: String) {
        if role == "All" {
            filteredUsers = users
        } else if role == "Admin" {
            // Filter for both "Admin" and "Administrator"
            filteredUsers = users.filter {
                let userRole = $0["role"] as? String ?? ""
                return userRole == "Admin" || userRole == "Administrator"
            }
        } else {
            filteredUsers = users.filter { $0["role"] as? String == role }
        }
        tableView.reloadData()
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

        if let editButton = cell.viewWithTag(3) as? UIButton {
            editButton.tag = indexPath.row
            editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        }

        return cell
    }

    // MARK: - Edit Button Action
    @objc func editButtonTapped(_ sender: UIButton) {
        let rowIndex = sender.tag
        let user = filteredUsers[rowIndex]
        if let userId = user["uid"] as? String {
            print("Navigating to details with userId: \(userId)")

            // Create and navigate to UserDetailsViewController programmatically
            let storyboard = UIStoryboard(name: "AdminDash", bundle: nil)
            if let userDetailsVC = storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as? UserDetailsViewController {
                userDetailsVC.userId = userId
                self.navigationController?.pushViewController(userDetailsVC, animated: true)
            }
        }
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
