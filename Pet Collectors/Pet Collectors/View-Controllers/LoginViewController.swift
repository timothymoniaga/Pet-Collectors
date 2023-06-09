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
            if let user = user, self.segueFlag {
                self.segueFlag = true
                print(user.uid)
                let UID = user.uid
                self.databaseController?.copyUserCardsToPersistentStorage(userUID: UID) { success in
                    if success {
                        print("Cards copied from Firebase successfully")
                    } else {
                        print("Error copying cards")
                    }
                }
                
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    /**
     Performs the login process with the provided email and password.

     This method is called when the login button is tapped. It retrieves the email and password entered by the user from the text fields. If both fields are not empty, it invokes the `login(email:password:completion:)` method of the `databaseController` to perform the login process.

     - Parameters:
        - sender: The sender object that triggered the action.

     - Note: The completion handler receives an optional error message if the login process fails. If the login is successful, it performs the segue with the identifier "loginSegue".

     */
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email and password cannot be empty")
            UIUtil.displayMessageDimiss("Error", "Email or password cannot be empty.", self)
            return
        }
        
        databaseController?.login(email: email, password: password) { errorMessage in
            if let errorMessage = errorMessage {
                // Login failed, show error message
                UIUtil.displayMessageDimiss("Error", errorMessage, self)
            } else {
                // Login successful, perform segue
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        }
        segueFlag = false
    }

    
    /**
     Performs the signup process with the provided email and password.

     This method is called when the signup button is tapped. It retrieves the email and password entered by the user from the text fields. If both fields are not empty, it invokes the `signup(email:password:completion:)` method of the `databaseController` to perform the signup process.

     - Parameters:
        - sender: The sender object that triggered the action.

     - Note: The completion handler receives an optional error message if the signup process fails. If the signup is successful, it performs the segue with the identifier "loginSegue".

     - SeeAlso: `signup(email:password:completion:)`
     */
    @IBAction func signup(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email and password cannot be empty")
            UIUtil.displayMessageDimiss("Error", "Email or password cannot be empty.", self)
            return
        }
        
        databaseController?.signup(email: email, password: password) { errorMessage in
            if let errorMessage = errorMessage {
                // Login failed, show error message
                UIUtil.displayMessageDimiss("Error", errorMessage, self)
            } else {
                // Login successful, perform segue
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        }
    }
}
