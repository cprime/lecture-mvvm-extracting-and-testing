//
//  MockRestClient.swift
//  MVVMMessageComposerTests
//
//  Created by Prime, Colden on 4/30/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid
@testable import MVVMMessageComposer

class MockRestClient: RestClient {
    var capturedSendArguments = [(text: String, sender: User, recipient: User)]()
    var stubbedSendResult: Result<Message>!
    func send(_ text: String, from sender: User, to recipient: User, completion: @escaping (Result<Message>) -> Void) {
        capturedSendArguments.append((text: text, sender: sender, recipient: recipient))
        DispatchQueue.main.async {
            completion(self.stubbedSendResult)
        }
    }
}
