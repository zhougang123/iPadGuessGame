//
//  HIstoryListTableViewController.h
//  PGGame
//
//  Created by RIMI on 15/10/4.
//  Copyright (c) 2015年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HistoryListTableViewControllerDelegate <NSObject>


- (void)clickCellModifyButtonWithDataSource:(NSDictionary *)dataSource;

@end

@interface HIstoryListTableViewController : UITableViewController

@property (nonatomic,weak)id<HistoryListTableViewControllerDelegate> delegate;

@property (nonatomic ,strong)PGUser *user;

@end
