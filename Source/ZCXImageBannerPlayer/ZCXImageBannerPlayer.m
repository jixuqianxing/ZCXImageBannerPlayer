//
//  ZCXImageBannerPlayer.m
//  ZCXImageBannerPlayer
//
//  Created by zcx on 16/4/19.
//  Copyright © 2016年 继续前行. All rights reserved.
//


#import "ZCXImageBannerPlayer.h"

#define kPageControlHeight 10
#define kMargin 10

typedef NS_ENUM(NSInteger, ZCXImageBannerPlayerScrollDirectionType) {
    ZCXImageBannerPlayerScrollDirectionTypeNone,
    ZCXImageBannerPlayerScrollDirectionTypeLeft,     // 往左滚动
    ZCXImageBannerPlayerScrollDirectionTypeRight     // 往右滚动
};

@interface ZCXImageBannerPlayer ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *imageScrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) UIImageView *currentImageView;
@property (strong, nonatomic) UIImageView *nextImageView;

@property (strong, nonatomic) NSMutableArray *imageArray;

@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) NSInteger nextIndex;

@property (assign, nonatomic) NSInteger imageCount;

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) ZCXImageBannerPlayerScrollDirectionType scrollDirectionType;

@end

@implementation ZCXImageBannerPlayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    [self addSubview:self.imageScrollView];
    [self addSubview:self.pageControl];
    
    _autoScroll = YES;
    _remainTime = 5;
    _pageControlLayout = ZCXImageBannerPageControlLayoutBottmCenter;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageScrollView.frame = self.bounds;
    [self configScrollViewContentSize];
    [self layoutpPageControl];
}

#pragma mark getter

- (UIScrollView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [[UIScrollView alloc] init];
        _imageScrollView.contentInset  = UIEdgeInsetsZero;
        _imageScrollView.pagingEnabled = YES;
        _imageScrollView.bounces = NO;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator   = NO;
        _imageScrollView.delegate = self;
        _currentImageView = [[UIImageView alloc] init];
        _currentImageView.userInteractionEnabled = YES;
        [_currentImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)]];
        [_imageScrollView addSubview:_currentImageView];
        _nextImageView = [[UIImageView alloc] init];
        [_imageScrollView addSubview:_nextImageView];
    }
    return _imageScrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidden = YES;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (CGFloat)width {
    return CGRectGetWidth(self.imageScrollView.bounds);
}

- (CGFloat)height {
    return CGRectGetHeight(self.imageScrollView.bounds);
}

#pragma mark setter

- (void)setScrollDirectionType:(ZCXImageBannerPlayerScrollDirectionType)scrollDirectionType {
    if (_scrollDirectionType == scrollDirectionType) return;
    
    _scrollDirectionType = scrollDirectionType;
    
    if (scrollDirectionType == ZCXImageBannerPlayerScrollDirectionTypeNone) return;
    
    if (scrollDirectionType == ZCXImageBannerPlayerScrollDirectionTypeRight) {
        _nextImageView.frame = CGRectMake(0, 0, self.width, self.height);
        _nextIndex = _currentIndex - 1;
        if (_nextIndex < 0) _nextIndex = _imageCount - 1;
    }
    else if (scrollDirectionType == ZCXImageBannerPlayerScrollDirectionTypeLeft){
        _nextImageView.frame = CGRectMake(CGRectGetMaxX(_currentImageView.frame), 0, self.width, self.height);
        _nextIndex = (_currentIndex + 1) % _imageCount;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageBannerPlayer:loadImageForImageView:atIndex:)]) {
        [_delegate imageBannerPlayer:self loadImageForImageView:_nextImageView atIndex:@(_nextIndex)];
    }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

#pragma mark - Public
#pragma mark 刷新数据
- (void)reloadImageData {
    
    [self stopTimer];
    
    [self configScrollViewContentSize];
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfImages)]) {
        _imageCount = [[_dataSource numberOfImages] integerValue];
        self.pageControl.numberOfPages = _imageCount;
        [self layoutpPageControl];
    }
    
    if (_imageCount == 0) {
        _currentImageView.image = nil;
        _nextImageView.image = nil;
    }
    
    _currentIndex = 0;
    _nextIndex = _currentIndex + 1;
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageBannerPlayer:loadImageForImageView:atIndex:)]) {
        [_delegate imageBannerPlayer:self loadImageForImageView:_currentImageView atIndex:@(0)];
    }
    
    self.scrollDirectionType = ZCXImageBannerPlayerScrollDirectionTypeLeft;
    
    if (_autoScroll && _imageCount > 1) {
        [self startTimer];
    }
}


