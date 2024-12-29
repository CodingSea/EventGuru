import UIKit

class ExploreViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    // Event data arrays
    var eventNames = ["Birthday", "Wedding", "Ceremony", "Night Festival", "Music", "Birthday", "Wedding", "Ceremony"]
    var eventPrices = ["0 bd", "0.5 bd", "1 bd", "1.5 bd", "0 bd", "0.5 bd", "1 bd", "1.5 bd"]
    var eventImages = ["image1", "image2", "image3", "image4", "image5", "image6", "image7", "image8"]

    // Filtered data
    var filteredEventNames: [String] = []
    var filteredEventPrices: [String] = []
    var filteredEventImages: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self

        // Initialize filtered lists with all events
        filteredEventNames = eventNames
        filteredEventPrices = eventPrices
        filteredEventImages = eventImages
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEventNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as? ExploreTableViewCell else {
            fatalError("Unable to dequeue ExploreTableViewCell")
        }

        // Configure the custom cell
        cell.EventName.text = filteredEventNames[indexPath.row]
        cell.EventPrice.text = filteredEventPrices[indexPath.row]
        cell.EventImage.image = UIImage(named: filteredEventImages[indexPath.row])

        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Show all events if the search bar is empty
            filteredEventNames = eventNames
            filteredEventPrices = eventPrices
            filteredEventImages = eventImages
        } else {
            // Filter events based on search text
            filteredEventNames = []
            filteredEventPrices = []
            filteredEventImages = []

            for (index, name) in eventNames.enumerated() {
                if name.lowercased().contains(searchText.lowercased()) {
                    filteredEventNames.append(name)
                    filteredEventPrices.append(eventPrices[index])
                    filteredEventImages.append(eventImages[index])
                }
            }
        }

        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Reset search and show all events
        searchBar.text = ""
        filteredEventNames = eventNames
        filteredEventPrices = eventPrices
        filteredEventImages = eventImages
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    @IBAction func applyFiltersTapped(_ sender: Any) {

            let filterAlert = UIAlertController(title: "Apply Filters", message: "Choose a filter", preferredStyle: .actionSheet)

            // Show All Filter
            filterAlert.addAction(UIAlertAction(title: "Show All", style: .default, handler: { _ in
                self.resetFilters()
            }))

            // Category Filter
            filterAlert.addAction(UIAlertAction(title: "Category", style: .default, handler: { _ in
                self.showCategoryFilter()
            }))

            // Price Filter
            filterAlert.addAction(UIAlertAction(title: "Price", style: .default, handler: { _ in
                self.showPriceFilter()
            }))

            // Cancel Action
            filterAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(filterAlert, animated: true, completion: nil)
        }

        private func showCategoryFilter() {
            let categoryAlert = UIAlertController(title: "Category", message: "Select a category", preferredStyle: .alert)

            // Add other categories dynamically from eventNames
            let uniqueCategories = Array(Set(eventNames))
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

            let priceRanges = ["0-1 bd", "1-2 bd", "3-4 bd", "4-5 bd"]
            for price in priceRanges {
                priceAlert.addAction(UIAlertAction(title: price, style: .default, handler: { action in
                    self.filterByPriceRange(action.title ?? "")
                }))
            }

            priceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(priceAlert, animated: true, completion: nil)
        }

        private func resetFilters() {
            // Reset all filters and show all events
            filteredEventNames = eventNames
            filteredEventPrices = eventPrices
            filteredEventImages = eventImages
            tableView.reloadData()
        }

        private func filterByCategory(_ category: String) {
            filteredEventNames = []
            filteredEventPrices = []
            filteredEventImages = []

            for (index, name) in eventNames.enumerated() {
                if name == category {
                    filteredEventNames.append(name)
                    filteredEventPrices.append(eventPrices[index])
                    filteredEventImages.append(eventImages[index])
                }
            }

            tableView.reloadData()
        }

        private func filterByPriceRange(_ priceRange: String) {
            filteredEventNames = []
            filteredEventPrices = []
            filteredEventImages = []

            let ranges: [String: ClosedRange<Double>] = [
                "0-1 bd": 0...1,
                "1-2 bd": 1...2,
                "3-4 bd": 3...4,
                "4-5 bd": 4...5
            ]

            if let range = ranges[priceRange] {
                for (index, price) in eventPrices.enumerated() {
                    let priceValue = Double(price.replacingOccurrences(of: " bd", with: "")) ?? 0
                    if range.contains(priceValue) {
                        filteredEventNames.append(eventNames[index])
                        filteredEventPrices.append(price)
                        filteredEventImages.append(eventImages[index])
                    }
                }
            }

            tableView.reloadData()
        }
}
