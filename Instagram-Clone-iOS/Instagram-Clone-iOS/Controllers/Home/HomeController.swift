//
//  HomeController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit
import Firebase

class HomeController: UIViewController, UICollectionViewDelegate {

    var posts: [Post] = .init()

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl: UIRefreshControl = .init()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: HomePostCell.cellId, bundle: nil), forCellWithReuseIdentifier: HomePostCell.cellId)
        setupNavigationItems()

        fetchPosts()

        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: .updateFeed, object: nil)
    }

    @objc func handleUpdateFeed() {
        fetchPosts()
    }

    @objc func handleRefresh() {
        fetchPosts()
    }

    func fetchPosts() {
        Database.fetchMyAndFollowersPosts { result in
            switch result {
            case .success(let posts):
                self.posts = posts
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            case .failure(let error):
                print("Failed to fetch posts:", error)
            }
        }
    }

    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        navigationItem.leftBarButtonItem = .init(image: #imageLiteral(resourceName: "camera3"), style: .plain, target: self, action: #selector(handleCamera))
    }

    @objc func handleCamera() {
        print("Showing camera")
        let cameraController: CameraController = .init()
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController, animated: true, completion: nil)
    }

}

extension HomeController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.cellId, for: indexPath) as? HomePostCell else { return .init() }
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }

}

extension HomeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 40 + 8 + 8
        height += collectionView.bounds.width
        height += 50
        height += 60
        return .init(width: collectionView.bounds.width, height: height)
    }
}

extension HomeController: HomePostCellDelegate {

    func didTapComment(post: Post) {
//        let commentsController: CommentsController = .init(collectionViewLayout: UICollectionViewFlowLayout())
        let commentsController: CommentsController = .init()
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }

}
