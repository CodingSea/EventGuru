//
//  EventHelper.swift
//  EventGuru02
//
//  Created by BP-36-224-10 on 31/12/2024.
//

import Foundation


class EventHelper {
    // Static variable to hold the image path
    static var ImagePath: String = "default_image_path"

    // Method to update the static variable
    static func updateImagePath(to newPath: String) {
        ImagePath = newPath
    }
    
    // Method to retrieve the static variable
    static func getImagePath() -> String {
        return ImagePath
    }
}
