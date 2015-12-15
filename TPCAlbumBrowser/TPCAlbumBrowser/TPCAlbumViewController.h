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
@property (assign, nonatomic) NSInteger maxSelectedCount;
@property (copy, nonatomic) void (^maxSelectedAction)(NSInteger count);
@property (copy, nonatomic) void (^selectedCompletion)(NSArray *images);
@end

#define albumNavVc ((TPCAlbumController *)(self.navigationController))

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