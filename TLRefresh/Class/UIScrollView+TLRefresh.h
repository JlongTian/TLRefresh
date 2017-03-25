//
//  UIScrollView+TLRefresh.h
//  TLRefresh
//
//  Created by 张天龙 on 17/2/27.
//  Copyright © 2017年 张天龙. All rights reserved.
//

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
