import UIKit

class BuyTicket: UIViewController {
    
    @IBOutlet weak var Like: UIImageView!
    @IBOutlet weak var Dislike: UIImageView!
    @IBOutlet weak var BookMark: UIImageView!
    @IBOutlet weak var ReportIcon: UIImageView!
    
    var isThumbsUpFilled = false
    var isDislikeFilled = false
    var isBookmarkFilled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Like (thumbs up) image and gesture
        Like.image = UIImage(systemName: "hand.thumbsup")
        Like.isUserInteractionEnabled = true
        let likeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLikeTap))
        Like.addGestureRecognizer(likeTapGestureRecognizer)
        
        // Initialize Dislike image and gesture
        Dislike.image = UIImage(systemName: "hand.thumbsdown")
        Dislike.isUserInteractionEnabled = true
        let dislikeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDislikeTap))
        Dislike.addGestureRecognizer(dislikeTapGestureRecognizer)
        
        // Initialize Bookmark image and gesture
        BookMark.image = UIImage(systemName: "bookmark")
        BookMark.isUserInteractionEnabled = true
        let bookmarkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBookmarkTap))
        BookMark.addGestureRecognizer(bookmarkTapGestureRecognizer)
        
        // Initialize ReportIcon gesture
        ReportIcon.isUserInteractionEnabled = true
        let reportTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reportIconTapped))
        ReportIcon.addGestureRecognizer(reportTapGestureRecognizer)
    }
    
    @objc func handleLikeTap() {
        isThumbsUpFilled.toggle()
        Like.image = UIImage(systemName: isThumbsUpFilled ? "hand.thumbsup.fill" : "hand.thumbsup")
    }
    
    @objc func handleDislikeTap() {
        isDislikeFilled.toggle()
        Dislike.image = UIImage(systemName: isDislikeFilled ? "hand.thumbsdown.fill" : "hand.thumbsdown")
    }
    
    @objc func handleBookmarkTap() {
        isBookmarkFilled.toggle()
        BookMark.image = UIImage(systemName: isBookmarkFilled ? "bookmark.fill" : "bookmark")
    }
    
    @IBAction func buyTicket(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Ticket Purchase",
            message: "Are you sure you want to buy this ticket?",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { _ in
            print("Ticket purchased successfully!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func reportIconTapped() {
        // To avoid UI lag, ensure this is on the main thread
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: "Report Issue",
                message: "Please describe the issue you want to report:",
                preferredStyle: .alert
            )
            
            alertController.addTextField { textField in
                textField.placeholder = "Describe the issue"
                textField.font = UIFont.systemFont(ofSize: 14)
            }
            
            let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
                let reportText = alertController.textFields?.first?.text
                print("User submitted a report: \(reportText ?? "")")
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(submitAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
