//
//  SharePhotoController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {

    var selectedImage: UIImage?

    @IBOutlet weak var sharedPhotoImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightButtonItem: UIBarButtonItem = .init(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        navigationItem.rightBarButtonItem = rightButtonItem
        setupImageAndTextViews()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupImageAndTextViews() {
        sharedPhotoImageView.image = selectedImage
    }

    @objc func handleShare() {
        guard let postImage = selectedImage else { return }
        guard let caption = textView.text else { return }

        navigationItem.rightBarButtonItem?.isEnabled = false
        Storage.saveSharePost(postImage: postImage, caption: caption) { result in
            switch result {
            case .success():
                self.dismiss(animated: true)
                NotificationCenter.default.post(name: .updateFeed, object: nil)
            case .failure(_):
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }

}

extension Notification.Name {
    static let updateFeed = NSNotification.Name("updateFeed")
}

