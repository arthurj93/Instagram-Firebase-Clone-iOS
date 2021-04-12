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
        self.delegate = self
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
        let layout = UICollectionViewFlowLayout()
        let homeNavController = templateNavController(viewController: HomeController(), image: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"))
        let searchNavController = templateNavController(viewController: UserSearchController.init(collectionViewLayout: layout), image: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"))
        let userProfileNavController = templateNavController(viewController: UserProfileController.init(collectionViewLayout: layout), image: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"))
        let plusNavController = templateNavController(viewController: .init(), image: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        let likeNavController = templateNavController(viewController: .init(), image: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))
        viewControllers = [
            homeNavController,
            searchNavController,
            plusNavController,
            likeNavController,
            userProfileNavController
        ]

        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = .init(top: 4, left: 0, bottom: -4, right: 0)
        }
    }

}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let layout: UICollectionViewFlowLayout = .init()
            let photoSelectorController: PhotoSelectorController = .init(collectionViewLayout: layout)
            let navController: UINavigationController = .init(rootViewController: photoSelectorController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            return false
        }
        return true
    }
}

extension MainTabBarController {
    private func templateNavController(viewController: UIViewController = .init(), image: UIImage, selectedImage: UIImage) -> UINavigationController {
        let navController: UINavigationController = .init(rootViewController: viewController)
        viewController.tabBarItem.image = image
        viewController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
