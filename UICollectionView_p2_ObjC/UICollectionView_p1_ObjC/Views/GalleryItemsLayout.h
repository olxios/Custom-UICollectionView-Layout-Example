//
//  GalleryItemsLayout.h
//  UICollectionView_p1_ObjC
//
//  Created by Olga Dalton on 24/11/16.
//  Copyright © 2016 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryItemsLayout : UICollectionViewLayout
    
@property (nonatomic, readonly) CGFloat horizontalInset;
@property (nonatomic, readonly) CGFloat verticalInset;
    
@property (nonatomic, readonly) CGFloat minimumItemWidth;
@property (nonatomic, readonly) CGFloat maximumItemWidth;
@property (nonatomic, readonly) CGFloat itemHeight;

@end
