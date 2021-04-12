//
//  LoginController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupView()
    }

    func setupView() {
        emailTextField.backgroundColor = .init(white: 0, alpha: 0.03)
        passwordTextField.backgroundColor = .init(white: 0, alpha: 0.03)
        loginButton.layer.cornerRadius = 5


        let attributedText = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                                                                                                       NSAttributedString.Key.foregroundColor: UIColor.lightGray.cgColor])
        attributedText.append(NSAttributedString(string: "SignUp", attributes: [NSAttributedString.Key.foregroundColor: UIColor.rgbColor(red: 17, green: 154, blue: 237, alpha: 1).cgColor,
                                                                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]))
        dontHaveAccountButton.setAttributedTitle(attributedText, for: .normal)

        emailTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    }

    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Failed to sign in with email:", error)
                return
            }
            print("Successfullu logged back in with user:", result?.user.uid ?? "")
            UIApplication.mainTabBarController()?.setupViewControllers()
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            loginButton.backgroundColor = .rgbColor(red: 17, green: 154, blue: 237, alpha: 1)
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = .rgbColor(red: 149, green: 204, blue: 244, alpha: 1)
            loginButton.isEnabled = false
        }
    }

    @IBAction func handleShowSignUp(_ sender: Any) {
        let signUpController: SignUpController = .init()
        signUpController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(signUpController, animated: true)
    }

}
