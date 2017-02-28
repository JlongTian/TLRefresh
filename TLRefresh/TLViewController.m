//
//  TLViewController.m
//  TLRefresh
//
//  Created by 张天龙 on 17/2/27.
//  Copyright © 2017年 张天龙. All rights reserved.
//

#import "TLViewController.h"
#import "UIScrollView+TLRefresh.h"

@interface TLViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation TLViewController

- (NSMutableArray *)dataArray{
    
    if (_dataArray==nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    __weak TLViewController *weakSelf = self;
    
    //添加头部刷新标签
    [self.tableView addHeaderWithCallBack:^{
        
        [weakSelf performSelector:@selector(addData:) withObject:[NSNumber numberWithBool:YES] afterDelay:2];
        
    }];
    
    //添加尾部刷新标签
    [self.tableView addFooterWithCallBack:^{
        
        [weakSelf performSelector:@selector(addData:) withObject:[NSNumber numberWithBool:NO] afterDelay:2];
        
    }];
    
    //添加数据
    for (NSInteger i=0; i<10; i++) {
        
        [self.dataArray addObject:[NSString stringWithFormat:@"第%ld个item",i]];
        
    }
    
    [self.tableView reloadData];
    
}

/**
 *模拟网络请求数据
 */
- (void)addData:(NSNumber *)obj{
    
    BOOL isHeader = [obj boolValue];
    
    NSInteger tag = (isHeader==YES)?0:self.dataArray.count;
    if (!tag) [self.dataArray removeAllObjects];
    
    for (NSInteger i=tag; i<tag+10; i++) {
        
        [self.dataArray addObject:[NSString stringWithFormat:@"第%ld个item",i]];
        
    }
    
    [self.tableView reloadData];
    [self.tableView endRefresh];
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* indentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
    
}


@end
