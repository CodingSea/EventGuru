//
//  HomeViewController.swift
//  EventGuru02
//
//  Created by Mac on 28/12/2024.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HomeTableViewCell
        
        cell?.EventImage.image = UIImage(named: EventImage[indexPath.row])
        cell?.EventName.text = EventName[indexPath.row]
        cell?.EventPrice.text = EventPrice[indexPath.row]
        return cell!
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        EventTable.delegate = self
        EventTable.dataSource = self

     }
}
