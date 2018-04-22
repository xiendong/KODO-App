//
//  ChatBubble.swift
//  KODO
//
//  Created by Xien Dong on 21/4/18.
//  Copyright © 2018 Xien Dong. All rights reserved.
//

import Foundation
import UIKit

class ChatBubble: UICollectionViewCell {

    var chatContent: String? {
        set {
            chatMessageLabel?.text = newValue
        }
        get {
            return chatMessageLabel?.text
        }
    }

    var isSenderUser: Bool {
        set {
            chatBackground?.image = newValue ? #imageLiteral(resourceName: "left-bubble") : #imageLiteral(resourceName: "right-bubble")
        }
        get {
            return chatBackground?.image == #imageLiteral(resourceName: "left-bubble")
        }
    }

    private var chatMessageLabel: UILabel? {
        get {
            return contentView.subviews
                .first(where: { $0.restorationIdentifier == "chat-message" }) as? UILabel
        }
    }

    var chatBackground: UIImageView? {
        get {
            return contentView.subviews
                .first(where: { $0.restorationIdentifier == "chat-background" }) as? UIImageView
        }
    }
}
