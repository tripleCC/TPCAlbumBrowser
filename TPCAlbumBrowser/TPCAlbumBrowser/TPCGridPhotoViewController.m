//
//  TPCGridPhotoViewController.m
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/10.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCGridPhotoViewController.h"
#import "TPCPhotoBrowserViewController.h"
#import "TPCAlbum.h"
#import <Photos/Photos.h>
#import "TPCAssetManager.h"
#import "NSObject+TPCExtesion.h"
#import "TPCAlbumViewController.h"

@interface TPCGridPhotoViewController ()
{
    UIView *_toolBarView;
    UIButton *_sendButton;
    UIButton *_previewButton;
    NSInteger _selectedCount;
}
@end
#define themeColor [[UIColor greenColor] colorWithAlphaComponent:0.8]

static CGSize assetGridThumbnailSize;
@implementation TPCGridPhotoViewController

static NSString * const reuseIdentifier = @"TPCGridViewCell";
static const CGFloat tooBarViewH = 40;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    CGFloat margin = 3;
    CGFloat column = 4;
    CGFloat itemSizeHW = ([UIScreen mainScreen].bounds.size.width - margin * (column + 1)) / column;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(itemSizeHW, itemSizeHW);
    flowLayout.minimumLineSpacing = margin;
    flowLayout.minimumInteritemSpacing = margin;
    flowLayout.sectionInset = UIEdgeInsetsMake(margin, margin, margin + tooBarViewH, margin);
    CGFloat scale = [UIScreen mainScreen].scale;
    assetGridThumbnailSize = CGSizeMake(flowLayout.itemSize.width * scale, flowLayout.itemSize.height * scale);
    if (self = [super initWithCollectionViewLayout:flowLayout]) {
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerClass:[TPCGridViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self setupSubviews];
}

- (void)setupSubviews {
    _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - tooBarViewH, [UIScreen mainScreen].bounds.size.width, tooBarViewH)];
    _toolBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolBarView];
    
    CGFloat sendButtonW = 60;
    CGFloat sendButtonH = 30;
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.backgroundColor = [UIColor lightGrayColor];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    _sendButton.layer.cornerRadius = 5;
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    _sendButton.frame = CGRectMake(_toolBarView.bounds.size.width - sendButtonW - (_toolBarView.bounds.size.height - sendButtonH) * 0.5, (_toolBarView.bounds.size.height - sendButtonH) * 0.5, sendButtonW, sendButtonH);
    [_sendButton addTarget:self action:@selector(sendButtonOnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_toolBarView addSubview:_sendButton];
    _sendButton.enabled = NO;
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previewButton.backgroundColor = [UIColor clearColor];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [_previewButton setTitleColor:themeColor forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_previewButton addTarget:self action:@selector(previewButtonOnClicked) forControlEvents:UIControlEventTouchUpInside];
    _previewButton.bounds = CGRectMake(0, 0, 60, _toolBarView.bounds.size.height);
    _previewButton.center = CGPointMake(_toolBarView.bounds.size.height - sendButtonH + _previewButton.bounds.size.width * 0.5, _toolBarView.bounds.size.height * 0.5);
    [_toolBarView addSubview:_previewButton];
    _previewButton.enabled = NO;
    
    CALayer *seperatorLine = [CALayer layer];
    seperatorLine.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    seperatorLine.frame = CGRectMake(0, 0, _toolBarView.bounds.size.width, 0.5);
    [_toolBarView.layer addSublayer:seperatorLine];
}

- (void)setupNav {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    _selectedCount = self.selectedPhotoes.count;
    [self configToolBar];
}

- (void)sendButtonOnClicked {
    NSArray *selectedPhotoes = [self selectedPhotoes];
    NSMutableArray *images = [NSMutableArray array];
    NSInteger maxCount = selectedPhotoes.count > 5 ? 5 : selectedPhotoes.count;
    for (NSInteger i = 0; i < maxCount; i++) {
        [[TPCAssetManager sharedManager] requestImageWithAsset:[selectedPhotoes[i] asset] targetSize:CGSizeZero type:TPCPhotoTypefullResolution completion:^(UIImage * _Nullable image) {
            [images addObject:image];
            if (i == maxCount - 1) {
                !albumNavVc.selectedCompletion ? : albumNavVc.selectedCompletion(images);
            }
        }];
    }
}

- (NSArray *)selectedPhotoes {
    NSMutableArray *selectedPhotoes = [NSMutableArray arrayWithCapacity:_selectedCount];
    for (TPCPhoto *photo in _result.photoes) {
        if (photo.selected) {
            [selectedPhotoes addObject:photo];
        }
    }
    return selectedPhotoes;
}

