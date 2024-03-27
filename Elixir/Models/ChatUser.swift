//
//  ChatUser.swift
//  Elixir
//
//  Created by Jack Stark on 2/4/23.
//

import Foundation
import MessageKit

struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
