//
//  WKJAssetsPicker.h
//  WKJAssetPickerDemo
//
//  Created by 王恺靖 on 15/12/16.
//  Copyright © 2015年 王恺靖. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@protocol WKJAssetsPickerDelegate;

@interface WKJAssetsPicker : UIViewController

// The WKJAssetsPicker's delegate
@property (assign, nonatomic) id<WKJAssetsPickerDelegate>delegate;

// The miaxmum number of image to pick
@property (assign, nonatomic) NSInteger maxmumNumber;

@end

@protocol WKJAssetsPickerDelegate <NSObject>
// Tells the Picker should return original images
- (BOOL)assetsPickerShouldReturnOriginalPhotos;

// Tells the delegate that the user finish picking photos
- (void)assetsPickerController:(WKJAssetsPicker*)picker didFinishedPickingPhotos:(NSArray*)photos;

// Tells the delegate that the user finish take photos
- (void)assetsPickerController:(WKJAssetsPicker*)picker didFinishedTakePhotos:(UIImage*)photo;

@optional

// Tells the delegate that the photo at the index path was selected.
- (void)assetsPickerController:(WKJAssetsPicker *)picker didSelectPhotoAtIndexPath:(NSIndexPath *)indexPath;

@end
