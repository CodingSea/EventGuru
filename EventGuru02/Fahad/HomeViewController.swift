/*

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

@IBOutlet weak var tableView: UITableView!

let db = Firestore.firestore()
var events: [Event] = []

override func viewDidLoad() {
super.viewDidLoad()
tableView.delegate = self
tableView.dataSource = self
fetchEvents()
}

func fetchEvents() {
db.collection("events").getDocuments { (querySnapshot, error) in
if let error = error {
print("Error getting documents: \(error)")
return
}

self.events = querySnapshot?.documents.compactMap { document in
let data = document.data()
guard let name = data["eventName"] as? String,
let price = data["eventPrice"] as? Double,
let imageUrl = data["eventImageURL"] as? String else {
return nil
}
return Event(name: name, price: price, imageUrl: imageUrl)
} ?? []

DispatchQueue.main.async {
self.tableView.reloadData()
}
}
}

// MARK: - UITableViewDataSource Methods

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
return events.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! HomeTableViewCell
let event = events[indexPath.row]
cell.eventNameLabel.text = event.name
cell.eventPriceLabel.text = "$\(event.price)"

// Load the image using the existing GetImage function
DispatchQueue.global(qos: .background).async {
let image = GetImage(string: event.imageUrl)
DispatchQueue.main.async {
cell.eventImageView.image = image
}
}

return cell
}

// MARK: - UITableViewDelegate Methods

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
// Handle the event selection if needed
}
}


*/

