//
//  Cloudinary.swift
//  LocalEventOrg
//


import Foundation
import Cloudinary
import UIKit

let config = CLDConfiguration(cloudName:"dvs6iybjy",apiKey: "681697956424333",apiSecret: "si8jGHFp1e1RQ9bnmEHsAnvSGlI")
let cloudinary = CLDCloudinary(configuration: config)

func uploadImage(image: UIImage) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

    cloudinary.createUploader().upload(data: imageData, uploadPreset: "ml_default", completionHandler:  { (result, error) in
        if error != nil {
            print("Upload failed: (error)")
        } else if let result = result {
            let imageUrl = result.secureUrl
            EventHelper.updateImagePath(to: imageUrl!)
            print("Upload successful: \(imageUrl!)")
            print("Upload successful: (result.secureUrl!)")
        }
    })
}

func GetImage(string: String) -> UIImage? {
    guard let url = URL(string: string) else {
        print("Invalid URL")
        return nil
    }
    
    var downloadedImage: UIImage?
    let semaphore = DispatchSemaphore(value: 0)
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
        } else if let data = data, let image = UIImage(data: data) {
            downloadedImage = image
        }
        semaphore.signal()
    }
    
    task.resume()
    semaphore.wait() // Wait for the network call to complete
    
    return downloadedImage
}

