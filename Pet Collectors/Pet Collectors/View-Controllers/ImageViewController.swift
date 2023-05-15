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

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
