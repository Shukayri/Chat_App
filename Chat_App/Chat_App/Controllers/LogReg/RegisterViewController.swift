//
//  RegisterViewController.swift
//  Chat_App
//
//  Created by administrator on 1/8/22.
//

import UIKit
import Firebase
import FirebaseAuth
import JGProgressHUD
class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func seletcPhotoAction(_ sender: UITapGestureRecognizer) {
        presentPhotoPicker()
        print(")000000")
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        
        guard let email = emailText.text,
      let password = passwordText.text,
              let firstName = firstNameText.text,
                let lastName = lastNameText.text,
                !email.isEmpty,
              !password.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty
                
        else {
            self.alertUserErrorRegister()
            return
            
        }
        
        spinner.show(in: view)

        
        DatabaseManger.shared.userExists(with: email, completion: {
            exits in
            
            
            guard !exits else {
                return
            }
            
        })
                                         
                                         
                                         
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [self] authResult , error  in
            
            
            guard let result = authResult, error == nil else {
                print("Error creating user")
                self.spinner.dismiss()

                return
            }
            let user = result.user
            
           self.spinner.show(in: view)

            print("Created User: \(user)")
            self.insetUserOnDatabase()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
          
            DispatchQueue.main.async {
                self.spinner.dismiss()
                

            }
            
           
        })
    }
    
    private func alertUserErrorRegister(){
        
        
            let alert = UIAlertController(title: "Miss Some thing",
                                          message: "Please Entry all inforamtion to create an account", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        
        
        
    }
  
    func insetUserOnDatabase() {
        let user : ChatAppUser = ChatAppUser(firstName: firstNameText.text!, lastName: lastNameText.text!, emailAddress: emailText.text!)
        
        DatabaseManger.shared.insertUser(with: user, completion:  { success in
            if success {
                // upload image
               guard let image = self.imageView.image,
                    let data = image.pngData() else {
                    
                    return
                }
                
                let fileName = user.profilePictureFileName
                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                    switch result {
                    case .success(let downloadUrl):
                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                        print(downloadUrl)
                    case .failure(let error):
                        print("Stroge manger error \(error)")
                    }
                    
                }
            }
        })
        
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
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


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take a photo or select a photo
        
        // action sheet - take photo or choose photo
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.layer.cornerRadius = (self.imageView.frame.size.height / 2)
        self.imageView.image = selectedImage
        self.imageView.layer.masksToBounds = true

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
