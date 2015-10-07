//
//  HistoryTableViewCell.h
//  PGGame
//
//  Created by RIMI on 15/10/4.
//  Copyright (c) 2015年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (nonatomic ,strong)NSDictionary *dataSource;

- (void)drawTableCellWithDetials:(NSArray *)detials;

@end
