//
//  Cloudinary.swift
//  EventGuru02
//
//  Created by Student on 11/12/2024.
//

import Foundation
import Cloudinary

struct CloudinarySetup {
    
    static var cloudinary : CLDCloudinary!

    private static let cloudName : String = "dvs6iybjy" //Cloud name
    
    static let uploadPreset: String = "ml_default" //Upload preset
    
    static func cloudinarySetup() -> CLDCloudinary {
        
        let config = CLDConfiguration(cloudName: CloudinarySetup.cloudName, secure: true)
        
        cloudinary = CLDCloudinary(configuration: config)
        
        return cloudinary
    }
}
