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
    }

    @IBAction func sendMessageButtonClicked(_ sender: Any) {
        guard let currentUser = MessagingDataStorage.shared.currentUser else {
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "MessageComposerViewController") as! MessageComposerViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.sender = currentUser
        vc.recipient = User(id: UUID().uuidString, name: "John Doe")
        present(vc, animated: true, completion: nil)
    }
}
