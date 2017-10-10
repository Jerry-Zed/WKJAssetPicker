//
//  WKJAsset.h
//  Logistics
//
//  Created by 王恺靖 on 2017/10/10.
//  Copyright © 2017年 王恺靖. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface WKJAsset : NSObject

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, strong) UIImage *image;

@end
