//
//  UserProfileHeader.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit
import SDWebImage

class UserProfileHeader: UICollectionViewCell {

    static let cellId = "UserProfileHeader"

    var user: User? {
        didSet {
            setupProfileImageView()
            usernameLabel.text = user?.username
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        editProfileButton.layer.borderColor = UIColor.lightGray.cgColor
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = 3

        let attributedPosts = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedPosts.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))

        let attributedFollowers = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedFollowers.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))

        let attributedFollowing = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedFollowing.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                                                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        postsLabel.attributedText = attributedPosts
        followersLabel.attributedText = attributedFollowers
        followingLabel.attributedText = attributedFollowing
    }

    func setupProfileImageView() {
        profileImageView.layer.cornerRadius = 80/2
        profileImageView.clipsToBounds = true
        guard let profileImageUrl = user?.profileImageUrl else { return }
        let url = URL(string: profileImageUrl)
        profileImageView.sd_setImage(with: url)
    }

}
