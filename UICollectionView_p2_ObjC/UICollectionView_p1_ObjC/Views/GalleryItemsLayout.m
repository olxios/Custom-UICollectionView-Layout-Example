//
//  GalleryItemsLayout.m
//  UICollectionView_p1_ObjC
//
//  Created by Olga Dalton on 24/11/16.
//  Copyright © 2016 Olga Dalton. All rights reserved.
//

#import "GalleryItemsLayout.h"

@interface GalleryItemsLayout()
{
    NSMutableDictionary *_layoutAttributes;
    CGSize _contentSize;
}
    
@end

@implementation GalleryItemsLayout
    
#pragma mark - 
#pragma mark - Layout
    
- (void)prepareLayout
{
    [super prepareLayout];
        
    _layoutAttributes = [NSMutableDictionary dictionary]; // 1
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
        
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:path];
    attributes.frame = CGRectMake(0, 0, self.collectionView.frame.size.width, self.itemHeight / 4.0f);
        
    NSString *headerKey = [self layoutKeyForHeaderAtIndexPath:path];
    _layoutAttributes[headerKey] = attributes; // 2
        
    NSUInteger numberOfSections = [self.collectionView numberOfSections]; // 3
        
    CGFloat yOffset = self.itemHeight / 4.0f;
        
    for (int section = 0; section < numberOfSections; section++)
    {
        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section]; // 3
            
        CGFloat xOffset = self.horizontalInset;
            
        for (int item = 0; item < numberOfItems; item++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath]; // 4
                
            CGSize itemSize = CGSizeZero;
                
            BOOL increaseRow = NO;
                
            if (self.collectionView.frame.size.width - xOffset > self.maximumItemWidth * 1.5f)
            {
                itemSize = [self randomItemSize]; // 5
            }
            else
            {
                itemSize.width = self.collectionView.frame.size.width - xOffset - self.horizontalInset;
                itemSize.height = self.itemHeight;
                increaseRow = YES; // 6
            }
                
            attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height));
            NSString *key = [self layoutKeyForIndexPath:indexPath];
            _layoutAttributes[key] = attributes; // 7
                
            xOffset += itemSize.width;
            xOffset += self.horizontalInset; // 8
            
            if (increaseRow
                && !(item == numberOfItems-1 && section == numberOfSections-1)) // 9
            {
                yOffset += self.verticalInset;
                yOffset += self.itemHeight;
                xOffset = self.horizontalInset;
            }
        }
    }
        
    yOffset += self.itemHeight; // 10
        
    _contentSize = CGSizeMake(self.collectionView.frame.size.width, yOffset + self.verticalInset); // 11
}
    
#pragma mark -
#pragma mark - Helpers
    
#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))
    
- (CGSize)randomItemSize
{
    return CGSizeMake([self getRandomWidth], self.itemHeight);
}
    
- (CGFloat)getRandomWidth
{
    return RAND_FROM_TO(self.minimumItemWidth, self.maximumItemWidth);
}
    
- (NSString *)layoutKeyForIndexPath:(NSIndexPath *)indexPath
{
    return [NSString stringWithFormat:@"%ld_%ld", (long)indexPath.section, (long)indexPath.row];
}
    
- (NSString *)layoutKeyForHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    return [NSString stringWithFormat:@"s_%ld_%ld", (long)indexPath.section, (long)indexPath.row];
}
    
#pragma mark - 
#pragma mark - Layout attributes

- (CGSize)collectionViewContentSize
{
    return _contentSize;
}
    
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *headerKey = [self layoutKeyForHeaderAtIndexPath:indexPath];
    return _layoutAttributes[headerKey];
}
    
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self layoutKeyForIndexPath:indexPath];
    return _layoutAttributes[key];
}
    
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        UICollectionViewLayoutAttributes *layoutAttribute = _layoutAttributes[evaluatedObject];
        return CGRectIntersectsRect(rect, [layoutAttribute frame]);
    }];
        
    NSArray *matchingKeys = [[_layoutAttributes allKeys] filteredArrayUsingPredicate:predicate];
    return [_layoutAttributes objectsForKeys:matchingKeys notFoundMarker:[NSNull null]];
}
    
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return !(CGSizeEqualToSize(newBounds.size, self.collectionView.frame.size));
}
    
@end
