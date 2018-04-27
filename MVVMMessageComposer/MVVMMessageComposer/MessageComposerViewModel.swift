//
//  MessageComposerViewModel.swift
//  MVVMMessageComposer
//
//  Created by Prime, Colden on 4/27/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation

class MessageComposerViewModel {
    let sender: User
    let recipient: User

    init(sender: User, recipient: User) {
        self.sender = sender
        self.recipient = recipient
    }
}
