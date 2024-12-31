import UIKit
import FirebaseAuth
import FirebaseFirestore

class AdminRegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phonenumberField: UITextField!
    @IBOutlet weak var dateofbirthField: UITextField!
    @IBOutlet weak var roleField: UITextField!

    // MARK: - Properties
    let db = Firestore.firestore()
    var selectedRole: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        roleField.isUserInteractionEnabled = false // Disable editing for role field
    }

    // MARK: - Role Dropdown
    @IBAction func showRoleDropdown(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Select Role", message: nil, preferredStyle: .actionSheet)
        let roles = ["Administrator", "Event Organizer"]

        for role in roles {
            alertController.addAction(UIAlertAction(title: role, style: .default, handler: { _ in
                self.selectedRole = role
                self.roleField.text = role
            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }

    // MARK: - Register Button Action
    @IBAction func registerAdmin(_ sender: UIButton) {
        if validateFields() {
            // Show confirmation popup
            let confirmationAlert = UIAlertController(
                title: "Confirm Registration",
                message: "Are you sure you want to create this admin account?",
                preferredStyle: .alert
            )
            confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            confirmationAlert.addAction(UIAlertAction(title: "Register", style: .default, handler: { _ in
                self.performRegistration()
            }))
            self.present(confirmationAlert, animated: true)
        }
    }

    // MARK: - Perform Registration
    func performRegistration() {
        guard let email = emailField.text,
              let password = passwordField.text,
              let username = usernameField.text,
              let phone = phonenumberField.text,
              let dateOfBirth = dateofbirthField.text,
              let role = selectedRole else { return }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                return
            }

            guard let user = authResult?.user else { return }

            let userData: [String: Any] = [
                "username": username,
                "email": email,
                "phone": phone,
                "uid": user.uid,
                "dateofbirth": dateOfBirth,
                "role": role
            ]

            self.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to store user data: \(error.localizedDescription)")
                } else {
                    self.showAlert(
                        title: "Success",
                        message: "Admin account created successfully.",
                        completion: {
                            self.navigationController?.popViewController(animated: true)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Validate Fields
    func validateFields() -> Bool {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let username = usernameField.text, !username.isEmpty,
              let phone = phonenumberField.text, !phone.isEmpty,
              let dateOfBirth = dateofbirthField.text, !dateOfBirth.isEmpty else {
            showAlert(title: "Validation Error", message: "All fields are required.")
            return false
        }

        if !isValidEmail(email) {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return false
        }

        if !isValidPassword(password) {
            showAlert(title: "Invalid Password", message: "Password must be at least 6 characters long.")
            return false
        }

        if !isValidPhone(phone) {
            showAlert(title: "Invalid Phone", message: "Please enter a valid phone number.")
            return false
        }

        if !isValidDateOfBirth(dateOfBirth) {
            showAlert(title: "Invalid Date of Birth", message: "Please enter a valid date of birth in YYYY/MM/DD format.")
            return false
        }

        if selectedRole == nil {
            showAlert(title: "Role Required", message: "Please select a role.")
            return false
        }

        return true
    }

    // MARK: - Helper Functions
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    func isValidPhone(_ phone: String) -> Bool {
        return phone.count >= 10
    }

    func isValidDateOfBirth(_ dateOfBirth: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.date(from: dateOfBirth) != nil
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        self.present(alert, animated: true)
    }
}
