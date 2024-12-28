import UIKit

class ViewControllerr: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // Buy Ticket Action
    @IBAction func BuyTicket(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Ticket Purchase",
            message: "Are you sure you want to buy this ticket?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Ticket purchased!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Purchase cancelled.")
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // Cancel Reservation Action
    @IBAction func CancelReservation(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Cancel Reservation",
            message: "Are you sure you want to cancel this ticket?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Ticket canceled!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel reservation cancelled.")
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Notify User Action
    @IBAction func Notify(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Notify if Available",
            message: "Are you sure you want an Email to be sent once tickets are available?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Email will be sent!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Email notification cancelled.")
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
