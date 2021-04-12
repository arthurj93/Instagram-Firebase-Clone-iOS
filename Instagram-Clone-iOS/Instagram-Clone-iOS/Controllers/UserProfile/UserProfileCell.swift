//
//  UserProfileCell.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit

class UserProfileCell: UICollectionViewCell {

    static let cellId = "UserProfileCell"

    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else{ return }
            guard let url = URL(string: imageUrl) else { return }
            imageView.sd_setImage(with: url, completed: nil)
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
