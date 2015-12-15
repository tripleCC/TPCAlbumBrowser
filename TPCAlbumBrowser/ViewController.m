//
//  ViewController.m
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/15.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "ViewController.h"
#import "TPCAlbumViewController.h"

@implementation ViewController
- (IBAction)present:(id)sender {
    TPCAlbumController *vc = [TPCAlbumController albumController];
    vc.maxSelectedCount = 4;
    [vc setMaxSelectedAction:^(NSInteger c) {
        NSLog(@"%ld", c);
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
