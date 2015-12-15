//
//  TPCPhotoBrowserViewController.h
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/10.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPCPhotoBrowserViewController : UIViewController
@property (strong, nonatomic) NSArray *photoes;
@property (strong, nonatomic) NSArray *selectedPhotoes;
@property (assign, nonatomic) NSInteger selectedCount;
@property (assign, nonatomic) NSInteger index;
@end
