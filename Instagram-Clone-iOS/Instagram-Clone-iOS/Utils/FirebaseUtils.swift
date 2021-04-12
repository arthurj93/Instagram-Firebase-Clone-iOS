//
//  FirebaseUtils.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 09/04/21.
//

import Firebase

extension Database {

    //checar se nao pode juntar as duas numa só

    //MARK:- Users

    static func fetchUserWithUID(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user: User = .init(uid: uid, dictionary: userDictionary)
            completion(.success(user))
        } withCancel: { (error) in
            completion(.failure(error))
        }
    }

    //MARK:- Posts

    static func fetchPostsWithUser(_ user: User, completion: @escaping (Result<[Post], Error>) -> Void) {
        let database = Database.database().reference().child("posts").child(user.uid)
        database.observeSingleEvent(of: .value) { (snapshot) in
            var posts: [Post] = .init()
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach { (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                var post: Post = .init(user: user, dictionary: dictionary)
                post.id = key
                posts.append(post)
            }
            completion(.success(posts))
        } withCancel: { (error) in
            completion(.failure(error))
            print("Failed to fetch posts:", error)
        }
    }


    static func fetchMyAndFollowersPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        fetchMyPosts { result in
            switch result {
            case .success(let myPosts):
                //AFTER FETCHING MY POSTS WILL FETCH MY FOLLOWERS POSTS
                self.fetchMyFollowersPosts(uid: uid, myPosts: myPosts) { result in
                    switch result {
                    case .success(let allPosts):
                        completion(.success(allPosts))
                    case .failure(let error):
                        completion(.failure(error))
                        print("Failed to fetch all posts")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    static func fetchMyPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        //FETCH CURRENT USER POSTS
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (result) in
            switch result {
            case .success(let user):
                Database.fetchPostsWithUser(user) { result in
                    switch result {
                    case .success(let posts):
                        completion(.success(posts))
                        print("Successfully fetch my posts")
                    case .failure(let error):
                        completion(.failure(error))
                        print("Failed to fetch my posts:", error)
                    }
                }
            case .failure(let error):
                print("Failed to fetch user:", error)
            }
        }
    }

    static func fetchMyFollowersPosts(uid: String, myPosts: [Post], completion: @escaping (Result<[Post], Error>) -> Void) {

        var allPosts = myPosts
        let database = Database.database().reference().child("following").child(uid)
        //FETCH MY FOLLOWERS AND RETURN A LIST OF USERS
        database.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                print("nao tenho seguidores")
                completion(.success(sortPosts(posts: allPosts)))
                return
            }
            guard let userIdDictionary = snapshot.value as? [String: Any] else { return }
            //TO GET THEIR POSTS INDIVIDUALLY WILL FETCH EATCH USER
            userIdDictionary.forEach { (key, value) in
                print("key é: ", key)
                Database.fetchUserWithUID(uid: key) { result in
                    switch result {
                    case .success(let user):
                        //AFTER GET THE USER WILL FETCH THEIR POSTS
                        Database.fetchPostsWithUser(user) { result in
                            switch result {
                            case .success(let posts):
                                for post in posts {
                                    //APPEND THEIR POSTS WITH MY POSTS ARRAY
                                    allPosts.append(post)
                                }
                                completion(.success(sortPosts(posts: allPosts)))
                            case .failure(let error):
                                completion(.failure(error))
                                print("Failed to fetch users posts:", error)
                            }
                        }
                    case .failure(let error):
                        print("Failed to fetch user:", error)
                    }
                }
            }
        } withCancel: { (error) in
            print("Failed to fetch followers posts:", error)
        }
    }

    //MARK:- Share

    static func savePostToDatabaseWithImageURL(postImage: UIImage, caption: String, imageUrl: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let database = Database.database().reference().child("posts").child(uid)
        let ref = database.childByAutoId()
        let values = ["imageUrl": imageUrl,
                      "caption": caption,
                      "imageWidth": postImage.size.width,
                      "imageHeight": postImage.size.height,
                      "creationDate": Date().timeIntervalSince1970] as [String: Any]
        ref.updateChildValues(values) { (error, reference) in
            if let error = error {
                print("Failed to save post to DB:", error)
                completion(.failure(error))
                return
            }
            print("Successfully save post do DB")
            completion(.success(()))
        }
    }

    static private func sortPosts(posts: [Post]) -> [Post] {
        var allPosts = posts
        allPosts.sort { (p1, p2) in
            return p1.creationDate.compare(p2.creationDate) == .orderedDescending
        }
        return allPosts
    }

    //MARK:- Comments

    static func fetchComments(postId: String, completion: @escaping (Result<Comment, Error>) -> Void) {
        let database = Database.database().reference().child("comments").child(postId)
        database.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }

            Database.fetchUserWithUID(uid: uid) { (result) in
                switch result {
                case .success(let user):
                    let comment: Comment = .init(user: user, dictionary: dictionary)
                    completion(.success(comment))
                case .failure(let error):
                    completion(.failure(error))
                }
            }

        } withCancel: { (error) in
            completion(.failure(error))
            print("Failed to observe comments:", error)
        }
    }

}
