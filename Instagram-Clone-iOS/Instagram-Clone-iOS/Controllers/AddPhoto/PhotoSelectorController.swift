//
//  PhotoSelectorController.swift
//  Instagram-Clone-iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/04/21.
//

import UIKit
import Photos
private let headerId = "headerId"

class PhotoSelectorController: UICollectionViewController {

    var images: [UIImage] = .init()
    var selectedImage: UIImage?
    var assets: [PHAsset] = .init()
    var header: PhotoSelectorCell?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UINib(nibName: PhotoSelectorCell.cellId, bundle: nil), forCellWithReuseIdentifier: PhotoSelectorCell.cellId)
        collectionView.register(UINib(nibName: PhotoSelectorCell.cellId, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PhotoSelectorCell.cellId)
        collectionView.backgroundColor = .white
        setupNavigationButtons()
        fetchPhotos()
    }

    func setupNavigationButtons() {
        let leftButtonItem: UIBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        let rightButtonItem: UIBarButtonItem = .init(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        navigationItem.leftBarButtonItem = leftButtonItem
        navigationItem.rightBarButtonItem = rightButtonItem
        navigationController?.navigationBar.tintColor = .black
    }

    func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetFetchOptions())

        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager: PHImageManager = .default()
                let targetSize: CGSize = .init(width: 200, height: 200)
                let options: PHImageRequestOptions = .init()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }

    @objc func handleNext() {
        let shareController: SharePhotoController = .init()
        navigationController?.pushViewController(shareController, animated: true)
        shareController.selectedImage = header?.photoImageView.image
    }
    @objc func handleCancel() {
        dismiss(animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoSelectorCell.cellId, for: indexPath) as? PhotoSelectorCell else { return .init() }
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        collectionView.reloadData()
        let indexPath: IndexPath = .init(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }


    fileprivate func assetFetchOptions() -> PHFetchOptions {
        let fetchOptions: PHFetchOptions = .init()
        fetchOptions.fetchLimit = 10
        let sortDescriptor: NSSortDescriptor = .init(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }


}

extension PhotoSelectorController {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PhotoSelectorCell.cellId, for: indexPath) as? PhotoSelectorCell else { return .init() }
        self.header = header
        header.photoImageView.image = selectedImage
        let imageManager: PHImageManager = .default()

        if let selectedImage = selectedImage {
            if let index = self.images.firstIndex(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let targetSize: CGSize = .init(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, info) in
                    header.photoImageView.image = image
                }
            }
        }

        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.bounds.width
        return .init(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 1, left: 0, bottom: 0, right: 0)
    }
}

extension PhotoSelectorController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 3) / 4
        return .init(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
