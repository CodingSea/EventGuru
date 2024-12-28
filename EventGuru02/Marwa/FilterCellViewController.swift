 //
//  FilterCellViewController.swift
//  EventGuru02
//
//  Created by Mac on 27/12/2024.
//

import UIKit

class FilterCellViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, subcategorydelegate {
    func selectsubcategory(_subcategory: String) {
        
    }
    
    
    @IBOutlet weak var filterpopup : UITableView!
    
    var filtername = ["Category", "Price", "Location", "Date", "Availability"]
       
       override func viewDidLoad() {
           super.viewDidLoad()
           self.filterpopup.delegate = self
           self.filterpopup.dataSource = self
       }

       // MARK: - Table View Data Source
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return filtername.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let filtercell = tableView.dequeueReusableCell(withIdentifier: "filtercell", for: indexPath) as? FilterCell
           filtercell?.labelfilter.text = filtername[indexPath.row]
           return filtercell!
       }

       // MARK: - Table View Delegate
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let selectedFilter = filtername[indexPath.row]
           
           if selectedFilter == "Category" {
               // Instantiate SubcategoryViewController
               let storyboard = UIStoryboard(name: "Main", bundle: nil)
               if let subcategoryVC = storyboard.instantiateViewController(withIdentifier: "SubcategoryViewController") as? SubcategoryViewController {
                   
                   // Set modal presentation style
                   subcategoryVC.modalPresentationStyle = .overFullScreen
                   subcategoryVC.modalTransitionStyle = .crossDissolve
                   
                   // Set delegate to self
                   subcategoryVC.delegate = self
                   
                   // Present SubcategoryViewController
                   present(subcategoryVC, animated: true, completion: nil)
               }
           }
       }

       // MARK: - SubcategoryDelegate
       func didSelectSubcategory(_ subcategory: String) {
           print("Selected Subcategory: \(subcategory)")
           
           // Implement your filtering logic here
           // Example: Reload the table or apply the filter
       }

}
 
