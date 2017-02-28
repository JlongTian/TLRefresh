//
//  UIScrollView+TLRefresh.m
//  TLRefresh
//
//  Created by 张天龙 on 17/2/27.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "UIScrollView+TLRefresh.h"
#import "CYLDeallocBlockExecutor.h"
#import <objc/runtime.h>

#define kContentSize @"contentSize"
#define kContentOffset @"contentOffset"
#define kPanState @"panGestureRecognizer.state"

#define kRefreshViewH 64

typedef enum : NSUInteger {
    TLRefreshStausEndRefresh,
    TLRefreshStausHeaderRefreshing,
    TLRefreshStausFooterRefreshing,
} TLRefreshStaus;

@interface UIScrollView ()

@property (strong,nonatomic) UILabel *refreshHeader;
@property (strong, nonatomic) UILabel *refreshFooter;
@property (copy,nonatomic) CallBack headerCallBack;
@property (copy,nonatomic) CallBack footerCallBack;
@property (nonatomic,assign) TLRefreshStaus staus;

@end

@implementation UIScrollView (TLRefresh)

static char refreshHeaderKey;
static char refreshFooterKey;
static char headerCallBackKey;
static char footerCallBackKey;
static char stausKey;

#pragma mark - setter和getter方法

- (void)setStaus:(TLRefreshStaus)staus{
    objc_setAssociatedObject(self, &stausKey, [NSNumber numberWithInt:staus], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TLRefreshStaus)staus{
    return [objc_getAssociatedObject(self, &stausKey) intValue];
}

- (void)setHeaderCallBack:(CallBack)headerCallBack{
    objc_setAssociatedObject(self, &headerCallBackKey, headerCallBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CallBack)headerCallBack{
    return objc_getAssociatedObject(self, &headerCallBackKey);
}

- (void)setFooterCallBack:(CallBack)footerCallBack{
    objc_setAssociatedObject(self, &footerCallBackKey, footerCallBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CallBack)footerCallBack{
    return objc_getAssociatedObject(self, &footerCallBackKey);
}

- (void)setRefreshHeader:(UIColor *)refreshHeader{
    objc_setAssociatedObject(self, &refreshHeaderKey, refreshHeader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)refreshHeader{
    return objc_getAssociatedObject(self, &refreshHeaderKey);
}

- (void)setRefreshFooter:(UIColor *)refreshFooter{
    objc_setAssociatedObject(self, &refreshFooterKey, refreshFooter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)refreshFooter{
    return objc_getAssociatedObject(self, &refreshFooterKey);
}

#pragma mark - 添加头部和尾部刷新标签

/**
 添加头部标签
 */
- (void)addHeaderWithCallBack:(CallBack)callBack{
    
    //1.创建刷新头部标签
    self.refreshHeader = [self creatRefreshHeader];
    self.headerCallBack = callBack;
    
    //2.添加监听
    [self addObserver];
    
}

- (UILabel *)creatRefreshHeader{
    
    UILabel *refreshHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, -kRefreshViewH, self.frame.size.width, kRefreshViewH)];
    refreshHeader.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    refreshHeader.textAlignment = NSTextAlignmentCenter;
    refreshHeader.backgroundColor = [UIColor clearColor];
    refreshHeader.font = [UIFont systemFontOfSize:12.0];
    refreshHeader.textColor = [UIColor lightGrayColor];
    [self addSubview:refreshHeader];
    return refreshHeader;
    
}

- (void)addObserver{
    
    [self addObserver:self forKeyPath:kContentSize options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:kPanState options:NSKeyValueObservingOptionNew context:NULL];
    
    //ScrollView销毁的时候会自动移除监听
    [self cyl_executeAtDealloc:^{
        
        [self removeObserver:self forKeyPath:kContentSize context:NULL];
        [self removeObserver:self forKeyPath:kContentOffset context:NULL];
        [self removeObserver:self forKeyPath:kPanState context:NULL];
        
        
    }];
    
}

/**
 添加尾部刷新标签
 */
- (void)addFooterWithCallBack:(CallBack)callBack{
    
   
    self.refreshFooter = [self creatRefreshFooter];
    self.footerCallBack = callBack;
    [self addObserver];
    
}

- (UILabel *)creatRefreshFooter{
    
    CGFloat contentSizeH = self.contentSize.height;
    CGFloat tableH = self.frame.size.height;
    UILabel *refreshFooter = [[UILabel alloc] init];
    refreshFooter.textAlignment = NSTextAlignmentCenter;
    refreshFooter.font = [UIFont systemFontOfSize:12.0];
    refreshFooter.textColor = [UIColor lightGrayColor];
    refreshFooter.backgroundColor = [UIColor clearColor];
    CGFloat footerY = contentSizeH<tableH?tableH:contentSizeH;
    refreshFooter.frame = CGRectMake(0, footerY, self.frame.size.width,kRefreshViewH);
    refreshFooter.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:refreshFooter];
    return refreshFooter;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    
    UIScrollView *scrollView = (UIScrollView *)object;
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat tableH = scrollView.frame.size.height;
    CGFloat footerMaxY = CGRectGetMaxY(self.refreshFooter.frame);
    CGFloat footerY = self.refreshFooter.frame.origin.y;
    CGFloat contentSizeH = scrollView.contentSize.height;
    CGFloat criticalValue = offsetY+tableH;
    
    if ([keyPath isEqualToString:kContentSize]) {
        
        //设置底部视图的frame
        CGSize size = [change[@"new"] CGSizeValue];
        //如果滑动距离太短的话，添加在表格的下面,每次刷新数据contentSize都会改变，尾部控件的frame要跟着改变
        CGFloat footerY = (size.height<tableH)?tableH:size.height;
        //如果没有内容就将底部视图隐藏起来
        self.refreshFooter.hidden = !size.height;
        self.refreshFooter.frame = CGRectMake(0,footerY, size.width, kRefreshViewH);
        
    }else if([keyPath isEqualToString:kContentOffset]){
        
        //根据滑动位置修改文字,正在刷新的时候拖拽不修改文字
        if (self.staus==TLRefreshStausEndRefresh) {
            
            if (offsetY<-kRefreshViewH) {
                self.refreshHeader.text = @"释放加载";
            }else if(offsetY<0 && offsetY>=-kRefreshViewH){
                self.refreshHeader.text = @"下拉加载更多";
            }else if (criticalValue>footerMaxY){
                self.refreshFooter.text = @"释放加载";
            }else if (criticalValue<=footerMaxY && criticalValue>footerY){
                self.refreshFooter.text = @"上拉加载更多";
            }
        }
        
    }else{
        
        //如果正在刷新的时候拖拽不回调
        if (self.staus) return;
        
        //如果要头部刷新，需要满足3个条件：
        //1.滑动手势刚结束
        //2.滑动距离超过临界值
        //3.它有设置头部刷新标签
        if(scrollView.panGestureRecognizer.state==UIGestureRecognizerStateEnded && offsetY<-kRefreshViewH && self.refreshHeader){
            
            //进入头部刷新状态
            self.staus = TLRefreshStausHeaderRefreshing;
            
            scrollView.contentInset = UIEdgeInsetsMake(kRefreshViewH, 0, 0, 0);
            
            self.refreshHeader.text = @"正在加载……";
            
            CallBack callBack = self.headerCallBack;
            if (callBack) {
                callBack();
            }
        
        //如果要尾部刷新，需要满足4个条件：
        //1.滑动手势刚结束
        //2.滑动距离超过临界值
        //3.它有设置尾部部刷新标签
        //4.滑动内容高度不为0
        }else if (scrollView.panGestureRecognizer.state==UIGestureRecognizerStateEnded  && criticalValue>footerMaxY && self.refreshFooter && contentSizeH) {
            
            //进入尾部刷新状态
            self.staus = TLRefreshStausFooterRefreshing;
            
            //如果滚动的高度小于表格的高度时，contentInset的bottom要加大才能出现底部加载控件
            CGFloat margin = tableH-contentSizeH;
            CGFloat bottom = contentSizeH<tableH?(kRefreshViewH+margin):kRefreshViewH;
            
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0);
            
            //修改位移，不然看不到底部加载控件
            if (contentSizeH<tableH) {
                scrollView.contentOffset = CGPointMake(0, kRefreshViewH);
            }else{
                scrollView.contentOffset = CGPointMake(0, contentSizeH+kRefreshViewH-tableH);
            }
            
            self.refreshFooter.text = @"正在加载……";
            
            CallBack callBack = self.footerCallBack;
            if (callBack) {
                callBack();
            }
            
        }
        
    }
}

#pragma mark - 结束刷新

- (void)endRefresh{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.contentInset = UIEdgeInsetsZero;
    }completion:^(BOOL finished) {
        self.staus = TLRefreshStausEndRefresh;
    }];
    
}


@end