- (void)previewButtonOnClicked {
    TPCPhotoBrowserViewController *vc = [[TPCPhotoBrowserViewController alloc] init];
    vc.selectedPhotoes = self.selectedPhotoes;
    vc.selectedCount = _selectedCount;
    vc.index = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setResult:(TPCAlbum *)result {
    if (result == nil) {
        [[TPCAssetManager sharedManager] fetchCameraRollAlbumsWithThumbnailSize:assetGridThumbnailSize completion:^(TPCAlbum * _Nullable album) {
            [self reloadCollectionViewWithAlbum:album];
        }];
    } else {
        [self reloadCollectionViewWithAlbum:result];
    }
}

- (void)reloadCollectionViewWithAlbum: (TPCAlbum *)album {
    _result = album;
    self.navigationItem.title = album.title;
    [[TPCAssetManager sharedManager] initPhotoesForAlbum:album completion:^{
        [self.collectionView reloadData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _result.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TPCGridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    TPCPhoto *photo = _result.photoes[indexPath.item];
    if (indexPath.item < _result.photoes.count) {
        cell.representedAssetIdentifier = photo.asset.tpc_localIdentifer;
        __weak typeof(self) weakSelf = self;
        [cell setCallBack:^BOOL (BOOL selected){
            return [weakSelf setContentBySelectedFlag:selected photo:photo];
        }];
        cell.imageSelected = photo.selected;
        [[TPCAssetManager sharedManager] requestImageWithAsset:photo.asset targetSize:assetGridThumbnailSize completion:^(UIImage * _Nullable image) {
            if ([cell.representedAssetIdentifier isEqualToString:photo.asset.tpc_localIdentifer]) {
                cell.thumbnailImage = image;
            }
        }];
    }
    
    return cell;
}

- (BOOL)setContentBySelectedFlag:(BOOL)selectedFlag photo:(TPCPhoto *)photo{
    if (photo.selected != selectedFlag) {
        photo.selected = selectedFlag;
        _selectedCount = selectedFlag ? _selectedCount + 1 : _selectedCount - 1;
        if (_selectedCount > albumNavVc.maxSelectedCount) {
            photo.selected = NO;
            _selectedCount = albumNavVc.maxSelectedCount;
            !albumNavVc.maxSelectedAction ? : albumNavVc.maxSelectedAction(_selectedCount);
            return NO;
        } else {
            [self configToolBar];
            return selectedFlag;
        }
    }
    return NO;
}

- (void)configToolBar {
    if (_selectedCount) {
        NSString *title = [NSString stringWithFormat:@"发送(%ld)", _selectedCount];
        [_sendButton setTitle:title forState:UIControlStateNormal];
        _sendButton.backgroundColor = themeColor;
    } else {
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.backgroundColor = [UIColor lightGrayColor];
    }
    _previewButton.enabled = _selectedCount;
    _sendButton.enabled = _selectedCount;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TPCPhotoBrowserViewController *vc = [[TPCPhotoBrowserViewController alloc] init];
    vc.photoes = (NSArray *)_result.photoes;
    vc.selectedCount = _selectedCount;
    vc.index = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
    
@implementation TPCGridViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        CGSize selectedButtonSize = CGSizeMake(20, 20);
        CGFloat margin = 2;
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.frame = CGRectMake(self.bounds.size.width - selectedButtonSize.width - margin, margin, selectedButtonSize.width, selectedButtonSize.height);
        _selectedButton.layer.cornerRadius = selectedButtonSize.width * 0.5;
        _selectedButton.layer.borderWidth = 1.0;
        _selectedButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _selectedButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectedButton setTitle:@"✓" forState:UIControlStateNormal];
        [_selectedButton addTarget:self action:@selector(selectedButtonOnClicked:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:_selectedButton];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(CGRectMake(self.contentView.bounds.size.width * 0.5, 0, self.contentView.bounds.size.width * 0.5, self.contentView.bounds.size.height * 0.5), point)) {
        return _selectedButton;
    }
    return [super hitTest:point withEvent:event];
}

- (void)selectedButtonOnClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self adjustSelectedButtonBySelectedFlag:!_callBack ? : _callBack(sender.selected)];
}

- (void)adjustSelectedButtonBySelectedFlag:(BOOL)selectedFlag {
    if (selectedFlag == YES) {
        _selectedButton.layer.borderWidth = 0;
        _selectedButton.backgroundColor = themeColor;
        _selectedButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _selectedButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
        }];
    } else {
        [_selectedButton.layer removeAllAnimations];
        _selectedButton.layer.borderWidth = 1.0;
        _selectedButton.backgroundColor = [UIColor clearColor];
    }
}

- (void)setImageSelected:(BOOL)imageSelected {
    _imageSelected = imageSelected;
    _selectedButton.selected = imageSelected;
    [self adjustSelectedButtonBySelectedFlag:imageSelected];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    _imageView.image = thumbnailImage;
}

@end