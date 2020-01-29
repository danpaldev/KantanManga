//
//  Manga+CoreDataClass.swift
//  MangaReader
//
//  Created by admin on 2/25/19.
//  Copyright © 2019 Bakura. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Manga)
public class Manga: NSManagedObject {
    private(set) public var coverImage = UIImage()

    convenience init(context: NSManagedObjectContext, coverData: Data, totalPages: Int16, filePath: String, currentPage: Int16 = 0, createdAt: Date = Date(), lastViewedAt: Date? = nil) {
        self.init(context: context)
        self.coverData = coverData
        self.totalPages = totalPages
        self.filePath = filePath
        self.currentPage = currentPage
        self.createdAt = createdAt
        self.lastViewedAt = lastViewedAt
    }

    override public func awakeFromFetch() {
        super.awakeFromFetch()

        // Preload image data
        if let data = coverData, let image = UIImage(data: data) {
            coverImage = image
        }
    }
}
