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
    func didSelectSettings(_ libraryViewController: LibraryViewController)
    func didSelectCollection(_ libraryViewController: LibraryViewController, collection: MangaCollectionable)
}

class LibraryViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private weak var delegate: LibraryViewControllerDelegate?
    private var collections = [MangaCollectionable]()

    init(delegate: LibraryViewControllerDelegate, collections: [MangaCollectionable]) {
        self.delegate = delegate
        self.collections = collections
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func setCollections(collections: [MangaCollectionable]) {
        self.collections = collections
        self.collectionView.reloadData()
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)

        collectionView.register(UINib(nibName: "MangaCollectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MangaCell")
    }

    private func configureNavigationBar() {
        let addButton = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(add(button:)))
        navigationItem.leftBarButtonItem = addButton

        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settings(button:)))
        navigationItem.rightBarButtonItem = settingsButton
    }

    private func heightForImageWith(maxWidth: CGFloat, maxHeight: CGFloat, image: UIImage) -> CGFloat {
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

    @objc func settings(button: UIBarButtonItem) {
        delegate?.didSelectSettings(self)
    }
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MangaCell", for: indexPath) as! MangaCollectionCollectionViewCell // swiftlint:disable:this force_cast

        let collection = collections[indexPath.row]
        let mangas = collection.mangas.prefix(3)
        mangas.forEach { $0.loadCoverImage() }
        let images = mangas.map { $0.coverImage ?? UIImage() }
        cell.setImages(images)
        cell.nameLabel.text = collection.name

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCollection(self, collection: collections[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 300)
    }
}
