//
//  MessageComposerViewModelTests.swift
//  MVVMMessageComposerTests
//
//  Created by Prime, Colden on 5/2/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import XCTest
@testable import MVVMMessageComposer

class MessageComposerViewModelTests: XCTestCase {
    let sender = User(id: UUID().uuidString, email: "alice@example.com", name: "Alice")
    let recipient = User(id: UUID().uuidString, email: "bob@example.com", name: "Bob")
    lazy var viewModel = MessageComposerViewModel(sender: sender, recipient: recipient)

    // MARK: Title


    // MARK: Placeholder


    // MARK: Message Text


    // MARK: Character Count


    // MARK: Send Button


    // MARK: ShouldChangeText

    
    // MARK: Sending

}
