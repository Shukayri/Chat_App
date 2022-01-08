//
//  LoginViewController.swift
//  Chat_App
//
//  Created by administrator on 1/8/22.
//

import UIKit
import Firebase
import FirebaseAuth
//import FBSDKLoginKit
import JGProgressHUD
class LoginViewController : UIViewController   {
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    
    
//        @IBAction func facebookLogin(_ sender: UIButton) {
//
//            self.loginButtonClicked()
//
//
//
//
//            }
    
//    func getUserProfile(token: AccessToken?, userId: String?) {
//            let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, middle_name, last_name, name, picture, email"])
//            graphRequest.start { _, result, error in
//                if error == nil {
//                    let data: [String: AnyObject] = result as! [String: AnyObject]
//
//                    // Facebook Id
//                    if let facebookId = data["id"] as? String {
//                        print("Facebook Id: \(facebookId)")
//                    } else {
//                        print("Facebook Id: Not exists")
//                    }
//
//                    // Facebook First Name
//                    if let facebookFirstName = data["first_name"] as? String {
//                        print("Facebook First Name: \(facebookFirstName)")
//                    } else {
//                        print("Facebook First Name: Not exists")
//                    }
//
//                    // Facebook Middle Name
//                    if let facebookMiddleName = data["middle_name"] as? String {
//                        print("Facebook Middle Name: \(facebookMiddleName)")
//                    } else {
//                        print("Facebook Middle Name: Not exists")
//                    }
//
//                    // Facebook Last Name
//                    if let facebookLastName = data["last_name"] as? String {
//                        print("Facebook Last Name: \(facebookLastName)")
//                    } else {
//                        print("Facebook Last Name: Not exists")
//                    }
//
//                    // Facebook Name
//                    if let facebookName = data["name"] as? String {
//                        print("Facebook Name: \(facebookName)")
//                    } else {
//                        print("Facebook Name: Not exists")
//                    }
//
//                    // Facebook Profile Pic URL
//                    let facebookProfilePicURL = "https://graph.facebook.com/\(userId ?? "")/picture?type=large"
//                    print("Facebook Profile Pic URL: \(facebookProfilePicURL)")
//
//                    // Facebook Email
//                    if let facebookEmail = data["email"] as? String {
//                        print("Facebook Email: \(facebookEmail)")
//                    } else {
//                        print("Facebook Email: Not exists")
//                    }
//
//                    print("Facebook Access Token: \(token?.tokenString ?? "")")
//                } else {
//                    print("Error: Trying to get user's info")
//                }
//            }
//        }
//
//    func isLoggedIn() -> Bool {
//            let accessToken = AccessToken.current
//            let isLoggedIn = accessToken != nil && !(accessToken?.isExpired ?? false)
//            return isLoggedIn
//        }
//
//    func loginButtonClicked() {
//            let loginManager = LoginManager()
//            loginManager.logIn(permissions: ["public_profile", "email"], from: self, handler: { result, error in
//                if error != nil {
//                    print("ERROR: Trying to get login results")
//                } else if result?.isCancelled != nil {
//                    print("The token is \(result?.token?.tokenString ?? "")")
//                    if result?.token?.tokenString != nil {
//                        print("Logged in")
//                        self.getUserProfile(token: result?.token, userId: result?.token?.userID)
//                    } else {
//                        print("Cancelled")
//                    }
//                }
//            })
//        }
//
    
    func alertWorngEmail(){
        
        let alert = UIAlertController(title: "Incorrect Username",
                                      message: "Please check your username and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        guard let email = emailTextField.text else {return}
        
        guard let password = passwordTextField.text else {return}
        
        spinner.show(in: view)
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
                        guard let strongSelf = self else {
                            return
                        }


            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(email)")
                strongSelf.alertWorngEmail()
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()

                }
            
                return
            }
            let user = result.user
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("logged in user: \(user)")
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
          
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()

            }
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            
            
        })
        
       
    }
    
    
    @IBAction func singupAction(_ sender: UIButton) {
        
        let register = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
        
        self.navigationController?.pushViewController(register, animated: true)
    }
    
}
