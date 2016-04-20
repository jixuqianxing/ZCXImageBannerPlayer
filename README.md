# ZCXImageBannerPlayer

轮播控件封装，采用两张`UIImageView`来轮播网络或本地图片，节省内存消耗。

![image](https://github.com/jixuqianxing/ZCXImageBannerPlayer/blob/master/Screenshot/demo.gif?raw=true)

# 可实现的功能
* 可设置是否需要自动轮播
* 单张照片不展示Pagecontrol，不轮播
* Pagecontrol颜色自定义
* 设置轮播停留时长
* 当数据变化时可直接调用`- (void)reloadImageData`方法来更新UI数据


# 接口设计

类似`UITableView`数据源代理设计，整个控件不涉及任何第三方库。设置图片接口完全暴露给外界处理，做到无添加无污染。如：

```ruby
- (void)imageBannerPlayer:(ZCXImageBannerPlayer *)imageBannerPlayer
    loadImageForImageView:(UIImageView *)imageView
                  atIndex:(NSNumber *)index;
```

此代理方法，直接将需要展示图片的`UIImageView`暴露给外界，外界可以对`UIImageView`做任何操作，不管是展示网络图片、本地图片、占位图等等，都交由外界处理，你甚至可以在`UIImageView`上添加指示器。

下面示例是采用`SDWebImage`下载并展示图片：

```ruby
- (void)imageBannerPlayer:(ZCXImageBannerPlayer *)imageBannerPlayer loadImageForImageView:(UIImageView *)imageView atIndex:(NSNumber *)index {
    NSURL *url = [NSURL URLWithString:_imageArray[index.integerValue]];
    UIImage *placeholderImage = [self imageWithColor:[UIColor groupTableViewBackgroundColor] size:_imageBannerPlayer.bounds.size];
    [imageView sd_setImageWithURL:url placeholderImage:placeholderImage];
}
```