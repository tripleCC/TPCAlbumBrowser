//
//  TPCGridPhotoViewController.h
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/10.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPCAlbum;
@interface TPCGridPhotoViewController : UICollectionViewController
@property (strong, nonatomic) TPCAlbum *result;
@end

@interface TPCGridViewCell : UICollectionViewCell
{
    UIImageView *_imageView;
    UIButton *_selectedButton;
}
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (copy, nonatomic) NSString *representedAssetIdentifier;
@property (assign, nonatomic) BOOL imageSelected;
@property (copy, nonatomic) BOOL (^callBack)(BOOL selected);
@end