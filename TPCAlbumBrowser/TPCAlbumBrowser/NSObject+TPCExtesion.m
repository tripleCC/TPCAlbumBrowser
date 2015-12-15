//
//  NSObject+TPCExtesion.m
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/14.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "NSObject+TPCExtesion.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation NSObject (TPCExtesion)

- (NSString *)tpc_localIdentifer {
    if ([self class] != [ALAsset class]) {
        return ((PHAsset *)self).localIdentifier;
    } else {
        return ((ALAsset *)self).defaultRepresentation.filename;
    }
}

- (CGSize)tpc_pixelSize {
    if ([self class] != [ALAsset class]) {
        PHAsset *asset = (PHAsset *)self;
        return CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    } else {
        ALAsset *asset = (ALAsset *)self;
        return [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage].size;
    }
}
@end
