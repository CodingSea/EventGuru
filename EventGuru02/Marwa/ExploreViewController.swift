//
//  ExploreViewController.swift
//  EventGuru02
//
//  Created by Mac on 22/12/2024.
//


import UIKit

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventName.count
    }
    
    
    
    @IBOutlet weak var EventTable: UITableView!
    
    
    var EventName = ["Birthday","Wedding","Ceremony","Night Festival","Music","Birthday","Wedding","Ceremony"]
    
    var EventPrice = ["0 bd","0.5 bd", "1 bd","1.5 bd","0 bd","0.5 bd", "1 bd","1.5 bd"]
    
    var EventImage = ["image1", "image2", "image3", "image4", "image5", "image6", "image7", "image8"]
    
    @IBAction func FilterButton(_ sender: UIButton) {
       
    }
    


    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventcell = tableView.dequeueReusableCell(withIdentifier: "eventcell", for: indexPath) as? ExploreTableViewCell
        
        eventcell?.EventImage.image = UIImage(named: EventImage[indexPath.row])
        eventcell?.EventName.text = EventName[indexPath.row]
        eventcell?.EventPrice.text = EventPrice[indexPath.row]
        return eventcell!
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        self.EventTable.delegate = self
        self.EventTable.dataSource = self

     }
}

