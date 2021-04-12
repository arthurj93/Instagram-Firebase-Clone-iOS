//
//  CommentsContainerView.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 12/04/21.
//

import UIKit

protocol CommentsContainerViewDelegate: class {
    func didSubmitComment(comment: String)
}

class CommentsContainerView: UIView {

    static let xibName = "CommentsContainerView"

    weak var delegate: CommentsContainerViewDelegate?

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
    }

    @objc func handleSubmit() {
        guard let comment = commentTextField.text else { return }
        delegate?.didSubmitComment(comment: comment)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}


extension CommentsContainerView {
    static func initFromNib() -> CommentsContainerView {
        return Bundle.main.loadNibNamed(CommentsContainerView.xibName, owner: self, options: nil)?.first as! CommentsContainerView
    }
}

