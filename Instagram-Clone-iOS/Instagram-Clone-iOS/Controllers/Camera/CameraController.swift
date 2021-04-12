//
//  CameraController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 11/04/21.
//

import UIKit
import AVFoundation
import SnapKit

class CameraController: UIViewController {

    let dismissButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()

    let capturePhotoButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo"), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()

    let output: AVCapturePhotoOutput = .init()
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        transitioningDelegate = self
        setupCaptureSession()
        setupHUD()
    }

    func setupHUD() {
        view.addSubview(capturePhotoButton)
        view.addSubview(dismissButton)
        capturePhotoButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(80)
            $0.width.equalTo(80)
        }

        dismissButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.topMargin.equalToSuperview().inset(12)
            $0.height.equalTo(50)
            $0.width.equalTo(50)
        }

    }

    func setupCaptureSession() {
        let captureSession: AVCaptureSession = .init()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input: AVCaptureDeviceInput = try .init(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let error {
            print("Could not setup camera input:", error)
        }
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        let previewLayer: AVCaptureVideoPreviewLayer = .init(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    @objc func handleCapturePhoto() {
        print("capture photo")
        let settings: AVCapturePhotoSettings = .init()
        output.capturePhoto(with: settings, delegate: self)
    }

    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let previewImage = UIImage(data: imageData)
        let containerView = PreviewPhotoContainerView.initFromNib()
        containerView.previewImageView.image = previewImage
        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        print("finishing processing photo sample buffer")
    }
}

extension CameraController:  UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentor
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
}