#pragma mark - Private 
#pragma mark 点击图片事件
- (void)imageClick:(UITapGestureRecognizer *)gesture {
    if (_delegate && [_delegate respondsToSelector:@selector(imageBannerPlayer:clickedAtIndex:)]) {
        [_delegate imageBannerPlayer:self clickedAtIndex:@(_currentIndex)];
    }
}

- (void)startTimer {
    if (!_autoScroll) return;
    [self stopTimer];
    _timer = [NSTimer timerWithTimeInterval:_remainTime
                                     target:self
                                   selector:@selector(nextPage:)
                                   userInfo:nil
                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer
                                 forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (!_autoScroll) return;
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)reloadCurrentImage {
    if (_imageScrollView.contentOffset.x / self.width == 1) return;
    
    _currentIndex = _nextIndex;
    _pageControl.currentPage = _currentIndex;
    
    _currentImageView.image = _nextImageView.image;
    _currentImageView.frame = CGRectMake(self.width, 0, self.width, self.height);
    
    _imageScrollView.contentOffset = CGPointMake(self.width, 0);
}

- (void)configScrollViewContentSize {
    CGFloat width  = CGRectGetWidth(self.imageScrollView.bounds);
    CGFloat height = CGRectGetHeight(self.imageScrollView.bounds);
    if (_imageCount > 1) {
        self.imageScrollView.contentSize   = CGSizeMake(width * 3, 0);
        self.imageScrollView.contentOffset = CGPointMake(width, 0);
        _currentImageView.frame = CGRectMake(width, 0, width, height);
    } else {
        self.imageScrollView.contentSize   = CGSizeZero;
        self.imageScrollView.contentOffset = CGPointZero;
        _currentImageView.frame = CGRectMake(0, 0, width, height);
        _nextImageView.frame = CGRectMake(0, 0, width, height);
    }
    CGRect f = _nextImageView.frame;
    f.size.width  = width;
    f.size.height = height;
    _nextImageView.frame = f;
}

- (void)layoutpPageControl {
    if (_imageCount <= 1) return;
    
    self.pageControl.hidden = NO;
    
    CGSize size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
    size.height = kPageControlHeight;
    
    switch (_pageControlLayout) {
        case ZCXImageBannerPageControlLayoutNone:
            self.pageControl.hidden = YES;
            break;
        case ZCXImageBannerPageControlLayoutBottmCenter:
            _pageControl.center = CGPointMake(self.width * 0.5, self.height - kPageControlHeight);
            break;
        case ZCXImageBannerPageControlLayoutBottmLeft:
            _pageControl.center = CGPointMake(self.width - size.width - kMargin, self.height - kPageControlHeight);
            break;
        case ZCXImageBannerPageControlLayoutBottmRight:
            _pageControl.center = CGPointMake(kMargin, self.height - kPageControlHeight);
            break;
        default:
            break;
    }
}

#pragma mark nextPage
- (void)nextPage:(id)sender {
    if (_imageCount <= 1) {
        [self stopTimer];
        return;
    }
    [_imageScrollView setContentOffset:CGPointMake(self.width * 2, 0) animated:YES];
}

- (void)changeCurrentPageWithOffset:(CGFloat)offsetX {
    if (offsetX < self.width * 0.5) {
        NSInteger index = _currentIndex - 1;
        if (index < 0)
            index = _imageCount - 1;
        _pageControl.currentPage = index;
    } else if (offsetX > self.width * 1.5) {
        _pageControl.currentPage = (_currentIndex + 1) % _imageCount;
    } else {
        _pageControl.currentPage = _currentIndex;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    self.scrollDirectionType = offsetX > self.width? ZCXImageBannerPlayerScrollDirectionTypeLeft : offsetX < self.width? ZCXImageBannerPlayerScrollDirectionTypeRight : ZCXImageBannerPlayerScrollDirectionTypeNone;
    [self changeCurrentPageWithOffset:offsetX];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reloadCurrentImage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self reloadCurrentImage];
}

@end
