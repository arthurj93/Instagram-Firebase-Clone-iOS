//
//  UserSearchCell.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 10/04/21.
//

import UIKit

class UserSearchCell: UICollectionViewCell {

    static let cellId = "UserSearchCell"

    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            guard let url = URL(string: user?.profileImageUrl ?? "") else { return }
            profileImageView.sd_setImage(with: url, completed: nil)
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 50 / 2
    }

}
