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
    var isFinishedPaging = false
    var isGridView = true

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: UserProfileHeader.cellId, bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: UserProfileHeader.cellId)
        collectionView.register(UINib(nibName: UserProfileCell.cellId, bundle: nil), forCellWithReuseIdentifier: UserProfileCell.cellId)
        collectionView.register(UINib(nibName: HomePostCell.cellId, bundle: nil), forCellWithReuseIdentifier: HomePostCell.cellId)
        fetchUser()
        setupLogOutButton()
    }

    fileprivate func paginatePosts() {
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        let database = Database.database().reference().child("posts").child(uid)
        var query = database.queryOrderedByKey()
//        var query = database.queryOrdered(byChild: "creationDate")
        if posts.count > 0 {
            guard let value = posts.last?.id else { return }
//            guard let value = posts.last?.creationDate.timeIntervalSince1970 else { return }
            query = query.queryEnding(atValue: value)
        }
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in


            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.reverse()
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }

            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }

            guard let user = self.user else { return }
            allObjects.forEach { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
            }

            self.collectionView.reloadData()
        } withCancel: { (error) in
            print("Failed to paginate for posts:", error)
        }

    }

    func fetchUser() {
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        Database.fetchUserWithUID(uid: uid) { result in
            switch result {
            case .success(let user):
                self.user = user
                self.navigationItem.title = self.user?.username
                self.collectionView.reloadData()
                self.paginatePosts()
            case .failure(let error):
                print("errro 1:", error)
            }
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

}

extension UserProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            paginatePosts()
        }
        if isGridView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileCell.cellId, for: indexPath) as? UserProfileCell else { return .init() }
            let post = posts[indexPath.item]
            cell.post = post
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.cellId, for: indexPath) as? HomePostCell else { return .init() }
            cell.post = posts[indexPath.item]
            cell.delegate = self
            return cell
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (collectionView.frame.width - 2) / 3
            return .init(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8
            height += collectionView.bounds.width
            height += 50
            height += 60
            return .init(width: collectionView.bounds.width, height: height)
        }
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
        header.delegate = self
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 200)
    }
}

extension UserProfileController: UserProfileHeaderDelegate {

    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }

    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }

}

extension UserProfileController: HomePostCellDelegate {

    func didTapComment(post: Post) {
        let commentsController: CommentsController = .init()
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }

    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
        Database.saveLikes(post: post) { result in
            switch result {
            case .success():
                post.hasLiked = !post.hasLiked
                self.posts[indexPath.item] = post
                self.collectionView.reloadItems(at: [indexPath])
            case .failure(_):
                break
            }
        }
    }
}
