//
//  TPCAlbum.h
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/10.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class TPCPhoto;
@interface TPCAlbum : NSObject
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) NSObject *collection;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSArray<TPCPhoto *> *photoes;
+ (instancetype)albumWithTitle:(NSString *)title count:(NSInteger)count collection:(NSObject *)collection image:(UIImage *)image;
@end

@interface TPCPhoto : NSObject
@property (strong, nonatomic) NSObject *asset;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) NSInteger index;
@property (copy, nonatomic) NSString *representedAssetIdentifier;
+ (NSArray *)assetsWithPhotoes:(NSArray *)photoes;
+ (instancetype)photoWithAsset:(NSObject *)asset selected:(BOOL)selected index:(NSInteger)index;
@end
