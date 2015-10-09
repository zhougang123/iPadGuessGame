//
//  HIstoryListTableViewController.m
//  PGGame
//
//  Created by RIMI on 15/10/4.
//  Copyright (c) 2015年 qfpay. All rights reserved.
//

#import "HIstoryListTableViewController.h"
#import "HistoryTableViewCell.h"


#define kOneLineHeight (15 * BILI_WIDTH)

@interface HIstoryListTableViewController ()<UIAlertViewDelegate,DZNEmptyDataSetDelegate,DZNEmptyDataSetSource>

@property (nonatomic ,strong)NSMutableArray *dataSource;

@property (nonatomic,strong)NSNumber *cancelOrderID;
@end

@implementation HIstoryListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xECECEF);
    [self netWorking];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellModifyButtonAction:) name:@"cellModifyButtonAction" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellCancelButtonAction:) name:@"cellCancelButtonAction" object:nil];
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
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
        self.dataSource = [obj mutableCopy];
        
        NSMutableArray *indexArray = [NSMutableArray array];
        [weakself.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSArray *detailArray = [obj objectForKey:@"orderDetailVoList"];
            if (detailArray.count<=0) {
                [indexArray addObject:obj];
            }
        }];
        
        for (id obj in indexArray) {
            [weakself.dataSource removeObject:obj];
        }
        
        [weakself.tableView reloadData];
        
    } fail:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error];
        [weakself.tableView.header endRefreshing];
    }];
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[HistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSDictionary *dic = self.dataSource[indexPath.row];
    cell.dataSource = dic;
    [cell drawTableCellWithDetials:[dic objectForKey:@"orderDetailVoList"]];
//    CGRect frame = cell.frame;
//    frame.size.height = cellH;
//    cell.frame = frame;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    HistoryTableViewCell *cell = (HistoryTableViewCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    
//    CGFloat height = cell.frame.size.height;
    
    NSArray *dataArr = [self.dataSource[indexPath.row] objectForKey:@"orderDetailVoList"];
    CGFloat height = 64 *BILI_WIDTH +5 + 10 *BILI_WIDTH +kOneLineHeight * [dataArr count] +kOneLineHeight;
    
    return height;
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
