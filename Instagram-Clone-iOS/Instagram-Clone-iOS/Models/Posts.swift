//
//  Posts.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import Foundation

struct Post {
    var id: String?
    let user: User
    let imageUrl: String
    let caption: String
    let imageHeight: Int
    let imageWidth: Int
    let creationDate: Date
    var hasLiked: Bool = false

    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.imageWidth = dictionary["imageWidth"] as? Int ?? 0
        self.imageHeight = dictionary["imageHeight"] as? Int ?? 0
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
