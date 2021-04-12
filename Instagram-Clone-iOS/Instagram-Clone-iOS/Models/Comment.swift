//
//  Comment.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 12/04/21.
//

import Foundation

struct Comment {
    let user: User
    let text: String
    let uid: String

    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
