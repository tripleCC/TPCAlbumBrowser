//
//  TPCAlbumViewController.h
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/10.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPCAlbumController : UINavigationController
+ (instancetype)albumController;
/**
 *  照片选择最大张数
 */
@property (assign, nonatomic) NSInteger maxSelectedCount;
/**
 *  选择最大张数后回调
 */
@property (copy, nonatomic) void (^maxSelectedAction)(NSInteger count);
/**
 *  授权结果回调
 */
@property (copy, nonatomic) void (^authorizeCompletion)(BOOL authorized);
/**
 *  选择完成回调
 */
@property (copy, nonatomic) void (^selectedCompletion)(NSArray *images);
@end

#define TPCAlbumNavVc ((TPCAlbumController *)(self.navigationController))

@interface TPCAlbumViewController : UITableViewController
@end

@class TPCAlbum;
@interface TPCAlbumViewCell: UITableViewCell
{
    UIImageView *_assetImageView;
    UILabel *_assetTextLabel;
    CALayer *_seperatorLine;
}
@property (strong, nonatomic) TPCAlbum *album;
@end