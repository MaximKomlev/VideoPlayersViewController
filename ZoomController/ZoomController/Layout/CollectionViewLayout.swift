//
//  CollectionViewLayout.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/24/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

protocol CollectionViewLayoutDelegate: class {
    var itemsCount: Int { get }
    
    func itemSize(index: Int, widthConstrained: CGFloat) -> CGSize
}

protocol CollectionViewLayoutProtocol: class {
    var itemSpace: CGFloat { get set }
    var boundaryMargin: CGFloat { get set }
   
    var contentSize: CGSize { get }
    
    init(layoutDelegate: CollectionViewLayoutDelegate)
    
    func performLayout(_ size: CGSize)
    func itemRect(for index: Int) -> CGRect
}

class CollectionViewLayout: CollectionViewLayoutProtocol {
    
    // MARK: Fields
    
    private weak var layoutDelegate: CollectionViewLayoutDelegate?
    private var itemsRect = [CGRect]()

    // MARK: Initializers/Deinitializer
    
    required init(layoutDelegate: CollectionViewLayoutDelegate) {
        self.layoutDelegate = layoutDelegate
    }
    
    // MARK: CollectionViewLayoutProtocol
    
    var itemSpace: CGFloat = 0
    var boundaryMargin: CGFloat = 0
    
    private(set) var contentSize: CGSize = CGSize.zero
     
    func performLayout(_ size: CGSize) {
        guard let delegate = layoutDelegate else {
            return
        }
        
        itemsRect = [CGRect](repeating: CGRect.zero, count: delegate.itemsCount)
        
        // get content width
        contentSize.width = size.width - 2 * boundaryMargin

        // get actual width minus boundary margin
        let width = contentSize.width
        
        var rows = [[Int]]()

        // create grid for items, it depends item width
        // and how many of them can be lined in to row
        var itemIndex = 0
        var currentRowIndex = 0
        var leftWidth = width
        while itemIndex < delegate.itemsCount {
            let itemWitdh = delegate.itemSize(index: itemIndex, widthConstrained: width).width
            if rows.count == currentRowIndex {
                rows.append([Int]())
            }
            var row = rows[currentRowIndex]
            if row.count == 0 {
                row.append(itemIndex)
                leftWidth -= itemWitdh
            } else {
                let itemWidthWithSpace = itemWitdh + itemSpace
                if leftWidth - itemWidthWithSpace > 0 {
                    row.append(itemIndex)
                    leftWidth -= itemWidthWithSpace
                } else {
                    currentRowIndex += 1
                    leftWidth = width
                    continue
                }
            }
            rows[currentRowIndex] = row
            itemIndex += 1
        }
        
        // layout items by X, center items by X
        itemIndex = 0
        currentRowIndex = 0
        while currentRowIndex < rows.count {
            var rowItemIndex = 0
            let rowItems = rows[currentRowIndex]

            var rowWidth = CGFloat(0)
            while rowItemIndex < rowItems.count {
                let itemSize = delegate.itemSize(index: itemIndex, widthConstrained: width)
                rowWidth += (itemSize.width + itemSpace)
                
                rowItemIndex += 1
                itemIndex += 1
            }
            rowWidth -= itemSpace

            itemIndex -= rowItems.count
            rowItemIndex = 0
            var x = boundaryMargin + (width - rowWidth) / 2
            while rowItemIndex < rowItems.count {
                var rect = itemsRect[itemIndex]
                let itemSize = delegate.itemSize(index: itemIndex, widthConstrained: width)
                rect.origin.x = x
                rect.size = itemSize
                itemsRect[itemIndex] = rect
                
                itemIndex += 1
                rowItemIndex += 1
                x += (itemSize.width + itemSpace)
            }
            currentRowIndex += 1
        }
        
        // layout items by Y,
        // items vertically will fill available space following just rules of spacing between items,
        // to take up available space as much as possible without breaking order of items,
        // and considering totatly different size/resolution of items.
        var maxHeight = CGFloat(0)
        itemIndex = 0
        currentRowIndex = 0
        let rowItems = rows[currentRowIndex]
        var rowItemIndex = 0
        
        // align elements of first row
        while rowItemIndex < rowItems.count {
            var rect = itemsRect[itemIndex]
            rect.origin.y = boundaryMargin
            itemsRect[itemIndex] = rect
            
            if maxHeight < rect.maxY {
                maxHeight = rect.maxY + itemSpace
            }

            itemIndex += 1
            rowItemIndex += 1
        }
        currentRowIndex += 1
        
        contentSize.height += (maxHeight + boundaryMargin)

        // align elements of all rows
        while currentRowIndex < rows.count {
            let aboveRowItemsCount = rows[currentRowIndex - 1].count
            var aboveRowItemsIndex = 0
            var aboveItemsIndex = itemIndex - aboveRowItemsCount
            let rowItems = rows[currentRowIndex]
            rowItemIndex = 0
            while rowItemIndex < rowItems.count {
                var rect = itemsRect[itemIndex]
                var maxY = itemsRect[aboveItemsIndex].maxY
                rect.origin.y = getY(rect: rect,
                                     maxY: &maxY,
                                     aboveItemsIndex: &aboveItemsIndex,
                                     aboveRowItemIndex: &aboveRowItemsIndex,
                                     aboveRowItemsCount: aboveRowItemsCount)
                itemsRect[itemIndex] = rect

                if maxHeight < rect.maxY {
                    maxHeight = rect.maxY + itemSpace
                }

                itemIndex += 1
                rowItemIndex += 1
            }
            
            currentRowIndex += 1
            contentSize.height = maxHeight
            maxHeight = 0
        }

        contentSize.height += (boundaryMargin - itemSpace)

        // calculate center of rects
        for i in 0..<itemsRect.count {
            var rect = itemsRect[i]
            rect.origin.x += rect.width / 2
            rect.origin.y += rect.height / 2
            itemsRect[i] = rect
        }
    }
    
    func itemRect(for index: Int) -> CGRect {
        if index >= 0 && index < itemsRect.count {
            return itemsRect[index]
        }
        return CGRect.zero
    }
    
    // MARK: Helpers
    
    private func getY(rect: CGRect,
                      maxY: inout CGFloat,
                      aboveItemsIndex: inout Int,
                      aboveRowItemIndex: inout Int,
                      aboveRowItemsCount: Int) -> CGFloat {
        let aboveRect = itemsRect[aboveItemsIndex]
        maxY = max(aboveRect.maxY, maxY)
        let rightX = rect.maxX
        if rightX <= aboveRect.maxX ||
            aboveRowItemIndex + 1 == aboveRowItemsCount {
            if rightX == aboveRect.maxX {
                aboveItemsIndex += 1
                aboveRowItemIndex += 1
            }
            return maxY + itemSpace
        } else {
            aboveItemsIndex += 1
            aboveRowItemIndex += 1
            return getY(rect: rect,
                        maxY: &maxY,
                        aboveItemsIndex: &aboveItemsIndex,
                        aboveRowItemIndex: &aboveRowItemIndex,
                        aboveRowItemsCount: aboveRowItemsCount)
        }
    }

}
