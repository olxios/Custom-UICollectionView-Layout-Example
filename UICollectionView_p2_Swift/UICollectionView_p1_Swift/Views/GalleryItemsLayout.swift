//
//  GalleryItemsLayout.swift
//  UICollectionView_p1_Swift
//
//  Created by Olga Dalton on 24/11/16.
//  Copyright © 2016 Olga Dalton. All rights reserved.
//

import UIKit

class GalleryItemsLayout: UICollectionViewLayout {
    
    var horizontalInset = 0.0 as CGFloat
    var verticalInset = 0.0 as CGFloat
    
    var minimumItemWidth = 0.0 as CGFloat
    var maximumItemWidth = 0.0 as CGFloat
    var itemHeight = 0.0 as CGFloat
    
    var _layoutAttributes = Dictionary<String, UICollectionViewLayoutAttributes>()
    var _contentSize = CGSize.zero
    
    // MARK: -
    // MARK: - Layout
    
    override func prepare() {
        super.prepare()
        
        _layoutAttributes = Dictionary<String, UICollectionViewLayoutAttributes>() // 1
        
        let path = IndexPath(item: 0, section: 0)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: path)
        
        let headerHeight = CGFloat(self.itemHeight / 4)
        attributes.frame = CGRect(x: 0, y: 0, width: self.collectionView!.frame.size.width, height: headerHeight)
        
        let headerKey = layoutKeyForHeaderAtIndexPath(path)
        _layoutAttributes[headerKey] = attributes // 2
        
        let numberOfSections = self.collectionView!.numberOfSections // 3
        
        var yOffset = headerHeight
        
        for section in 0 ..< numberOfSections {
            
            let numberOfItems = self.collectionView!.numberOfItems(inSection: section) // 3
            
            var xOffset = self.horizontalInset
            
            for item in 0 ..< numberOfItems {
                
                let indexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath) // 4
                
                var itemSize = CGSize.zero
                var increaseRow = false
                
                if self.collectionView!.frame.size.width - xOffset > self.maximumItemWidth * 1.5 {
                    itemSize = randomItemSize() // 5
                } else {
                    itemSize.width = self.collectionView!.frame.size.width - xOffset - self.horizontalInset
                    itemSize.height = self.itemHeight
                    increaseRow = true // 6
                }
                
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                let key = layoutKeyForIndexPath(indexPath)
                _layoutAttributes[key] = attributes // 7
                
                xOffset += itemSize.width
                xOffset += self.horizontalInset // 8
                
                if increaseRow
                    && !(item == numberOfItems - 1 && section == numberOfSections - 1) { // 9
                    
                    yOffset += self.verticalInset
                    yOffset += self.itemHeight
                    xOffset = self.horizontalInset
                    
                }
            }
            
        }
        
        yOffset += self.itemHeight // 10
        
        _contentSize = CGSize(width: self.collectionView!.frame.size.width, height: yOffset + self.verticalInset) // 11
        
    }
    
    // MARK: -
    // MARK: - Helpers
    
    func randomItemSize() -> CGSize {
        return CGSize(width: getRandomWidth(), height: self.itemHeight)
    }
    
    func getRandomWidth() -> CGFloat {
        let range = UInt32(self.maximumItemWidth - self.minimumItemWidth + 1)
        let random = Float(arc4random_uniform(range))
        return CGFloat(self.minimumItemWidth) + CGFloat(random)
    }

    
    func layoutKeyForIndexPath(_ indexPath : IndexPath) -> String {
        return "\(indexPath.section)_\(indexPath.row)"
    }
    
    func layoutKeyForHeaderAtIndexPath(_ indexPath : IndexPath) -> String {
        return "s_\(indexPath.section)_\(indexPath.row)"
    }
    
    // MARK: -
    // MARK: - Layout attributes
    
    override var collectionViewContentSize: CGSize {
        return _contentSize
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let headerKey = layoutKeyForIndexPath(indexPath)
        return _layoutAttributes[headerKey]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let key = layoutKeyForIndexPath(indexPath)
        return _layoutAttributes[key]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let predicate = NSPredicate {  [unowned self] (evaluatedObject, bindings) -> Bool in
            let layoutAttribute = self._layoutAttributes[evaluatedObject as! String]
            return rect.intersects(layoutAttribute!.frame)
        }
        
        let dict = _layoutAttributes as NSDictionary
        let keys = dict.allKeys as NSArray
        let matchingKeys = keys.filtered(using: predicate)
        
        return dict.objects(forKeys: matchingKeys, notFoundMarker: NSNull()) as? [UICollectionViewLayoutAttributes]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !newBounds.size.equalTo(self.collectionView!.frame.size)
    }
}
