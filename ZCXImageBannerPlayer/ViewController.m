//
//  ViewController.m
//  ZCXImageBannerPlayer
//
//  Created by zcx on 16/4/19.
//  Copyright © 2016年 继续前行. All rights reserved.
//

#import "ViewController.h"
#import "ZCXImageBannerPlayer.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()<ZCXImageBannerPlayerDataSource, ZCXImageBannerPlayerDelegate>

@property (weak, nonatomic) IBOutlet ZCXImageBannerPlayer *imageBannerPlayer;

@property (weak, nonatomic) IBOutlet ZCXImageBannerPlayer *imageBannerPlayer1;

@property (strong, nonatomic) NSArray *imageArray;

@property (strong, nonatomic) UIImage *placeholderImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageArray = @[@"http://download.pchome.net/wallpaper/pic-5465-5-1366x768.jpg",
                    @"http://download.pchome.net/wallpaper/pic-5194-7-1366x768.jpg",
                    @"http://pic1.win4000.com/wallpaper/b/537dc675ef44f.jpg",
                    @"http://www.bz55.com/uploads/allimg/150608/139-15060Q60Z3-50.jpg",
                    @"http://d.3987.com/jxmnc_130710/003.jpg"];
    
    {
        _imageBannerPlayer.dataSource = self;
        _imageBannerPlayer.delegate   = self;
        
        // Set UIPagecontrol pageIndicatorTintColor and currentPageIndicatorTintColor
        _imageBannerPlayer.pageIndicatorTintColor = [UIColor lightGrayColor];
        _imageBannerPlayer.currentPageIndicatorTintColor = [UIColor blackColor];
        
        // Hidden UIPagecontrol
        /*_imageBannerPlayer.pageControlLayout = ZCXImageBannerPageControlLayoutNone;*/
        
        // 是否需要自动滚动播放，默认 YES
        /*_imageBannerPlayer.autoScroll = NO;*/
        
        // 展示图片停留时间，默认5s
        _imageBannerPlayer.remainTime = 2;
        
        // 数据更新了，直接调用此方法刷新数据，参考 UITableView reloadData 方法设计
        [_imageBannerPlayer reloadImageData];
    }
    
    {
        _imageBannerPlayer1.dataSource = self;
        _imageBannerPlayer1.delegate   = self;
        _imageBannerPlayer1.autoScroll = NO;
        [_imageBannerPlayer1 reloadImageData];
    }
}

#pragma mark - ZCXImageBannerPlayerDataSource

- (NSNumber *)numberOfImages {
    return @(_imageArray.count);
}

#pragma mark - ZCXImageBannerPlayerDelegate

- (void)imageBannerPlayer:(ZCXImageBannerPlayer *)imageBannerPlayer loadImageForImageView:(UIImageView *)imageView atIndex:(NSNumber *)index {
    
    // 示例：利用SDWebImage下载并展示图片
    NSURL *url = [NSURL URLWithString:_imageArray[index.integerValue]];
    UIImage *placeholderImage = [self imageWithColor:[UIColor groupTableViewBackgroundColor] size:_imageBannerPlayer.bounds.size];
    [imageView sd_setImageWithURL:url placeholderImage:placeholderImage];
}

- (void)imageBannerPlayer:(ZCXImageBannerPlayer *)imageBannerPlayer clickedAtIndex:(NSNumber *)index {
    NSLog(@"Clicked index = %@",index);
}



- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!_placeholderImage) {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        _placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGContextRelease(context);
    }
    return _placeholderImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
