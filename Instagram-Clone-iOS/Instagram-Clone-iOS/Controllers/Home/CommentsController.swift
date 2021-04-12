//
//  CommentsController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 12/04/21.
//

import UIKit
import Firebase

class CommentsController: UIViewController {

    var post: Post?
    var comments: [Comment] = .init()

    var containerView = CommentsContainerView.initFromNib()

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: CommentCell.cellId, bundle: nil), forCellWithReuseIdentifier: CommentCell.cellId)
        collectionView.keyboardDismissMode = .interactive
        fetchComments()
    }

    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func fetchComments() {
        guard let postId = post?.id else { return }

        Database.fetchComments(postId: postId) { result in
            switch result {
            case .success(let comment):
                self.comments.append(comment)
                self.collectionView.reloadData()
            case .failure(let error):
                print("Failed to observe comments:", error)
            }
        }
    }
}

extension CommentsController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.cellId, for: indexPath) as? CommentCell else { return .init() }
        cell.comment = comments[indexPath.item]

        return cell
    }
}

extension CommentsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let frame: CGRect = .init(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell.initFromNib()
        dummyCell.frame = frame
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        let targetSize: CGSize = .init(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)

        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return .init(width: collectionView.bounds.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CommentsController: CommentsContainerViewDelegate {

    func didSubmitComment(comment: String) {
        print("submit")
        print("postId:", post?.id ?? "nao tem id")
        guard let postId = post?.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let database = Database.database().reference().child("comments").child(postId).childByAutoId()
        let values = ["text": comment, "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        database.updateChildValues(values) { (error, reference) in
            if let error = error {
                print("Failed to insert comment:", error)
                return
            }

            print("Successfully insert comment")
        }
    }
}

