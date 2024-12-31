import UIKit
import FirebaseFirestore
import FirebaseCore

class ExploreViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    // Data arrays
    var filteredEvents: [[String: Any]] = []
    var allEvents: [[String: Any]] = []

    // Firestore instance
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ExploreViewController loaded")

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self

        db = Firestore.firestore()

        print("Testing Firestore connection...")
            db.collection("AddEvents").getDocuments { snapshot, error in
                if let error = error {
                    print("Firestore connection failed: \(error.localizedDescription)")
                } else {
                    print("Firestore connection successful: \(snapshot?.documents.count ?? 0) documents retrieved.")
                }
        }

        fetchEventsFromFirestore()
    }


    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? ExploreTableViewCell else {
            fatalError("Unable to dequeue ExploreTableViewCell")
        }

        let event = filteredEvents[indexPath.row]

        // Populate the cell with event data
        cell.eventName.text = event["eventName"] as? String ?? "Unknown"
        cell.price.text = event["price"] as? String ?? "0 BHD"

        // Fetch and display the image
        if let imageUrl = event["image"] as? String {
            // Download image from Cloudinary
            DispatchQueue.global().async {
                if let image = GetImage(string: imageUrl) {
                    DispatchQueue.main.async {
                        cell.eventImage.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.eventImage.image = UIImage(named: "default_image") // Placeholder image
                    }
                }
            }
        } else {
            cell.eventImage.image = UIImage(named: "default_image") // Placeholder image
        }

        return cell
    }


    // MARK: - Firestore Fetching
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

            print("Fetched \(documents.count) documents from Firestore.")

            // Process each document
            self.allEvents = documents.map { $0.data() }
            print("All Events: \(self.allEvents)")

            self.filteredEvents = self.allEvents

            DispatchQueue.main.async {
                print("Reloading table view with \(self.filteredEvents.count) events")
                self.tableView.reloadData()
            }
        }
    }


    // MARK: - Search Bar Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredEvents = allEvents
        } else {
            filteredEvents = allEvents.filter { event in
                let eventName = event["eventName"] as? String ?? ""
                return eventName.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredEvents = allEvents
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    // MARK: - Filters
       @IBAction func applyFiltersTapped(_ sender: Any) {
           let filterAlert = UIAlertController(title: "Apply Filters", message: "Choose a filter", preferredStyle: .actionSheet)

           filterAlert.addAction(UIAlertAction(title: "Show All", style: .default, handler: { _ in
               self.filteredEvents = self.allEvents
               self.tableView.reloadData()
           }))

           filterAlert.addAction(UIAlertAction(title: "Category", style: .default, handler: { _ in
               self.showCategoryFilter()
           }))

           filterAlert.addAction(UIAlertAction(title: "Price", style: .default, handler: { _ in
               self.showPriceFilter()
           }))

           filterAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

           present(filterAlert, animated: true, completion: nil)
       }

       private func showCategoryFilter() {
           let categoryAlert = UIAlertController(title: "Category", message: "Select a category", preferredStyle: .alert)

           let uniqueCategories = Array(Set(allEvents.compactMap { $0["category"] as? String }))
           for category in uniqueCategories {
               categoryAlert.addAction(UIAlertAction(title: category, style: .default, handler: { action in
                   self.filterByCategory(action.title ?? "")
               }))
           }

           categoryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           present(categoryAlert, animated: true, completion: nil)
       }

       private func showPriceFilter() {
           let priceAlert = UIAlertController(title: "Price", message: "Select a price range", preferredStyle: .alert)

           let priceRanges = ["0-10 BHD", "10-20 BHD", "20-30 BHD"]
           for price in priceRanges {
               priceAlert.addAction(UIAlertAction(title: price, style: .default, handler: { action in
                   self.filterByPriceRange(action.title ?? "")
               }))
           }

           priceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           present(priceAlert, animated: true, completion: nil)
       }

       private func filterByCategory(_ category: String) {
           filteredEvents = allEvents.filter { event in
               return event["category"] as? String == category
           }
           tableView.reloadData()
       }

       private func filterByPriceRange(_ priceRange: String) {
           let ranges: [String: ClosedRange<Double>] = [
               "0-10 BHD": 0...10,
               "10-20 BHD": 10...20,
               "20-30 BHD": 20...30
           ]

           if let range = ranges[priceRange] {
               filteredEvents = allEvents.filter { event in
                   let price = Double((event["price"] as? String)?.replacingOccurrences(of: " BHD", with: "") ?? "0") ?? 0
                   return range.contains(price)
               }
           }
           tableView.reloadData()
       }
}

