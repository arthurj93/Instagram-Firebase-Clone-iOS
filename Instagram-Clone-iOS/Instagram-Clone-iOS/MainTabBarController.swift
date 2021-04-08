//
//  MainTabBarController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController: LoginController = .init()
                let navController: UINavigationController = .init(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        setupViewControllers()
    }

    func setupViewControllers() {
        let layout: UICollectionViewFlowLayout = .init()
        let userProfileController: UserProfileController = .init(collectionViewLayout: layout)
        viewControllers = [
            generateNavigationController(with: userProfileController, title: "teste2", image: #imageLiteral(resourceName: "profile_unselected"))
        ]
    }

}

extension MainTabBarController {
    private func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        rootViewController.configureNavigationBar(largeTitleColor: .black,
                                                  backgoundColor: .white,
                                                  tintColor: .black,
                                                  title: title,
                                                  preferredLargeTitle: false)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
