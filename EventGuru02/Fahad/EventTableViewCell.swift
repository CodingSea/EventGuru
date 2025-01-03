//
//  ExploreTableViewCell.swift
//  EventGuru02
//
//  Created by Mac on 22/12/2024.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var EventImage: UIImageView!
    
    
    @IBOutlet weak var EventName: UILabel!
    
    @IBOutlet weak var EventPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
    
    
    @IBAction func editBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func deleteBtn(_ sender: Any) {
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
