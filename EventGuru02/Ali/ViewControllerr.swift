import UIKit

class ViewControllerr: UIViewController {

  

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
    
    
  

 

        
      @IBOutlet weak var thumbsUpImageView: UIImageView!

      // Boolean to track whether thumbs up is filled or not
      var isThumbsUpFilled = false

      override func viewDidLoad() {
          super.viewDidLoad()

          // Set the initial image (unfilled thumbs up)
          thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup")  // Unfilled thumbs-up symbol

          // Enable user interaction on the UIImageView
          thumbsUpImageView.isUserInteractionEnabled = true

          // Add tap gesture recognizer to handle the tap
          let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleThumbsUpTap))
          thumbsUpImageView.addGestureRecognizer(tapGestureRecognizer)
      }

      // Handle the tap event
      @objc func handleThumbsUpTap() {
          // Toggle between filled and unfilled thumbs up
          isThumbsUpFilled.toggle()

          // Update the image based on the state
          if isThumbsUpFilled {
              thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup.fill")  // Filled thumbs-up symbol
          } else {
              thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup")  // Unfilled thumbs-up symbol
          }
      }
  }

    
    
    
    


    
    
    

