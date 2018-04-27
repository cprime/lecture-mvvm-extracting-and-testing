//
//  RootViewController.swift
//  MVCMessageComposer
//
//  Created by Prime, Colden on 4/26/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        MessagingDataStorage.shared.setCurrentUser(User(id: UUID().uuidString, name: "Jane Doe"))
    }

    @IBAction func sendMessageButtonClicked(_ sender: Any) {
        MessagingDataStorage.shared.getCurrentUser { currentUser in
            if let currentUser = currentUser {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageComposerViewController") as! MessageComposerViewController
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                vc.sender = currentUser
                vc.recipient = User(id: UUID().uuidString, name: "John Doe")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
