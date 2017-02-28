# TLRefresh
自定义刷新控件
TLRefresh提供了一种自定义刷新控件的思路 

主要用一个分类实现：
```objc
#import <UIKit/UIKit.h>

typedef void(^CallBack)();

@interface UIScrollView (TLRefresh)
/**
 *添加头部刷新控件
 */
- (void)addHeaderWithCallBack:(CallBack)callBack;
/**
 *添加尾部刷新控件
 */
- (void)addFooterWithCallBack:(CallBack)callBack;
/**
 *结束刷新
 */
- (void)endRefresh;

@end
```
用法如下：
```
//添加头部刷新标签
    [self.tableView addHeaderWithCallBack:^{
        
        //请求网络数据
           
    }];
    
    //添加尾部刷新标签
    [self.tableView addFooterWithCallBack:^{
        
        //请求网络数据
        
    }];
```


![上下拉刷新效果图](http://upload-images.jianshu.io/upload_images/1318303-83b222f2976eb895.gif?imageMogr2/auto-orient/strip)
