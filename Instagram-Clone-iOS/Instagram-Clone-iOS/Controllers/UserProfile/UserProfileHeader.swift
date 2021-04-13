//
//  UserProfileHeader.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit
import SDWebImage
import Firebase

protocol UserProfileHeaderDelegate: class {
    func didChangeToListView()
    func didChangeToGridView()
}

class UserProfileHeader: UICollectionViewCell {

    static let cellId = "UserProfileHeader"

    weak var delegate: UserProfileHeaderDelegate?

    var user: User? {
        didSet {
            setupProfileImageView()
            usernameLabel.text = user?.username
            setupEditFollowButton()
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var editProfileFollowButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        setupAttributedText()
    }

    func setupView() {
        editProfileFollowButton.layer.borderColor = UIColor.lightGray.cgColor
        editProfileFollowButton.layer.borderWidth = 1
        editProfileFollowButton.layer.cornerRadius = 3
        editProfileFollowButton.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)

        listButton.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        gridButton.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
    }

    @objc func handleChangeToListView() {
        listButton.tintColor = .mainBlue
        gridButton.tintColor = .init(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }

    @objc func handleChangeToGridView() {
        gridButton.tintColor = .mainBlue
        listButton.tintColor = .init(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }

    @objc func handleEditProfileOrFollow() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }

        if editProfileFollowButton.titleLabel?.text == "Unfollow" {
            let database = Database.database().reference().child("following").child(currentLoggedInUserId).child(userId)
            database.removeValue { (error, reference) in
                if let error = error {
                    print("Failed to unfollow user:", error)
                    return
                }
                print("Successfully unfollow user", self.user?.username ?? "")
                self.setupFollowStyle()
            }
        } else {
            //follow logic
            let database = Database.database().reference().child("following").child(currentLoggedInUserId)
            let values = [userId: 1]
            database.updateChildValues(values) { (error, reference) in
                if let error = error {
                    print("Failed to follow user:", error)
                    return
                }
                print("Successfully follow user:", self.user?.username ?? "")
                self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
        }
    }

    func setupFollowStyle() {
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = .rgbColor(red: 17, green: 154, blue: 237, alpha: 1)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor.init(white: 0, alpha: 0.2).cgColor
    }

    func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        if currentLoggedInUserId == userId {
        } else {

            let database = Database.database().reference().child("following").child(currentLoggedInUserId).child(userId)
            database.observeSingleEvent(of: .value) { snapshot in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                } else {
                    self.setupFollowStyle()
                }
            } withCancel: { (error) in
                print("Failed to check if following:", error)
            }
        }

    }

    func setupProfileImageView() {
        profileImageView.layer.cornerRadius = 80/2
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .green
        guard let profileImageUrl = user?.profileImageUrl else { return }
        let url = URL(string: profileImageUrl)
        profileImageView.sd_setImage(with: url)
    }

    func setupAttributedText() {
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

}
