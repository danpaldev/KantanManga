//
//  FakeLibraryViewController.swift
//  MangaReaderTests
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

@testable import Kantan_Manga

class FakeLibraryViewController: LibraryViewController {
    override var collectionView: UICollectionView! {
        get {
            return FakeCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        }
        set {
            _ = newValue
        }
    }

    init(collections: [MangaCollectionable] = []) {
        super.init(delegate: FakeLibraryViewControllerDelegate(), collections: collections)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setCollections(collections: [MangaCollectionable]) {}
}
