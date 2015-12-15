//
//  TPCPhotoBrowserView.m
//  TPCPhotoBrowserView
//
//  Created by tripleCC on 15/12/9.
//  Copyright © 2015年 tripleCC. All rights reserved.
//

#import "TPCPhotoBrowserView.h"
#import "NSObject+TPCExtesion.h"
#import "TPCAssetManager.h"

@interface TPCPhotoBrowserView() <UIScrollViewDelegate, TPCImageViewDelegate>
{
    TPCImageView *_currentImageView;
    TPCImageView *_backupImageView;
    UIImage *_leftImageCache;
    UIImage *_rightImageCache;
    UIScrollView *_scrollView;
    UIView *_edgeMaskView;
    UILabel *_pageLabel;
}
@end

#define ViewWidth [UIScreen mainScreen].bounds.size.width
#define ViewHeight [UIScreen mainScreen].bounds.size.height
#define LeftIndex(currentIndex, TotalCount) (_currentImageView.tag - 1 + TotalCount) % TotalCount
#define RightIndex(currentIndex, TotalCount) (_currentImageView.tag + 1) % TotalCount
static const CGFloat padding = 40;
@implementation TPCPhotoBrowserView

- (void)setAssets:(NSArray *)assets {
    
    _assets = assets;
    if (_assets.count == 0) { return; }
    if (_assets.count > _index && !_currentImageView.asset) {
        _currentImageView.tag = _index;
        _scrollView.scrollEnabled = _assets.count != 1;
    }
    [self setImageCachesWithIndex:_index];
    !_pageCallBack ? : _pageCallBack(_index);
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    if (_assets.count > index) {
        _currentImageView.tag = index;
        _scrollView.scrollEnabled = _assets.count != 1;
    }
    [self setImageCachesWithIndex:_index];
    !_pageCallBack ? : _pageCallBack(_index);
}

- (void)setPageCallBack:(void (^)(NSInteger))pageCallBack {
    _pageCallBack = pageCallBack;
    !_pageCallBack ? : _pageCallBack(_index);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSubviews];
    }
    
    return self;
}

- (void)setImageCachesWithIndex:(NSInteger)index {
    if (_assets.count > index) {
        [TPCImageView fetchFullScreenImageWithAsset:_assets[index] completion:^(UIImage * _Nullable image) {
            _currentImageView.image = image;
        }];
        if (_assets.count > 1) {
            [TPCImageView fetchFullScreenImageWithAsset:_assets[RightIndex(index, _assets.count)] completion:^(UIImage * _Nullable image) {
                _rightImageCache = image;
            }];
            [TPCImageView fetchFullScreenImageWithAsset:_assets[LeftIndex(index, _assets.count)] completion:^(UIImage * _Nullable image) {
                _leftImageCache = image;
            }];
        }
    }
}

- (void)setupSubviews {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(ViewWidth * 3, 0);
    _scrollView.contentOffset = CGPointMake(ViewWidth, 0);
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    _currentImageView = [[TPCImageView alloc] initWithFrame:CGRectMake(ViewWidth, 0, ViewWidth, ViewHeight)];
    _currentImageView.delegate = self;
    [_scrollView addSubview:_currentImageView];
    
    _backupImageView = [[TPCImageView alloc] initWithFrame:CGRectMake(ViewWidth * 2, 0, ViewWidth, self.bounds.size.height)];
    _backupImageView.delegate = self;
    [_scrollView addSubview:_backupImageView];
    
    _edgeMaskView = [[UIView alloc] initWithFrame:CGRectMake(-padding, 0, padding, ViewHeight)];
    _edgeMaskView.backgroundColor = [UIColor blackColor];
    [self addSubview:_edgeMaskView];
    
    self.clipsToBounds = YES;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGRect frame = _edgeMaskView.frame;
    if (offsetX < ViewWidth) {
        frame.origin.x = padding / ViewWidth * (ViewWidth - offsetX) + ViewWidth - offsetX - padding;
        _backupImageView.frame = CGRectMake(0, 0, ViewWidth, ViewHeight);
        _backupImageView.tag = (_currentImageView.tag - 1 + _assets.count) % _assets.count;
        _backupImageView.image = _leftImageCache;
    } else if (offsetX > ViewWidth) {
        frame.origin.x = padding / ViewWidth * (ViewWidth - offsetX) + 2 * ViewWidth - offsetX;
        _backupImageView.frame = CGRectMake(ViewWidth * 2, 0, ViewWidth, ViewHeight);
        _backupImageView.tag = (_currentImageView.tag + 1) % _assets.count;
        _backupImageView.image = _rightImageCache;
    }
    _edgeMaskView.frame = frame;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    scrollView.contentOffset = CGPointMake(ViewWidth, scrollView.contentOffset.y);
    if (offsetX < ViewWidth * 1.5 && offsetX > ViewWidth * 0.5) { return; }
    
    UIImage *centerImageCache = _currentImageView.image;
    _currentImageView.image = _backupImageView.image;
    _currentImageView.tag = _backupImageView.tag;
    !_pageCallBack ? : _pageCallBack(_currentImageView.tag);
    if (_backupImageView.image == _leftImageCache) {
        [TPCImageView fetchFullScreenImageWithAsset:_assets[LeftIndex(_currentImageView.tag, _assets.count)] completion:^(UIImage * _Nullable image) {
            _leftImageCache = image;
        }];
        _rightImageCache = centerImageCache;
    } else {
        [TPCImageView fetchFullScreenImageWithAsset:_assets[RightIndex(_currentImageView.tag, _assets.count)] completion:^(UIImage * _Nullable image) {
            _rightImageCache = image;
        }];
        _leftImageCache = centerImageCache;
    }
}

