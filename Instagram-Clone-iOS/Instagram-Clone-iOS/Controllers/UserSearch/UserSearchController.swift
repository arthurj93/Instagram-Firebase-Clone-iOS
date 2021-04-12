//
//  UserSearchController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 09/04/21.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController {

    var users: [User] = .init()
    var filteredUsers: [User] = .init()
    var timer: Timer?
    let searchController: UISearchController = {
        let sc: UISearchController = .init(searchResultsController: nil)
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(UINib(nibName: UserSearchCell.cellId, bundle: nil), forCellWithReuseIdentifier: UserSearchCell.cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        setupSearchBar()
        fetchUsers()
    }

    func fetchUsers() {
        let database = Database.database().reference().child("users")
        database.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach { (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    print("Found myself, omit from list")
                    return
                }
                guard let userDictionary = value as? [String: Any] else { return }
                let user: User = .init(uid: key, dictionary: userDictionary)
                self.users.append(user)
                print(user.uid, user.username)
            }
            self.users.sort { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            }
            self.filteredUsers = self.users
            self.collectionView.reloadData()
        } withCancel: { (error) in
            print("Failed to fetch users:", error)
        }

    }

    private func setupSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Enter username"
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserSearchCell.cellId, for: indexPath) as? UserSearchCell else { return .init() }
        cell.user = filteredUsers[indexPath.item]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filteredUsers[indexPath.item]
        let userProfileController: UserProfileController = .init(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }

}

extension UserSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 66)
    }
}

extension UserSearchController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { user in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
    }

}
