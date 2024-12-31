//
//  DashboardTableViewCell.swift
//  EventGuru02
//
//  Created by Mac on 29/12/2024.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

    
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var eventName: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    
    @IBOutlet weak var reuse: UIButton!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
