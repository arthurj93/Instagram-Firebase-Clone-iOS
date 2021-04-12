//
//  HomePostCell.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit

protocol HomePostCellDelegate: class {
    func didTapComment(post: Post)
}

class HomePostCell: UICollectionViewCell {

    static let cellId = "HomePostCell"

    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            photoImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
            usernameLabel.text = post?.user.username

            guard let profileImageUrl = post?.user.profileImageUrl else { return }
            userProfileImageView.sd_setImage(with: URL(string: profileImageUrl), completed: nil)
            setAttributedText(post: post)
        }
    }

    weak var delegate: HomePostCellDelegate?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userProfileImageView.layer.cornerRadius = 40/2

        commentButton.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
    }

    func setAttributedText(post: Post?) {
        guard let caption = post?.caption else { return }
        guard let username = post?.user.username else { return }
        let attributedText: NSMutableAttributedString = .init(string: "\(username)",
                                                              attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(caption)",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        guard let timeAgoDisplay = post?.creationDate.timeAgoDisplay() else { return }
        attributedText.append(NSAttributedString(string: timeAgoDisplay,
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                              NSAttributedString.Key.foregroundColor: UIColor.gray]))
        captionLabel.attributedText = attributedText
    }

    @objc func handleComment() {
        guard let post = post else { return }
        delegate?.didTapComment(post: post)
    }

}
