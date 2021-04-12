//
//  PreviewPhotoContainerView.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 11/04/21.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {

    static let xibName = "PreviewPhotoContainerView"
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
    }

    @objc func handleCancel() {
        self.removeFromSuperview()
    }

    @objc func handleSave() {
        guard let previewImage = previewImageView.image else { return }
        let library = PHPhotoLibrary.shared()
        library.performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: previewImage)
        } completionHandler: { (success, error) in
            if let error = error {
                print("Failed to save image to photo library:", error)
            }

            self.addSavedLabel()

            print("Sucessfully saved image to library")
        }

    }

    private func addSavedLabel() {
        DispatchQueue.main.async {
            let savedLabel: UILabel = .init()
            savedLabel.text = "Saved Successfully"
            savedLabel.textColor = .white
            savedLabel.numberOfLines = 0
            savedLabel.textAlignment = .center
            savedLabel.backgroundColor = .init(white: 0, alpha: 0.3)
            self.addSubview(savedLabel)
            savedLabel.frame = .init(x: 0, y: 0, width: 150, height: 80)
            savedLabel.center = self.center
            self.addSubview(savedLabel)
            savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
            } completion: { (completed) in
                //completed
                UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    savedLabel.alpha = 0
                } completion: { (_) in
                    savedLabel.removeFromSuperview()
                }

            }

        }
    }
}


extension PreviewPhotoContainerView {
    static func initFromNib() -> PreviewPhotoContainerView {
        return Bundle.main.loadNibNamed(PreviewPhotoContainerView.xibName, owner: self, options: nil)?.first as! PreviewPhotoContainerView
    }
}
