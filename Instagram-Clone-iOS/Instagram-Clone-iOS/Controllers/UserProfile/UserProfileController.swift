//
//  UserProfileController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController {

    var user: User?
    var userId: String?
    var posts: [Post] = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: UserProfileHeader.cellId, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: UserProfileHeader.cellId)
        collectionView.register(UINib(nibName: UserProfileCell.cellId, bundle: nil), forCellWithReuseIdentifier: UserProfileCell.cellId)
        fetchUser()
        setupLogOutButton()
//        fetchOrderedPosts()
    }

    fileprivate func fetchOrderedPosts() {
        guard let uid = user?.uid else { return }
        let database = Database.database().reference().child("posts").child(uid)
        database.queryOrdered(byChild: "creationDate").observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let user = self.user else { return }
            let post: Post = .init(user: user, dictionary: dictionary)
            //checar isso
//            self.posts.append(post)
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
        } withCancel: { (error) in
            print("Failed to fetch ordered posts:", error)
        }

    }

    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(handleLogOut))
    }

    @objc func handleLogOut() {
        let alertController: UIAlertController = .init(title: nil, message: nil, preferredStyle: .actionSheet)
        let logOutAction: UIAlertAction = .init(title: "Log out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                let loginController: LoginController = .init()
                let navController: UINavigationController = .init(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            } catch let signOutError {
                print("Failed to sign out:", signOutError)
            }

        }
        let cancelAction: UIAlertAction = .init(title: "Cancel", style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        alertController.pruneNegativeWidthConstraints()
        present(alertController, animated: true, completion: nil)
    }

    private func fetchUser() {
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        let database = Database.database().reference().child("users")
        database.child(uid).observe(.value) { (snapshot) in
            print(snapshot.value ?? "")
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            self.user = .init(uid: uid, dictionary: dictionary)
            self.navigationItem.title = self.user?.username
            self.collectionView.reloadData()
            self.fetchOrderedPosts()
        } withCancel: { (error) in
            print(error)
        }

    }

}

extension UserProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileCell.cellId, for: indexPath) as? UserProfileCell else { return .init() }
        let post = posts[indexPath.item]
        cell.post = post
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 2) / 3
        return .init(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension UserProfileController: UICollectionViewDelegateFlowLayout {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserProfileHeader.cellId, for: indexPath) as? UserProfileHeader else { return .init() }
        header.user = user
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 200)
    }
}