#pragma mark TPCImageViewDelegate 
- (void)imageViewDidSingalTap:(UIImageView *)imageView {
    if ([_delegate respondsToSelector:@selector(photoBrowserViewDidSingalTap:)]) {
        [_delegate photoBrowserViewDidSingalTap:self];
    }
}

- (void)imageViewDidDoubleTap:(UIImageView *)imageView {
    if ([_delegate respondsToSelector:@selector(photoBrowserViewDidDoubleTap:)]) {
        [_delegate photoBrowserViewDidDoubleTap:self];
    }
}
@end

@interface TPCImageView() <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    PHImageManager *_imageManager;
}
@end

@implementation TPCImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageManager = [PHImageManager defaultManager];
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _imageManager = [PHImageManager defaultManager];
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self adjustImageFrame];
}

- (void)adjustImageFrame {
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) * 0.5;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) * 0.5;
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(_imageView.frame, frameToCenter)) {
        _imageView.frame = frameToCenter;
    }
}

- (void)setImage:(UIImage *)image {
    if (_image == image) { return; }
    _image = image;
    [self resetSubviews];
    [self adjustImageViewFrameByImage:image];
    _imageView.image = image;
}

- (void)setAsset:(NSObject *)asset {
    if ([_asset.tpc_localIdentifer isEqualToString:asset.tpc_localIdentifer]) { return; }
    _asset = asset;
    [self resetSubviews];
    [TPCImageView fetchFullScreenImageWithAsset:asset completion:^(UIImage * _Nullable image) {
        [self adjustImageViewFrameByImage:image];
        _imageView.image = image;
        _image = image;
    }];
}

+ (void)fetchFullScreenImageWithAsset:(NSObject *)asset completion:(void(^)(UIImage * _Nullable image))completion {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeZero;
    CGFloat xScale = ViewWidth / asset.tpc_pixelSize.width;
    CGFloat yScale = ViewHeight / asset.tpc_pixelSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    targetSize = CGSizeMake(ViewWidth * minScale * scale, ViewHeight * minScale * scale);
    [[TPCAssetManager sharedManager] requestImageWithAsset:asset targetSize:targetSize type:TPCPhotoTypeFullScreen completion:^(UIImage * _Nullable image) {
        !completion ? : completion(image);
    }];
}

- (void)setupSubviews {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 4.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor blackColor];
    [self addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    
    UITapGestureRecognizer *singalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singalTap:)];
    singalTap.numberOfTapsRequired = 1;
    [_imageView addGestureRecognizer:singalTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_imageView addGestureRecognizer:doubleTap];
    [singalTap requireGestureRecognizerToFail:doubleTap];
}

- (void)singalTap: (UIGestureRecognizer *)gesture {
    if ([_delegate respondsToSelector:@selector(imageViewDidSingalTap:)]) {
        [_delegate imageViewDidSingalTap:_imageView];
    }
}

- (void)doubleTap: (UIGestureRecognizer *)gesture {
    if (_scrollView.zoomScale == 1) {
        CGPoint point = [gesture locationInView:gesture.view];
        CGFloat width = ViewWidth / _scrollView.maximumZoomScale;
        CGFloat height = ViewHeight / _scrollView.maximumZoomScale;
        [_scrollView zoomToRect:CGRectMake(point.x - width * 0.5, point.y - height * 0.5, width, height) animated:YES];
    } else {
        [_scrollView setZoomScale:1 animated:YES];
    }
    if ([_delegate respondsToSelector:@selector(imageViewDidDoubleTap:)]) {
        [_delegate imageViewDidDoubleTap:_imageView];
    }
}

- (void)adjustImageViewFrameByImage:(UIImage *)image {
    _imageView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    CGFloat xScale = ViewWidth / image.size.width;
    CGFloat yScale = ViewHeight / image.size.height;
    CGFloat minScale = MIN(xScale, yScale);
    _imageView.bounds = CGRectMake(0, 0, _imageView.bounds.size.width * minScale, _imageView.bounds.size.height * minScale);
    [self adjustImageFrame];
}

- (void)resetSubviews {
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.contentOffset = CGPointZero;
    _scrollView.contentSize = CGSizeZero;
    _imageView.transform = CGAffineTransformIdentity;
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self adjustImageFrame];
}
@end
