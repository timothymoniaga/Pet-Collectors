//
//  ImageViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
// TODO: make image zoomable and rotatable via genstures?

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet var image: UIImageView!
    var imageURL: String?
    var dogBreed: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageFromURL(urlString: imageURL ?? "")
        
        title = dogBreed ?? "Image"
    }
    
    func loadImageFromURL(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self.image.image = UIImage(data: imageData)
                }
            }
        }
    }
}
