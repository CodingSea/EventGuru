import UIKit
import FirebaseFirestore
import FirebaseCore

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    // Firestore instance
    var db: Firestore!
    var events: [[String: Any]] = [] // Array to store Firestore data

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up tableView
        tableView.delegate = self
        tableView.dataSource = self

        // Initialize Firestore
        db = Firestore.firestore()

        // Fetch data from Firestore
        fetchEventsFromFirestore()
    }

    // MARK: - Fetch Data from Firestore
    private func fetchEventsFromFirestore() {
        print("Fetching events from Firestore...")

        db.collection("AddEvents").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found in Firestore.")
                return
            }

            // Debug: Log fetched data
            self.events = documents.map { $0.data() }
            print("Fetched events: \(self.events)")

            DispatchQueue.main.async {
                self.tableView.reloadData()
                print("Reloaded table view with \(self.events.count) events")
            }
        }
    }

    // MARK: - UITableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DashboardTableViewCell else {
            fatalError("Unable to dequeue DashboardTableViewCell")
        }

        // Fetch event data
        let event = events[indexPath.row]
        cell.eventName.text = event["eventName"] as? String ?? "Unknown"
        cell.price.text = event["price"] as? String ?? "N/A"

        // Fetch and set image from Cloudinary
        if let imageUrl = event["image"] as? String {
            DispatchQueue.global().async {
                if let image = GetImage(string: imageUrl) {
                    DispatchQueue.main.async {
                        cell.eventImage.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.eventImage.image = UIImage(named: "default_image") // Placeholder
                    }
                }
            }
        } else {
            cell.eventImage.image = UIImage(named: "default_image") // Placeholder
        }

        // Set up the reuse button action using a closure
        cell.reuseButtonAction = { [weak self] in
            guard let self = self else { return }
            self.reuseButtonTapped(for: indexPath.row)
        }

        return cell
    }

    // MARK: - Reuse Button Action
    private func reuseButtonTapped(for index: Int) {
        let selectedEvent = events[index]
        print("Reuse button tapped for event: \(selectedEvent)")

        // Perform the segue to the EventListingViewController
        performSegue(withIdentifier: "showEventListing", sender: selectedEvent)
    }

    // Prepare for segue to pass data
  /*  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventListing" {
            if let destinationVC = segue.destination as? EventListingViewController,
               let event = sender as? [String: Any] {
                // Pass the selected event data to the EventListingViewController
                destinationVC.eventData = event
            } else {
                print("Error: Could not cast destination view controller or sender")
            }
        }
    }*/
}
