//
//  WKJAssetsPickCell.h
//  WKJAssetPickerDemo
//
//  Created by 王恺靖 on 15/12/17.
//  Copyright © 2015年 王恺靖. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKJAsset.h"

@protocol WKJAssetsPickCellDelegate <NSObject>

- (void)didSelectAsset:(WKJAsset *)asset;

@end

@interface WKJAssetsPickCell : UICollectionViewCell

@property (assign, nonatomic) BOOL takePhoto;

@property (strong, nonatomic) WKJAsset *asset;

@property (nonatomic, weak) id <WKJAssetsPickCellDelegate> delegate;

@end
