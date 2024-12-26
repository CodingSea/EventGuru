//
//  TableViewController.swift
//  EventGuru02
//
//  Created by BP-36-201-17 on 24/12/2024.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CellTableViewCell
        cell?.Label.text = Label[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Label.count
    }
    

    @IBOutlet weak var Table: UITableView!
    
    var Label = ["Entertainment", "Gaming", "Sports", "Social & Networking", "Food & Drink", "Technology"]
    
   
    
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Table.delegate = self
        self.Table.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    

}



