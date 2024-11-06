//
//  ViewController.swift
//  EventGuru
//
//  Created by Fahad on 02/11/2024.
//

import UIKit
import FirebaseAnalytics

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("Run App", parameters: ["used App": "used"])
    }


}

