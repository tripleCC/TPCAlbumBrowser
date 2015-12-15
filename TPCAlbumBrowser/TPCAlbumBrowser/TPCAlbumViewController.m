//
//  TPCAlbumViewController.m
//  PhotoLibTest
//
//  Created by tripleCC on 15/12/10.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCAlbumViewController.h"
#import "TPCGridPhotoViewController.h"
#import <Photos/Photos.h>
#import "TPCAlbum.h"
#import "TPCAssetManager.h"

@implementation TPCAlbumController
+ (instancetype)albumController {
    TPCAlbumController *naVc = [[self alloc] initWithRootViewController: [[TPCAlbumViewController alloc] initWithStyle:UITableViewStylePlain]];
    naVc.maxSelectedCount = 5;
    return naVc;
}
@end


@interface TPCAlbumViewController ()
{
    NSMutableArray *_fetchResults;
    PHImageManager *_imageManager;
}
@end

static const CGFloat cellHeight = 60;

@implementation TPCAlbumViewController
static NSString *const reuseIdentifier = @"TPCAlbumViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self pushToGridPhotoAtFirstTime];
    [self setupNav];
    [self setupSubviews];
    [[TPCAssetManager sharedManager] fetchAlbumsWithThumbnailSize:CGSizeMake(cellHeight, cellHeight) completion:^(NSInteger index) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)pushToGridPhotoAtFirstTime {
    TPCGridPhotoViewController *vc = [[TPCGridPhotoViewController alloc] initWithCollectionViewLayout:[[UICollectionViewLayout alloc] init]];
    vc.result = nil;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)setupSubviews {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TPCAlbumViewCell class] forCellReuseIdentifier:reuseIdentifier];
}

- (void)setupNav {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
}

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [TPCAssetManager sharedManager].albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPCAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.album = [TPCAssetManager sharedManager].albums[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TPCGridPhotoViewController *vc = [[TPCGridPhotoViewController alloc] initWithCollectionViewLayout:[[UICollectionViewLayout alloc] init]];
    vc.result = [TPCAssetManager sharedManager].albums[indexPath.row];
    vc.navigationItem.title = vc.result.title;
    [self.navigationController pushViewController:vc animated:YES];
}
@end

@implementation TPCAlbumViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _assetImageView = [[UIImageView alloc] init];
        _assetImageView.contentMode = UIViewContentModeScaleAspectFill;
        _assetImageView.clipsToBounds = YES;
        [self.contentView addSubview:_assetImageView];
        
        _assetTextLabel = [[UILabel alloc] init];
        _assetTextLabel.textAlignment = NSTextAlignmentLeft;
        _assetTextLabel.font = [UIFont systemFontOfSize:18.0];
        _assetTextLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_assetTextLabel];
        
        _seperatorLine = [CALayer layer];
        _seperatorLine.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
        [self.contentView.layer addSublayer:_seperatorLine];
    }
    return self;
}
- (void)setAlbum:(TPCAlbum *)album {
    _album = album;
    _assetImageView.image = album.image;
    _assetTextLabel.text = [NSString stringWithFormat:@"%@ (%ld)", album.title, album.count];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    _assetImageView.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    _assetTextLabel.frame = CGRectMake(CGRectGetMaxX(_assetImageView.frame) + 10, 0, 150, _assetImageView.bounds.size.height);
    _seperatorLine.frame = CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5);
}
@end