//
//  ExploreTableViewCell.swift
//  EventGuru02
//
//  Created by Mac on 22/12/2024.
//

import UIKit

protocol EventCellDelegate: AnyObject
{
    func didTapDeleteButton(eventID: String)
}

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var EventImage: UIImageView!
    @IBOutlet weak var EventName: UILabel!
    @IBOutlet weak var EventPrice: UILabel!
    
    var eventId: String?
    
    weak var delegate: EventCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }
    
    
    @IBAction func editBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func deleteBtn(_ sender: Any)
    {
        guard let eventID = eventId else { return }
        
        delegate?.didTapDeleteButton(eventID: eventID)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
