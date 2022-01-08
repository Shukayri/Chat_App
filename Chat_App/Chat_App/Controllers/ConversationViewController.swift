//
//  ConversationViewController.swift
//  Chat_App
//
//  Created by administrator on 1/8/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var newConversationButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
       
//        DatabaseManger.shared.test() //
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
   
    @IBAction func newConversationButtonAction(_ sender: UIBarButtonItem) {
        
        let vc = NewConversationViewController()
        vc.completion = {[weak self] result in
            self?.createNewConversation(result: result)
        }
        let nviVC = UINavigationController(rootViewController: vc)
        present(nviVC, animated: true)
        
    }
    
    private func createNewConversation(result : [String : String]){
        guard let name = result["name"] ,
                let email = result["email"]
        else {
            return
            
        }
        let vc = ChatViewController(with: email)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if FirebaseAuth.Auth.auth().currentUser == nil {
           
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        }
        }
    
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    private  func fetchConversation(){}
}


extension ConversationViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "Hey There!"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let vc = ChatViewController(with: "testo@gmail.com")
            vc.title = "Majeed Shukayri"
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    
    
}
