//
//  Message.swift
//  MVCMessageComposer
//
//  Created by Prime, Colden on 4/26/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation

struct Message: Codable {
    let id: String
    let senderId: String
    let recipientId: String
    let text: String
    let date: Date
}
