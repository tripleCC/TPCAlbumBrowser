//
//  TPCAlbum.m
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/10.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCAlbum.h"

@implementation TPCAlbum
+ (instancetype)albumWithTitle:(NSString *)title count:(NSInteger)count collection:(NSObject *)collection image:(UIImage *)image {
    TPCAlbum *album = [[self alloc] init];
    album.title  = title;
    album.count = count;
    album.collection = collection;
    album.image = image;
    return album;
}
@end

@implementation TPCPhoto
+ (instancetype)photoWithAsset:(NSObject *)asset selected:(BOOL)selected index:(NSInteger)index {
    TPCPhoto *photo = [[self alloc] init];
    photo.asset = asset;
    photo.selected = selected;
    photo.index = index;
    return photo;
}

+ (NSArray *)assetsWithPhotoes:(NSArray *)photoes {
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:photoes.count];
    for (TPCPhoto *photo in photoes) {
        [assets addObject:photo.asset];
    }
    return assets;
}

@end
