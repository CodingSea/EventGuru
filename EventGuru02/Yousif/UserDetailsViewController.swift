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
        nameTextField.isUserInteractionEnabled = false
        roleTextField.isUserInteractionEnabled = false
        locationTextField.isUserInteractionEnabled = false
        ageTextField.isUserInteractionEnabled = false
        joinDateTextField.isUserInteractionEnabled = false

        setupActivityIndicator()
        fetchUserDetails()
    }

    // MARK: - Setup Activity Indicator
    func setupActivityIndicator() {
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }

    // MARK: - Fetch User Details with Retry
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
                print("User document not found for ID: \(userId)")
                if retryCount > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.fetchUserDetails(retryCount: retryCount - 1)
                    }
                } else {
                    self.showErrorAlert(message: "User data not found.")
                }
                return
            }

            DispatchQueue.main.async {
                self.nameTextField.text = data["username"] as? String ?? "Unknown"
                self.roleTextField.text = data["role"] as? String ?? "Unknown"
                self.locationTextField.text = data["location"] as? String ?? "Unknown"
                
                // Handle Date of Birth and calculate age
                if let dateOfBirth = data["dateofbirth"] as? String {
                    self.ageTextField.text = self.calculateAge(from: dateOfBirth)
                } else {
                    self.ageTextField.text = "Unknown"
                }
                
                self.joinDateTextField.text = data["joinDate"] as? String ?? "Unknown"
            }
        }
    }

    // MARK: - Calculate Age
    func calculateAge(from dateOfBirth: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let birthDate = dateFormatter.date(from: dateOfBirth) else {
            return "Invalid Date"
        }

        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return "\(ageComponents.year ?? 0)"
    }

    // MARK: - Save Changes
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let userId = userId else {
            print("Error: User ID is nil")
            return
        }

        let updatedDetails: [String: Any] = [
            "username": nameTextField.text ?? "",
            "role": roleTextField.text?.isEmpty == false ? roleTextField.text ?? "Unknown" : "Unknown",
            "location": locationTextField.text ?? "",
            "joinDate": joinDateTextField.text ?? ""
        ]

        activityIndicator.startAnimating()

        db.collection("users").document(userId).updateData(updatedDetails) { error in
            self.activityIndicator.stopAnimating()

            if let error = error {
                print("Error updating user details: \(error.localizedDescription)")
                self.showErrorAlert(message: "Failed to update user details.")
            } else {
                print("User details updated successfully.")
                self.showSuccessAlert(message: "User details updated successfully.")
            }
        }
    }

    // MARK: - Delete Account
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let userId = userId else {
            print("Error: User ID is nil")
            return
        }

        activityIndicator.startAnimating()

        db.collection("users").document(userId).delete { error in
            self.activityIndicator.stopAnimating()

            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                self.showErrorAlert(message: "Failed to delete user.")
            } else {
                print("User deleted successfully.")
                let alert = UIAlertController(title: "Success", message: "User deleted successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Show Alerts
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
