import UIKit
import FirebaseFirestore

class UserDetailsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var roleTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var joinDateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Properties
    var userId: String?
    let db = Firestore.firestore()
    var originalData: [String: Any] = [:]
    var datePicker: UIDatePicker! // For date input in ageTextField

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Enable editing by default
        configureEditingMode(isEditing: true)

        // Configure the date picker for birth field
        configureDatePicker()

        // Fetch user details from Firestore
        fetchUserDetails()
    }

    // MARK: - Configure Editing Mode
    func configureEditingMode(isEditing: Bool) {
        nameTextField.isUserInteractionEnabled = isEditing
        emailTextField.isUserInteractionEnabled = isEditing // Make email field non-editable
        ageTextField.isUserInteractionEnabled = isEditing
        joinDateTextField.isUserInteractionEnabled = false // Keep joinDate non-editable
        roleTextField.isUserInteractionEnabled = false // Keep role non-editable
        saveButton.isHidden = !isEditing // Show Save button in editing mode
    }

    // MARK: - Configure Date Picker
    func configureDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Calendar.current.date(from: DateComponents(year: 2004, month: 12, day: 31)) // Set maximum date to 2004
        datePicker.minimumDate = Calendar.current.date(from: DateComponents(year: 1900, month: 1, day: 1)) // Optional: Set minimum date to a realistic value

        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)

        // Set date picker as the input view for ageTextField
        ageTextField.inputView = datePicker

        // Add a toolbar with a "Done" button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissDatePicker))
        toolbar.setItems([doneButton], animated: true)
        ageTextField.inputAccessoryView = toolbar
    }

    @objc func datePickerValueChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        ageTextField.text = formatter.string(from: datePicker.date)
    }

    @objc func dismissDatePicker() {
        ageTextField.resignFirstResponder()
    }

    // MARK: - Fetch User Details
    func fetchUserDetails() {
        guard let userId = userId else {
            print("Error: User ID is nil")
            return
        }

        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }

            guard let data = document?.data() else {
                print("No data found for user.")
                return
            }

            DispatchQueue.main.async {
                self.originalData = data // Store the original data
                self.updateUI(with: data)
            }
        }
    }

    // MARK: - Update UI
    func updateUI(with data: [String: Any]) {
        nameTextField.text = data["username"] as? String ?? "Unknown"
        roleTextField.text = data["role"] as? String ?? "Unknown"
        emailTextField.text = data["email"] as? String ?? "Unknown" // Display email
        ageTextField.text = data["dateofbirth"] as? String ?? "Unknown"
        joinDateTextField.text = data["joinDate"] as? String ?? "Unknown"
    }

    // MARK: - Revert Unsaved Changes
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Revert text fields to original data if the user navigates back without saving
        if self.isMovingFromParent {
            self.updateUI(with: originalData)
        }
    }

    // MARK: - Save Button Action
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let userId = userId else {
            print("Error: User ID is nil")
            return
        }

        // Show confirmation popup
        let confirmationAlert = UIAlertController(
            title: "Confirm Save",
            message: "Are you sure you want to save these changes?",
            preferredStyle: .alert
        )
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        confirmationAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.saveUserDetails()
        }))
        present(confirmationAlert, animated: true)
    }

    // MARK: - Save User Details to Firestore
    func saveUserDetails() {
        guard let userId = userId else {
            print("Error: User ID is nil")
            return
        }

        let updatedData: [String: Any] = [
            "username": nameTextField.text ?? "",
            "email": emailTextField.text ?? "",
            "dateofbirth": ageTextField.text ?? ""
        ]

        db.collection("users").document(userId).updateData(updatedData) { error in
            if let error = error {
                print("Error saving user details: \(error.localizedDescription)")
                return
            }

            print("User details updated successfully.")
            DispatchQueue.main.async {
                self.originalData = updatedData // Update original data after saving
            }
        }
    }

    // MARK: - Delete Button Action
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let userId = userId else {
            print("Error: User ID is nil")
            return
        }

        let confirmationAlert = UIAlertController(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this account? This action cannot be undone.",
            preferredStyle: .alert
        )
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        confirmationAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteUser(userId: userId)
        }))
        present(confirmationAlert, animated: true)
    }

    func deleteUser(userId: String) {
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                return
            }

            print("User deleted successfully.")
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
