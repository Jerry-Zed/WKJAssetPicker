//
//  WKJAssetsPickCell.m
//  WKJAssetPickerDemo
//
//  Created by 王恺靖 on 15/12/17.
//  Copyright © 2015年 王恺靖. All rights reserved.
//

#import "WKJAssetsPickCell.h"

#define CellSize self.contentView.bounds.size

@implementation WKJAssetsPickCell
{
    UIButton     *_checkIcon;
    UIImageView  *_showPhoto;
}
static UIImage *checkedIcon;

+ (void)initialize
{
    checkedIcon = [UIImage imageNamed:@"WKJAssetsPickerUnChecked"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _showPhoto = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _showPhoto.clipsToBounds = YES;
        _showPhoto.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_showPhoto];
        
        _checkIcon = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkIcon.frame = CGRectMake(_showPhoto.bounds.size.width-40, 5, 35, 35);
        _checkIcon.alpha = 0.5;
        
        [_checkIcon setImage:[UIImage imageNamed:@"WKJAssetsPickerUnChecked"]
                    forState:UIControlStateNormal];
        [_checkIcon setImage:[UIImage imageNamed:@"WKJAssetsPickerChecked"]
                    forState:UIControlStateSelected];
        
        [_checkIcon addTarget:self
                       action:@selector(checkIconAction)
             forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_checkIcon];
    }
    return self;
}

- (void)setAsset:(WKJAsset *)asset
{
    _asset = asset;
    
    _checkIcon.alpha = asset.selected ? 1.f:0.5f;
    _checkIcon.selected = asset.selected;
    
    if (asset.image == nil) {
        [self requestAsset:asset.asset];
    }
    else {
        _showPhoto.image = asset.image;
    }
}

- (void)setTakePhoto:(BOOL)takePhoto
{
    _checkIcon.hidden = takePhoto;
    _showPhoto.image = takePhoto ? [UIImage imageNamed:@"WKJAssetsPickerTakePhoto"]:nil;
}

- (void)requestAsset:(PHAsset *)asset
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = NO;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    CGSize size = CGSizeMake(200, 200);
    
    __block typeof(_showPhoto) weakImage = _showPhoto;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakImage.image = result;
            self.asset.image = result;
        });
    }];
}

- (void)checkIconAction
{
    if ([self.delegate respondsToSelector:@selector(didSelectAsset:)]) {
        [self.delegate didSelectAsset:self.asset];
    }
}

@end
