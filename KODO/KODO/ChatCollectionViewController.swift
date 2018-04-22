//
//  ChatCollectionViewController.swift
//  KODO
//
//  Created by Xien Dong on 22/4/18.
//  Copyright © 2018 Xien Dong. All rights reserved.
//

import UIKit

class ChatCollectionViewController: UICollectionViewController {

    // Chat record is a map of message and isSenderUser.
    // First item is the earliest message.
    var chatRecords: [(String, Bool)] = [
        ("Hello! My name is Kodo, what is your name?", false)
    ]
}

extension ChatCollectionViewController { // UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return chatRecords.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let reuseableCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "chat-bubble", for: indexPath)

        let chatBubbleCell = reuseableCell as? ChatBubble
        chatBubbleCell?.chatContent = chatRecords[indexPath.item].0
        chatBubbleCell?.isSenderUser = chatRecords[indexPath.item].1
        chatBubbleCell?.sizeToFit()

        return chatBubbleCell!
    }
}

extension ChatCollectionViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print(collectionView.cellForItem(at: indexPath))
//
//        guard let cell = collectionView.cellForItem(at: indexPath) as? ChatBubble else {
//            return .zero
//        }
//        return cell.chatBackground?.bounds.size ?? .zero
//    }
}
