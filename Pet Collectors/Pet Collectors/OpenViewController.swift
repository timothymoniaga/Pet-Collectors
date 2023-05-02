//
//  OpenViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 1/5/2023.
//

import UIKit

class OpenViewController: UIViewController {
    
    let countdownLabel = UILabel()
    var countdownTime: TimeInterval = 24 * 60 * 60
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        startCountdown()
        // Do any additional setup after loading the view.
    }
    
    func startCountdown() {
        // Invalidate the timer if it's already running
        timer?.invalidate()

        // Create a new timer that will fire every second
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            // Decrement the countdown time
            self?.countdownTime -= 1
            
            // Format the countdown time as a string
            let hours = Int(self?.countdownTime ?? 0) / 3600
            let minutes = (Int(self?.countdownTime ?? 0) / 60) % 60
            let seconds = Int(self?.countdownTime ?? 0) % 60
            let countdownString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            // Update the countdown label
            self?.countdownLabel.text = "Come back in \(countdownString) for your next pack!"
            
            
            // Stop the timer when the countdown reaches 0
            if self?.countdownTime == 0 {
                self?.timer?.invalidate()
                self?.timer = nil
                self?.countdownLabel.isHidden = true
            }
        }
    }
    
    func setup() {
        countdownLabel.text = "Come back in 24:00:00 for your next pack!"
        countdownLabel.font = .boldSystemFont(ofSize: 36)
        
        countdownLabel.numberOfLines = 0
        countdownLabel.adjustsFontSizeToFitWidth = true
        countdownLabel.textAlignment = .center
        
        view.addSubview(countdownLabel)
        
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countdownLabel.widthAnchor.constraint(equalToConstant: 300),
            countdownLabel.heightAnchor.constraint(equalToConstant: 150)
        ])
        
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
