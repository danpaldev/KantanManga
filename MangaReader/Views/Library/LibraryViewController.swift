//
//  LibraryViewController.swift
//  MangaReader
//
//  Created by Juan on 2/20/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol LibraryViewControllerDelegate: AnyObject {
    func didSelectAdd(_ libraryViewController: LibraryViewController, button: UIBarButtonItem)
    func didSelectManga(_ libraryViewController: LibraryViewController, manga: Manga)
    func didSelectDeleteManga(_ libraryViewController: LibraryViewController, manga: Manga)
}

class LibraryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: LibraryViewControllerDelegate?
    var mangas = [Manga]() {
        didSet {
            guard collectionView != nil else { return }
            collectionView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Library"
        configureCollectionView()
        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)

        collectionView.register(UINib.init(nibName: "MangaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MangaCell")

        let deleteMenuItem = UIMenuItem(title: "Delete", action: NSSelectorFromString("deleteCollectionCell"))
        UIMenuController.shared.menuItems = [deleteMenuItem]

        let layout = LibraryCollectionViewLayout()
        layout.delegate = self
        collectionView.collectionViewLayout = layout
    }

    func configureNavigationBar() {
        let addButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(add(button:)))
        navigationItem.leftBarButtonItem = addButton
    }

    func heightForImageWith(maxWidth: CGFloat, maxHeight: CGFloat, image: UIImage) -> CGFloat {
        let widthScale = image.size.width / maxWidth
        let heightScale = image.size.height / maxHeight

        if widthScale > heightScale {
            return (image.size.height / widthScale)
        } else {
            return maxHeight
        }
    }

    @objc func add(button: UIBarButtonItem) {
        delegate?.didSelectAdd(self, button: button)
    }
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mangas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MangaCell", for: indexPath) as! MangaCollectionViewCell // swiftlint:disable:this force_cast

        let manga = mangas[indexPath.row]
        manga.loadCoverImage()
        if let image = manga.coverImage {
            cell.coverImageView.image = image
        }
        cell.pageLabel.text = "\(manga.currentPage)/\(manga.totalPages)"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let manga = mangas[indexPath.row]
        delegate?.didSelectManga(self, manga: manga)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let manga = mangas[indexPath.row]
        if let image = manga.coverImage {
            let height = heightForImageWith(maxWidth: 200, maxHeight: 263, image: image) + 37
            return CGSize(width: 200, height: height)
        }

        // Default size
        return CGSize(width: 200, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false//return action == NSSelectorFromString("deleteCollectionCell")
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        delegate?.didSelectDeleteManga(self, manga: mangas[indexPath.row])
    }
}

extension LibraryViewController: LibraryCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForMangaAtIndexPath indexPath: IndexPath) -> CGFloat {
        let manga = mangas[indexPath.row]
        if let image = manga.coverImage {
            let height = heightForImageWith(maxWidth: 200, maxHeight: 263, image: image) + 37
            return height
        }
        return 300
    }
}
