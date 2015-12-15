//
//  TPCAssetManager.h
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/11.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TPCPhotoType) {
    TPCPhotoTypeThumbnail,
    TPCPhotoTypeFullScreen,
    TPCPhotoTypefullResolution,
    TPCPhotoTypeDefault = TPCPhotoTypeThumbnail
};

@class TPCAlbum, TPCPhoto, PHImageManager, ALAssetsLibrary;
@interface TPCAssetManager : NSObject
@property (strong, nonatomic, readonly) NSMutableArray * _Nullable albums;
@property (strong, nonatomic, readonly) PHImageManager * _Nullable imageManager;
@property (strong, nonatomic, readonly) ALAssetsLibrary * _Nullable assetsLibrary;
@property (assign, nonatomic, readonly) BOOL photoKitAvailable;
@property (assign, nonatomic, getter=isFilterEmptyAlbum) BOOL filterEmptyAlbum;
+ (_Nonnull instancetype)sharedManager;
- (void)requestImageWithAsset:(NSObject *_Nullable)asset targetSize:(CGSize)targetSize completion:(void(^_Nullable)(UIImage * _Nullable image))completion;
- (void)requestImageWithAsset:(NSObject *_Nullable)asset targetSize:(CGSize)targetSize type:(TPCPhotoType)type completion:(void (^_Nullable)(UIImage * _Nullable))completion;
- (void)fetchAlbumsWithThumbnailSize:(CGSize)thumbnailSize completion:(void(^ _Nullable)(NSInteger index))completion;
- (void)fetchCameraRollAlbumsWithThumbnailSize:(CGSize)thumbnailSize completion: (void(^ _Nullable)(TPCAlbum * _Nullable album))completion;
- (void)initPhotoesForAlbum:(TPCAlbum * _Nullable)album completion:(void(^ _Nullable)())completion;
@end
