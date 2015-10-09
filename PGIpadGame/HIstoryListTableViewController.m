//
//  HIstoryListTableViewController.m
//  PGGame
//
//  Created by RIMI on 15/10/4.
//  Copyright (c) 2015年 qfpay. All rights reserved.
//

#import "HIstoryListTableViewController.h"
#import "GuessHistoryTableCell.h"


#define kOneLineHeight (15 * BILI_WIDTH)

@interface HIstoryListTableViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong)NSMutableArray *dataSource;

@property (nonatomic,strong)NSNumber *cancelOrderID;
@end

@implementation HIstoryListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xECECEF);
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    [self netWorking];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellModifyButtonAction:) name:@"cellModifyButtonAction" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellCancelButtonAction:) name:@"cellCancelButtonAction" object:nil];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 4)];
    self.tableView.tableFooterView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    WS(weakself);
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakself netWorking];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)netWorking{
    
    [SVProgressHUD show];
    WS(weakself);
    [GMNetWorking getHistoryListWithTimeout:15 completion:^(id obj) {
        [SVProgressHUD dismiss];
        [weakself.tableView.header endRefreshing];
        NSArray *infoArray = (NSArray *)obj;
        if ([infoArray count] > 0) {
            [weakself.dataSource removeAllObjects];
            for (int i = 0; i < [obj count]; i++) {
                NSDictionary *dictInfo = obj[i];
                NSArray *guessArray = [dictInfo objectForKey:@"orderDetailVoList"];
                if ([guessArray count] > 0) {
                    [weakself.dataSource addObject:dictInfo];
                }
                
            }
        }else{
            [weakself.dataSource removeAllObjects];
        }
        
        [weakself.tableView reloadData];
        
    } fail:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error];
        [weakself.tableView.header endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"cell";
    GuessHistoryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[GuessHistoryTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell drawHistoryTableCellWithInfo:self.dataSource[indexPath.section]];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat rowHeight = 144 + 20 + 25;
    
    NSDictionary *dict = self.dataSource[indexPath.section];
    NSArray *orderArray = [dict objectForKey:@"orderDetailVoList"];
    rowHeight = rowHeight + [orderArray count] * 50;
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headHeight = 0;
    if (section == 0) {
        headHeight = 0;
    }else{
        headHeight = 4;
    }
    return headHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 4)];
    headView.backgroundColor = [UIColor lightGrayColor];

    return headView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



//点击修改按钮
- (void)cellModifyButtonAction:(NSNotification *)noti
{
    
    NSDictionary *dataSource = noti.userInfo;
    

    NSString *userID = [[dataSource objectforNotNullKey:@"waiterId"] description];
    if (![userID isEqualToString:[self.user.userID description]]) {
        
        [SVProgressHUD showErrorWithStatus:@"这不是您的下注的竞猜哦~"];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(clickCellModifyButtonWithDataSource:)]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate clickCellModifyButtonWithDataSource:dataSource];
    }
}


#pragma  mark -自动填充框架

//- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
//    return [UIImage imageNamed:@"3-1"];
//}
//
//- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
//{
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
//
//    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
//
//    animation.duration = 0.25;
//    animation.cumulative = YES;
//    animation.repeatCount = MAXFLOAT;
//
//    return animation;
//}


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"暂无数据，请稍后查看噢!";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"您也可以点击文字重新加载";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f]};
    
    return [[NSAttributedString alloc] initWithString:@"Continue" attributes:attributes];
}

- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    return [UIImage imageNamed:@"button_image"];
}


- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}



- (void)emptyDataSetDidTapView:(UIScrollView *)scrollView
{
    // Do something
    [self netWorking];
}



- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView
{
    // Do something
    [self netWorking];
}





//点击取消按钮
- (void)cellCancelButtonAction:(NSNotification *)noti
{
    NSDictionary *dataSource = noti.userInfo;
    
    NSString *userID = [[dataSource objectforNotNullKey:@"waiterId"] description];
    if (![userID isEqualToString:[self.user.userID description]]) {
        
        [SVProgressHUD showErrorWithStatus:@"这不是您的下注的竞猜哦~"];
        return;
    }
    
    self.cancelOrderID = [dataSource objectforNotNullKey:@"id"];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否取消此次下注？" delegate:self cancelButtonTitle:@"不" otherButtonTitles:@"是",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([alertView cancelButtonIndex] == buttonIndex) {
        
        return;
    }
    
    
    [SVProgressHUD show];
    WS(weakself);
    [GMNetWorking cancelOrderWithTimeout:15 orderID:self.cancelOrderID completion:^(id obj) {
        
        [SVProgressHUD showInfoWithStatus:@"取消成功"];
        [weakself netWorking];
        
    } fail:^(NSString *error) {
        
        [SVProgressHUD showErrorWithStatus:error];
        [weakself netWorking];
        
    }];
    
    
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
