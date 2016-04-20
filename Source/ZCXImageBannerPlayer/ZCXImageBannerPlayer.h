//
//  ZCXImageBannerPlayer.h
//  ZCXImageBannerPlayer
//
//  Created by zcx on 16/4/19.
//  Copyright © 2016年 继续前行. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZCXImageBannerPlayer;


typedef NS_ENUM(NSUInteger, ZCXImageBannerPageControlLayout) {
    ZCXImageBannerPageControlLayoutNone,
    ZCXImageBannerPageControlLayoutBottmCenter,
    ZCXImageBannerPageControlLayoutBottmLeft,
    ZCXImageBannerPageControlLayoutBottmRight
};

@protocol ZCXImageBannerPlayerDataSource <NSObject>

@required
/**
 *  获取图片总数
 *
 *  @return 图片总张数
 */
- (NSNumber *)numberOfImages;

@end

@protocol ZCXImageBannerPlayerDelegate <NSObject>

@required
/**
 *  设置每个界面的图片
 *
 *  @param imageBannerPlayer ZCXImageBannerPlayer
 *  @param imageView       需要设置图片的imageView
 *  @param index           设置图片的位置
 */
- (void)imageBannerPlayer:(ZCXImageBannerPlayer *)imageBannerPlayer
    loadImageForImageView:(UIImageView *)imageView
                  atIndex:(NSNumber *)index;
@optional
/**
 *  点击的为界面位置
 *
 *  @param imageBannerPlayer ZCXImageBannerPlayer
 *  @param index           位置
 */
- (void)imageBannerPlayer:(ZCXImageBannerPlayer *)imageBannerPlayer
           clickedAtIndex:(NSNumber *)index;

@end

@interface ZCXImageBannerPlayer : UIView

@property (weak, nonatomic) id<ZCXImageBannerPlayerDataSource>dataSource;
@property (weak, nonatomic) id<ZCXImageBannerPlayerDelegate>delegate;

@property (assign, nonatomic) NSTimeInterval remainTime;/**< 每一页停留时间，默认值5s*/

@property (assign, nonatomic) BOOL autoScroll;/**< 是否需要自动滚动播放,默认值为 YES*/

@property (assign, nonatomic) ZCXImageBannerPageControlLayout pageControlLayout;/**< UIPageControl位置，默认ZCXImageBannerPageControlLayoutBottmCenter*/

@property (strong, nonatomic) UIColor *pageIndicatorTintColor;
@property (strong, nonatomic) UIColor *currentPageIndicatorTintColor;


- (void)reloadImageData;

- (void)startTimer;
- (void)stopTimer;

@end
