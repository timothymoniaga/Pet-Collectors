//
//  LoginViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 3/6/2023.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    //var authController: Auth?
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var handle: AuthStateDidChangeListenerHandle?
    var segueFlag = true // For preventing a double segue.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //authController = Auth.auth()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
        passwordTextField.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in
            if(user != nil && self.segueFlag) {
                self.segueFlag = true
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func login(_ sender: Any) {
            
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email and password cannot be empty")
            displayMessage("Error", "Email or password cannot be empty.")
            return
        }
        
        databaseController?.login(email: email, password: password) { errorMessage in
            if let errorMessage = errorMessage {
                // Login failed, show error message
                self.displayMessage("Error", errorMessage)
            } else {
                // Login successful, perform segue
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        }
        segueFlag = false
    }

    
    
    @IBAction func signup(_ sender: Any) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email and password cannot be empty")
            displayMessage("Error", "Email or password cannot be empty.")
            return
        }
        
        databaseController?.signup(email: email, password: password) { errorMessage in
            if let errorMessage = errorMessage {
                // Login failed, show error message
                self.displayMessage("Error", errorMessage)
            } else {
                // Login successful, perform segue
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        }
    }
    
    func displayMessage(_ title: String, _ message: String) {
            let alertController = UIAlertController(title: title, message: message,
            preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
            handler: nil))
            
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
    }

}
