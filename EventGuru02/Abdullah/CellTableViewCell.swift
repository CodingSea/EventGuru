//
//  CellTableViewCell.swift
//  EventGuru02
//
//  Created by BP-36-201-17 on 24/12/2024.
//

import UIKit

class CellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var Switchs: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
