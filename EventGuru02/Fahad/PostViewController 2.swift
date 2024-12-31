//
//  PostViewController.swift
//  EventGuru02
//
//  Created by Fahad on 15/12/2024.
//

import UIKit
import Cloudinary
import FirebaseFirestore

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var cloudinary: CLDCloudinary!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        self.textView.layer.borderWidth = 1
        
        db = Firestore.firestore()
        cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: "dvs6iybjy", apiKey: "681697956424333", apiSecret: "si8jGHFp1e1RQ9bnmEHsAnvSGlI"))
    }
    
    
    @IBAction func selectPhoto(_ sender: Any)
    {
        let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                imageView.image = selectedImage
                uploadImageToCloudinary(image: selectedImage)
            }
            picker.dismiss(animated: true, completion: nil)
        }

    func uploadImageToCloudinary(image: UIImage)
    {
        /*
        cloudinary.createUrl()
            .setTransformation(CLDTransformation()
                .setWidth(360).setHeight(180))
         */
        
   //     let uploader = cloudinary.createUploader()
       // uploader.upload(data: image.pngData() ?? <#default value#>, uploadPreset: "presetName")
    }
    
    func fetchImage(url: String)
    {
        let downloader = cloudinary.createDownloader()
        
        downloader.fetchImage(url)
    }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
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
