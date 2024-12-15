//
//  PostViewController.swift
//  EventGuru02
//
//  Created by Fahad on 15/12/2024.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.borderWidth = 1
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
