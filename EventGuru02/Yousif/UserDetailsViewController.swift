import UIKit
import FirebaseFirestore

class UserDetailsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var joinDateLabel: UILabel!

    // MARK: - Properties
    let db = Firestore.firestore()
    var userId: String? // User ID passed from UsersListViewController

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userId = userId {
            print("User ID passed: \(userId)")
            fetchUserDetails(userId: userId)
        } else {
            print("Error: userId is nil")
        }
    }

    // MARK: - Fetch User Details
    func fetchUserDetails(userId: String) {
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }

            guard let data = document?.data() else {
                print("User document not found for ID: \(userId)")
                return
            }

            // Safely update the UI
            DispatchQueue.main.async {
                self.nameLabel.text = data["username"] as? String ?? "Unknown"
                self.roleLabel.text = data["role"] as? String ?? "Unknown"
                self.locationLabel.text = data["location"] as? String ?? "Unknown"
                self.joinDateLabel.text = data["joinDate"] as? String ?? "Unknown"
            }
        }
    }
}
