//
//  ProfileViewController.swift
//  Chat_App
//
//  Created by administrator on 1/8/22.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageProfile()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let StrongSelf = self else {return}
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                StrongSelf.validateAuth()
                StrongSelf.present(actionSheet , animated: true)
                
            }
            catch {
                
                
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    
    func setImageProfile(){
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return}
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
        
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: (self?.imageView)!, url: url)
                print("")
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func downloadImage(imageView : UIImageView , url : URL){
        URLSession.shared.dataTask(with: url , completionHandler:  { data, _, error in
            guard let data = data , error == nil else {return}
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.layer.cornerRadius = (self.imageView.frame.size.height / 2)
                imageView.image = image

                self.imageView.layer.masksToBounds = true
                
            }
        }).resume()
    }
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
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
}
