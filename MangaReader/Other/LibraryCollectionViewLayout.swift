//
//  LibraryCollectionViewLayout.swift
//  MangaReader
//
//  Created by Juan on 2/25/19.
//  Copyright © 2019 Bakura. All rights reserved.
//

import UIKit

protocol LibraryCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForMangaAtIndexPath indexPath: IndexPath) -> CGFloat
}

class LibraryCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: LibraryCollectionViewLayoutDelegate!

    var cellWidth: CGFloat = 200
    var cellHeight: CGFloat = 300
    var cache = [UICollectionViewLayoutAttributes]()
    var contentHeight: CGFloat = 0
    var cellMinimumPadding: CGFloat = 10
    var cellVerticalPadding: CGFloat = 15
    var numberOfColumns: Int {
        var possibleNumberOfColumns = floor(contentWidth / cellWidth)
        while (possibleNumberOfColumns * cellWidth) + (cellMinimumPadding * (possibleNumberOfColumns - 1)) > contentWidth {
            possibleNumberOfColumns -= 1
        }
        return Int(possibleNumberOfColumns)
    }
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }

        cache = [UICollectionViewLayoutAttributes]()
        contentHeight = 0

        var column: Int = 0
        var row = 0
        var rowsHeight: [CGFloat] = {
            var rows = [CGFloat]()
            for _ in 0 ..< calculateNumberOfRows() {
                rows.append(0.0)
            }
            return rows
        }()
        var currentRow = [UICollectionViewLayoutAttributes]()
        var totalHeight: CGFloat = 0
        let padding: CGFloat
        if numberOfColumns == 1 {
            // Prevent division by 0
            padding = (contentWidth - cellWidth) / 2
        } else {
            padding = (contentWidth - (CGFloat(numberOfColumns) * cellWidth)) / (CGFloat(numberOfColumns) - 1)
        }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        for item in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let height = delegate.collectionView(collectionView, heightForMangaAtIndexPath: indexPath)
            rowsHeight[row] = max(rowsHeight[row], height)
            var xPos = CGFloat(column) * (cellWidth + padding)
            if column == 0 && numberOfColumns == 1 {
                xPos += padding
            }
            let frame = CGRect(x: xPos, y: height, width: cellWidth, height: height)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            currentRow.append(attributes)

            column += 1
            if column >= numberOfColumns || item == numberOfItems - 1 {
                for attributes in currentRow {
                    attributes.frame.origin.y = totalHeight + cellVerticalPadding + rowsHeight[row] - attributes.frame.origin.y
                    cache.append(attributes)
                }
                currentRow = [UICollectionViewLayoutAttributes]()
                totalHeight += rowsHeight[row]
                row += 1
                column = 0
            }
        }
        contentHeight = max(contentHeight, cache.last?.frame.maxY ?? 0)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }

        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

    private func calculateNumberOfRows() -> Int {
        guard let collectionView = collectionView else {
            return 0
        }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let numberOfRows = ceil(Float(numberOfItems) / Float(numberOfColumns))

        return Int(numberOfRows)
    }
}
