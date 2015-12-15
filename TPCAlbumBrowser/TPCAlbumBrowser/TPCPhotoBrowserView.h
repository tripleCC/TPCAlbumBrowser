//
//  TPCPhotoBrowserView.h
//  TPCPhotoBrowserView
//
//  Created by tripleCC on 15/12/9.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class TPCPhotoBrowserView;
@protocol TPCPhotoBrowserViewDelegate <NSObject>
@optional
- (void)photoBrowserViewDidSingalTap:(TPCPhotoBrowserView *)photoBrowserView;
- (void)photoBrowserViewDidDoubleTap:(TPCPhotoBrowserView *)photoBrowserView;
@end
@interface TPCPhotoBrowserView : UIView
@property (strong, nonatomic) NSArray *assets;
@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) id<TPCPhotoBrowserViewDelegate> delegate;
@property (copy, nonatomic) void (^pageCallBack)(NSInteger index);
@end

@protocol TPCImageViewDelegate <NSObject>
@optional
- (void)imageViewDidSingalTap:(UIImageView *)imageView;
- (void)imageViewDidDoubleTap:(UIImageView *)imageView;
@end
@interface TPCImageView : UIView
@property (strong, nonatomic) NSObject *asset;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) id<TPCImageViewDelegate> delegate;
+ (void)fetchFullScreenImageWithAsset:(NSObject *)asset completion:(void(^_Nullable)(UIImage * _Nullable image))completion;
@end
