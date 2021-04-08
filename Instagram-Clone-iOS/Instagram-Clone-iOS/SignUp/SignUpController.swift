//
//  SignUpController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 07/04/21.
//

import UIKit
import Firebase

class SignUpController: UIViewController {

    enum Constants {
        static let plusButtonHeight = 140
        static let plusButtonWidth = 140
        static let plusButtonTop = 40
    }

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var plusPhotoButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        emailTextField.backgroundColor = .init(white: 0, alpha: 0.03)
        usernameTextField.backgroundColor = .init(white: 0, alpha: 0.03)
        passwordTextField.backgroundColor = .init(white: 0, alpha: 0.03)
        signUpButton.layer.cornerRadius = 5

        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        plusPhotoButton.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        alreadyHaveAccountButton.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)

        let attributedText = NSMutableAttributedString(string: "Already have and account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                                                                       NSAttributedString.Key.foregroundColor: UIColor.lightGray.cgColor])
        attributedText.append(NSAttributedString(string: "SignIn", attributes: [NSAttributedString.Key.foregroundColor: UIColor.rgbColor(red: 17, green: 154, blue: 237, alpha: 1).cgColor,
                                                                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]))
        alreadyHaveAccountButton.setAttributedTitle(attributedText, for: .normal)
    }

    @objc func handleAlreadyHaveAccount() {
        navigationController?.popViewController(animated: true)
    }

    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }

    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            signUpButton.backgroundColor = .rgbColor(red: 17, green: 154, blue: 237, alpha: 1)
            signUpButton.isEnabled = true
        } else {
            signUpButton.backgroundColor = .rgbColor(red: 149, green: 204, blue: 244, alpha: 1)
            signUpButton.isEnabled = false
        }
    }

}

extension SignUpController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage = info[.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        dismiss(animated: true)
    }
}

extension SignUpController {

    @objc func handleSignUp() {
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let username = usernameTextField.text, username.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in

            if let error = error {
                print("Failed to create user: ", error)
                return
            }

            print("Successfully created user:", result?.user.uid ?? "")

            guard let image = self.plusPhotoButton.imageView?.image else { return }
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return}
            let filename = NSUUID().uuidString
            let storage = Storage.storage().reference().child("profile_images").child(filename)

            storage.putData(uploadData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Failed to upload profile image:", error)
                    return
                }
                print("Successfully image into storage")
                storage.downloadURL { (url, error) in
                    if let error = error {
                        print("Failed to get image url:", error)
                        return
                    }
                    guard let profileImageUrl = url?.absoluteString else { return }
                    guard let uid = result?.user.uid else { return }
                    let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl]
                    let values = [uid: dictionaryValues]
                    Database.database().reference().child("users").updateChildValues(values) { (error, reference) in
                        if let error = error {
                            print("Failed to save user info into db: ", error)
                        }

                        print("Successfully save user into db")
                        UIApplication.mainTabBarController()?.setupViewControllers()
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

