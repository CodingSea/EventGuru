import UIKit

class DashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var price: UILabel!
    
    // Closure for the reuse button action
    var reuseButtonAction: (() -> Void)?

    @IBAction func reuseButtonTapped(_ sender: UIButton) {
        // Call the closure when the button is tapped
        reuseButtonAction?()
    }
}
