//
//  TPCPhotoBrowserViewController.m
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/10.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCPhotoBrowserViewController.h"
#import "TPCAlbumViewController.h"
#import "TPCPhotoBrowserView.h"
#import "TPCAlbum.h"

@interface TPCPhotoBrowserViewController () <TPCPhotoBrowserViewDelegate>
{
    TPCPhotoBrowserView *_browserView;
    NSInteger _currentIndex;
    NSArray *_validPhotoes;
}
@end
#define themeColor [[UIColor greenColor] colorWithAlphaComponent:0.8]
@implementation TPCPhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNav];
    [self setupSubviews];
}

- (void)setupSubviews {
    _browserView = [[TPCPhotoBrowserView alloc] initWithFrame:self.view.bounds];
    _browserView.delegate = self;
    _browserView.index = _index;
    _currentIndex = _index;
    if (_selectedPhotoes) {
        _browserView.assets = [TPCPhoto assetsWithPhotoes:_selectedPhotoes];
        _validPhotoes = _selectedPhotoes;
    } else {
        _browserView.assets = [TPCPhoto assetsWithPhotoes:_photoes];
        _validPhotoes = _photoes;
    }
    [self adjustSelectedButtonBySelectedFlag:[_validPhotoes[_currentIndex] selected] animate:NO];
    __weak typeof(self) weakSelf = self;
    [_browserView setPageCallBack:^(NSInteger index) {
        [weakSelf pageCallBackWithIndex:index];
    }];
    [self.view addSubview:_browserView];
}
- (void)setupNav {
    CGSize selectedButtonSize = CGSizeMake(20, 20);
    UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectedButton.bounds = CGRectMake(0, 0, selectedButtonSize.width, selectedButtonSize.height);
    selectedButton.layer.cornerRadius = selectedButtonSize.width * 0.5;
    selectedButton.layer.borderWidth = 1.0;
    selectedButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    selectedButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectedButton setTitle:@"✓" forState:UIControlStateNormal];
    [selectedButton addTarget:self action:@selector(selectedButtonOnClicked:) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:selectedButton];
}

- (void)selectedButtonOnClicked:(UIButton *)sender {
    TPCPhoto *photo = _validPhotoes[_currentIndex];
    photo.selected = !photo.selected;
    _selectedCount = photo.selected && _selectedCount <= TPCAlbumNavVc.maxSelectedCount ? _selectedCount + 1 : _selectedCount - 1;
    if (_selectedCount > TPCAlbumNavVc.maxSelectedCount) {
        photo.selected = NO;
        _selectedCount = TPCAlbumNavVc.maxSelectedCount;
        !TPCAlbumNavVc.maxSelectedAction ? : TPCAlbumNavVc.maxSelectedAction(_selectedCount);
    } else {
        [self adjustSelectedButtonBySelectedFlag:photo.selected animate:YES];
    }
}

- (void)adjustSelectedButtonBySelectedFlag:(BOOL)selectedFlag animate:(BOOL)animate{
    UIView *customView = self.navigationItem.rightBarButtonItem.customView;
    if (selectedFlag == YES) {
        customView.layer.borderWidth = 0;
        customView.backgroundColor = themeColor;
        customView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [UIView animateWithDuration:animate ? 0.5 : 0 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        customView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
        }];
    } else {
        [customView.layer removeAllAnimations];
        customView.layer.borderWidth = 1.0;
        customView.backgroundColor = [UIColor clearColor];
    }
}

- (void)pageCallBackWithIndex:(NSInteger)index {
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld", index + 1, _validPhotoes.count];
    _currentIndex = index;
    [self adjustSelectedButtonBySelectedFlag:[_validPhotoes[_currentIndex] selected] animate:NO];
}

- (void)photoBrowserViewDidSingalTap:(TPCPhotoBrowserView *)photoBrowserView {
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (self.navigationController.navigationBar.frame.origin.y < 0) {
        transform = CGAffineTransformIdentity;
    } else {
        transform = CGAffineTransformMakeTranslation(0, -self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height);
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.navigationBar.transform = transform;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

@end
