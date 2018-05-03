//
//  MockDataStorage.swift
//  MVVMMessageComposerTests
//
//  Created by Prime, Colden on 4/30/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid
@testable import MVVMMessageComposer

class MockDataStorage: DataStorage {
    var messages = [Message]()
    func save(_ message: Message) {
        messages.append(message)
    }
}
