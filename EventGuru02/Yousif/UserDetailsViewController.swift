// UserDetailsViewController.swift
import UIKit

class UserDetailsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var joinDateLabel: UILabel!

    // MARK: - Properties
    var user: User?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Display user details
        if let user = user {
            nameLabel.text = user.name
            roleLabel.text = user.role
            locationLabel.text = user.location
            joinDateLabel.text = user.joinDate
        }
    }
}
