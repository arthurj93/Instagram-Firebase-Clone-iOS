//
//  CommentCell.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 12/04/21.
//

import UIKit

class CommentCell: UICollectionViewCell {
    static let cellId = "CommentCell"

    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            setupAttributedText(username: comment.user.username, comment: comment.text)
            profileImageView.sd_setImage(with: URL(string: comment.user.profileImageUrl))
        }
    }

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 40 / 2
    }

    func setupAttributedText(username: String, comment: String) {
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(comment)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        textView.attributedText = attributedText
        textView.isScrollEnabled = false
    }

}

extension CommentCell {
    static func initFromNib() -> CommentCell {
        return Bundle.main.loadNibNamed(CommentCell.cellId, owner: self, options: nil)?.first as! CommentCell
    }
}

