//
//  FirebaseUtils+Storage.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 11/04/21.
//

import Firebase

extension Storage {
    //MARK:- Share
    static func saveSharePost(postImage: UIImage, caption: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uploadData = postImage.jpegData(compressionQuality: 0.5) else { return }
        let filename = NSUUID().uuidString
        let storage = Storage.storage().reference().child("posts").child(filename)
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
                print("Failed to upload post image:", error)
                return
            }

            storage.downloadURL { (url, error) in
                if let error = error {
                    print("Failed to get image url:", error)
                    completion(.failure(error))
                    return
                }
                guard let imageUrl = url else { return }
                print("Successfully uploaded post image:", imageUrl)
                Database.savePostToDatabaseWithImageURL(postImage: postImage, caption: caption, imageUrl: imageUrl.absoluteString) { result in
                    switch result {
                    case .success():
                        completion(.success(()))
                    case .failure(let error):
                        print("Failed to save image to database:", error)
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
