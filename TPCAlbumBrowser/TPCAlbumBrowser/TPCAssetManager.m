//
//  TPCAssetManager.m
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/11.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCAssetManager.h"
#import "TPCAlbum.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TPCAssetManager()
{
    PHImageManager *_imageManager;
    ALAssetsLibrary * _assetsLibrary;
    NSMutableArray *_albums;
}
@property (assign, nonatomic) BOOL photoKitAvailable;
@end

@implementation TPCAssetManager
static TPCAssetManager *_instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        [_instance instanceInitial];
    });
    return _instance;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance instanceInitial];
    });
    return _instance;
}

- (void)instanceInitial {
    _instance.photoKitAvailable = NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1;
    if (_photoKitAvailable) {
        _imageManager = [PHImageManager defaultManager];
    } else {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    _albums = [NSMutableArray array];
    _filterEmptyAlbum = YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (void)setPhotoKitAvailable:(BOOL)photoKitAvailable {
    _photoKitAvailable = photoKitAvailable;
}

- (void)authorizationWithCompletion:(void(^)(BOOL authorized))completion {
    BOOL authorized = NO;
    if (_photoKitAvailable) {
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        authorized = authorizationStatus != PHAuthorizationStatusRestricted && authorizationStatus != PHAuthorizationStatusDenied;
    } else {
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        authorized = authorizationStatus != ALAuthorizationStatusRestricted && authorizationStatus != ALAuthorizationStatusDenied;
    }
    !completion ? : completion(authorized);
}

- (void)fetchCameraRollAlbumsWithThumbnailSize:(CGSize)thumbnailSize completion: (void(^)(TPCAlbum *album))completion {
    if (_photoKitAvailable) {
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:smartAlbums.firstObject options:nil];
        if (!assets.count && _filterEmptyAlbum) { return; }
        PHAsset *asset = [assets lastObject];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize targetSize = CGSizeMake(thumbnailSize.width * scale, thumbnailSize.height * scale);
        [_imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            TPCAlbum *album = [TPCAlbum albumWithTitle:[smartAlbums.firstObject localizedTitle] count:assets.count collection:smartAlbums.firstObject image:result];
            !completion ? : completion(album);
        }];
    } else {
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group.numberOfAssets > 0 && _filterEmptyAlbum) {
                TPCAlbum *album = [TPCAlbum albumWithTitle:[group valueForProperty:ALAssetsGroupPropertyName] count:group.numberOfAssets collection:group image:[UIImage imageWithCGImage:[group posterImage]]];
                !completion ? : completion(album);
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)fetchAlbumsWithThumbnailSize:(CGSize)thumbnailSize completion:(void(^)(NSInteger index))completion {
    if (_photoKitAvailable) {
        PHFetchResult *myPhotoStream = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        [self addAlbumsWithFetchResult:myPhotoStream thumbnailSize:thumbnailSize completion:completion];
        [self addAlbumsWithFetchResult:smartAlbums thumbnailSize:thumbnailSize completion:completion];
        [self addAlbumsWithFetchResult:topLevelUserCollections thumbnailSize:thumbnailSize completion:completion];
    } else {
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [self addAlbumsWithGroup:group completion:completion];
        } failureBlock:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)requestImageWithAsset:(NSObject *)asset targetSize:(CGSize)targetSize completion:(void(^)(UIImage * _Nullable image))completion {
    [self requestImageWithAsset:asset targetSize:targetSize type:TPCPhotoTypeDefault completion:completion];
}

- (void)requestImageWithAsset:(NSObject *)asset targetSize:(CGSize)targetSize type:(TPCPhotoType)type completion:(void (^)(UIImage * _Nullable))completion {
    if (_photoKitAvailable) {
        if (type == TPCPhotoTypefullResolution) {
            targetSize = PHImageManagerMaximumSize;
        }
        [_imageManager requestImageForAsset:(PHAsset *)asset targetSize:targetSize contentMode:PHImageContentModeAspectFill  options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            !completion ? : completion(result);
        }];
    } else {
            CGImageRef imageRef;
            switch (type) {
                case TPCPhotoTypeThumbnail:
                    imageRef = [(ALAsset *)asset thumbnail];
                    break;
                case TPCPhotoTypeFullScreen:
                    imageRef = [((ALAsset *)asset).defaultRepresentation fullScreenImage];
                case TPCPhotoTypefullResolution:
                    imageRef = [((ALAsset *)asset).defaultRepresentation fullResolutionImage];
                default:
                    break;
            }
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            !completion ? : completion(image);
    }
}

- (void)initPhotoesForAlbum:(TPCAlbum *)album completion:(void(^)())completion {
    NSMutableArray *photoes;
    if (_photoKitAvailable) {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)album.collection options:nil];
        photoes = [NSMutableArray arrayWithCapacity:fetchResult.count];
        for (NSInteger i = 0; i < fetchResult.count; i++) {
            TPCPhoto *photo = [TPCPhoto photoWithAsset:fetchResult[i] selected:NO index:i];
            [photoes addObject:photo];
        }
    } else {
        photoes = [NSMutableArray arrayWithCapacity:((ALAssetsGroup *)album.collection).numberOfAssets];
        [(ALAssetsGroup *)album.collection enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                TPCPhoto *photo = [TPCPhoto photoWithAsset:result selected:NO index:index];
                [photoes addObject:photo];
            }
        }];
    }
    album.photoes = photoes;
    !completion ? : completion();
}

- (void)addAlbumsWithGroup:(ALAssetsGroup *)group completion:(void(^)(NSInteger index))completion {
    if (group) {
        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        if (group.numberOfAssets > 0 && _filterEmptyAlbum) {
            TPCAlbum *album = [TPCAlbum albumWithTitle:[group valueForProperty:ALAssetsGroupPropertyName] count:group.numberOfAssets collection:group image:[UIImage imageWithCGImage:[group posterImage]]];
            [_albums insertObject:album atIndex:0];
            !completion ? : completion(0);
        }
    } else {
        NSLog(@"completion");
    }
}

- (void)addAlbumsWithFetchResult:(PHFetchResult *)fetchResult thumbnailSize:(CGSize)thumbnailSize completion:(void(^)(NSInteger index))completion{
    for (PHAssetCollection *c in fetchResult) {
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:c options:nil];
        if (!assets.count && _filterEmptyAlbum) { continue; }
        PHAsset *asset = [assets lastObject];
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize targetSize = CGSizeMake(thumbnailSize.width * scale, thumbnailSize.height * scale);
        [_imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            TPCAlbum *album = [TPCAlbum albumWithTitle:c.localizedTitle count:assets.count collection:c image:result];
            [_albums addObject:album];
            !completion ? : completion([_albums indexOfObject:album]);
        }];
    }
}
@end
