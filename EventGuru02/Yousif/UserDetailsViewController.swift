import UIKit
import FirebaseFirestore

class UserDetailsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var roleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var joinDateTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Properties
    var userId: String?
    let db = Firestore.firestore()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable editing for specific fields
        [nameTextField, roleTextField, locationTextField, ageTextField, joinDateTextField].forEach {
            $0?.isUserInteractionEnabled = false
        }

        setupActivityIndicator()
        fetchUserDetails()
    }

    // MARK: - Setup Activity Indicator
    func setupActivityIndicator() {
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }

    // MARK: - Fetch User Details
    func fetchUserDetails(retryCount: Int = 3) {
        guard let userId = userId else {
            print("Error: User ID is nil")
            return
        }

        activityIndicator.startAnimating()

        db.collection("users").document(userId).getDocument { (document, error) in
            self.activityIndicator.stopAnimating()

            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")

                if retryCount > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.fetchUserDetails(retryCount: retryCount - 1)
                    }
                } else {
                    self.showErrorAlert(message: "Failed to load user details after multiple attempts.")
                }
                return
            }

            guard let data = document?.data() else {
                print("User document not found.")
                self.showErrorAlert(message: "User not found.")
                return
            }

            DispatchQueue.main.async {
                self.updateUI(with: data)
            }
        }
    }

    // MARK: - Update UI
    func updateUI(with data: [String: Any]) {
        nameTextField.text = data["username"] as? String ?? "Unknown"
        roleTextField.text = data["role"] as? String ?? "Unknown"
        locationTextField.text = data["location"] as? String ?? "Unknown"
        ageTextField.text = data["dateofbirth"] as? String ?? "Unknown"
        joinDateTextField.text = data["joinDate"] as? String ?? "Unknown"
    }

    // MARK: - Delete Account
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let userId = userId else {
            print("Error: User ID is nil")
            return
        }

        // Show confirmation alert
        let confirmationAlert = UIAlertController(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this account? This action cannot be undone.",
            preferredStyle: .alert
        )
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        confirmationAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteAccount(with: userId)
        }))
        present(confirmationAlert, animated: true)
    }

    func deleteAccount(with userId: String) {
        activityIndicator.startAnimating()

        db.collection("users").document(userId).delete { error in
            self.activityIndicator.stopAnimating()

            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                self.showErrorAlert(message: "Failed to delete user.")
            } else {
                print("User deleted successfully.")
                NotificationCenter.default.post(name: NSNotification.Name("UserDeleted"), object: nil)
                self.showSuccessAlert(message: "User deleted successfully.") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    // MARK: - Show Alerts
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func showSuccessAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        self.present(alert, animated: true)
    }
}
