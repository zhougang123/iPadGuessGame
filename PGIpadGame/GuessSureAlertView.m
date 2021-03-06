//
//  GuessSureAlertView.m
//  PGGame
//
//  Created by mac on 15/10/4.
//  Copyright © 2015年 qfpay. All rights reserved.
//

#import "GuessSureAlertView.h"

@interface GuessSureAlertView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *oddsTableview;
@property (nonatomic, copy) NSArray *guessArray;
@end

@implementation GuessSureAlertView

- (id)initWithGuessArray:(NSArray *)infoArray {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.guessArray = infoArray;
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        
        NSInteger rows = [self.guessArray count] > 3 ? 3 : [self.guessArray count];
        
        UIView *alertBGView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4.0, (SCREEN_HEIGHT - (60 * rows + 120))/2.0 - 100, SCREEN_WIDTH/2.0, 60 * 2 + 90 * rows)];
        alertBGView.backgroundColor = [UIColor whiteColor];
        alertBGView.layer.cornerRadius = 5.0;
        alertBGView.layer.masksToBounds = YES;
        alertBGView.userInteractionEnabled = YES;
        
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2.0, 60)];
        headLabel.font = [UIFont systemFontOfSize:24];
        headLabel.textColor = [UIColor whiteColor];
        headLabel.backgroundColor = UIColorFromRGB(0xF63D44);
        headLabel.text = @"竞猜确认";
        headLabel.textAlignment = NSTextAlignmentCenter;
        [alertBGView addSubview:headLabel];
        
        
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(alertBGView.frame) - 60 , SCREEN_WIDTH/2.0, 60)];
        footView.userInteractionEnabled = YES;
        UIView *greyLinv = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(footView.frame)/2.0, 0, 1, 60)];
        greyLinv.backgroundColor = [UIColor lightGrayColor];
        
        UIView *greyLinh = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2.0, 1)];
        greyLinh.backgroundColor = [UIColor lightGrayColor];
        
        UIButton *buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonCancel.frame = CGRectMake(20, 10, CGRectGetWidth(alertBGView.frame)/2.0 - 40, 40);
        buttonCancel.layer.cornerRadius = 3;
        buttonCancel.layer.masksToBounds = YES;
        [buttonCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonCancel setTitle:@"取 消" forState:UIControlStateNormal];
        [buttonCancel addTarget:self action:@selector(cancelAlertView) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSure.frame = CGRectMake(20 + CGRectGetWidth(footView.frame)/2.0, 10, CGRectGetWidth(footView.frame)/2.0 - 40, 40);
        [buttonSure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
        buttonSure.layer.cornerRadius = 3;
        buttonSure.layer.masksToBounds = YES;
        [buttonSure addTarget:self action:@selector(sureAlertView) forControlEvents:UIControlEventTouchUpInside];
        
        [footView addSubview:buttonCancel];
        [footView addSubview:buttonSure];
        [footView addSubview:greyLinv];
        [alertBGView addSubview:footView];
        [footView addSubview:greyLinh];
        self.oddsTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headLabel.frame), SCREEN_WIDTH/2.0, rows * 90) style:UITableViewStylePlain];
        self.oddsTableview.delegate = self;
        self.oddsTableview.dataSource = self;
        self.oddsTableview.rowHeight = 90;
        self.oddsTableview.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        self.oddsTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        [alertBGView addSubview:self.oddsTableview];
        [self addSubview:alertBGView];

    }
    return self;
}

- (void)cancelAlertView{
    [self dismiss];
}

- (void)sureAlertView
{
    if ([self.delegate respondsToSelector:@selector(guessSureAlertSubmitToServer)]) {
        [self.delegate guessSureAlertSubmitToServer];
    }
    [self dismiss];
}

- (void)show{
    [shareAppDelegate.window addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.guessArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"odds";
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    GuessInfoModel *infoModel = self.guessArray[indexPath.row];
    
    UILabel *label1 = (UILabel *) [cell.contentView viewWithTag:1001];
    if (!label1) {
        label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2.0, 45)];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.textColor = [UIColor blackColor];
        label1.tag = 1001;
        label1.text = [NSString stringWithFormat:@"竞猜: %@ %@", infoModel.betModel.betType, infoModel.betModel.odds];
        [cell.contentView addSubview:label1];
    }
    label1.text = [NSString stringWithFormat:@"竞猜: %@ %@", infoModel.betModel.betType, infoModel.betModel.odds];
    
    
    UILabel *label2 = (UILabel *) [cell.contentView viewWithTag:1002];
    if (!label2) {
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH/2.0, 45)];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.textColor = [UIColor blackColor];
        label2.tag = 1002;
        label2.text = [NSString stringWithFormat:@"投注: %@ %@", infoModel.drinkName, infoModel.drinkNum];
        [cell.contentView addSubview:label2];
    }
     label2.text = [NSString stringWithFormat:@"投注: %@ %@", infoModel.drinkName, infoModel.drinkNum];
  

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
