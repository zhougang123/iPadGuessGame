//
//  GuessHistoryTableCell.m
//  Prizegame
//
//  Created by mac on 15/10/9.
//  Copyright © 2015年 qfpay. All rights reserved.
//

#import "GuessHistoryTableCell.h"

#import "PGCustomView.h"

@interface GuessHistoryTableCell ()

@property(nonatomic, strong) UILabel *deskNameLab;
@property(nonatomic, strong) UILabel *roundLab;

@property(nonatomic, strong) UIButton *modifyButton;
@property(nonatomic, strong) UIButton *cancelButton;

@property(nonatomic, strong) UILabel *guessDateLabel;
@property(nonatomic, strong) UILabel *beautyNumLabel;
@property(nonatomic, strong) UILabel *managerNumLabel;

@property(nonatomic, strong) PGCustomView *customView;

@property(nonatomic, strong) UILabel *resultLabel;

@property(nonatomic, strong) UILabel *statusLabel;

@end


@implementation GuessHistoryTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.deskNameLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH/4.0, 80)];
        self.deskNameLab.font = [UIFont boldSystemFontOfSize:10 *BILI_WIDTH];
        self.deskNameLab.textAlignment = NSTextAlignmentLeft;

        self.roundLab = [[UILabel alloc] initWithFrame:CGRectMake(20 + SCREEN_WIDTH/4.0, 0, SCREEN_WIDTH/4.0, 80)];
        self.roundLab.font = [UIFont boldSystemFontOfSize:10 *BILI_WIDTH];
        self.roundLab.textAlignment = NSTextAlignmentLeft;
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(SCREEN_WIDTH - 20 - 40 * BILI_WIDTH, 20, 40 * BILI_WIDTH, 40);
        self.cancelButton.layer.cornerRadius = 3;
        self.cancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.cancelButton.layer.borderWidth = 1.0;
        [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"取 消" forState:UIControlStateNormal];
        
        self.modifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.modifyButton.frame = CGRectMake(SCREEN_WIDTH - 30 - 80 * BILI_WIDTH, 20, 40 * BILI_WIDTH, 40);
        self.modifyButton.layer.cornerRadius = 3;
        self.modifyButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.modifyButton.layer.borderWidth = 1.0;
        [self.modifyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.modifyButton setTitle:@"修 改" forState:UIControlStateNormal];
        
        self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.modifyButton.frame) - 40 - 40 * BILI_WIDTH, 20, 40 * BILI_WIDTH, 40)];
        self.resultLabel.font = [UIFont systemFontOfSize:10 *BILI_WIDTH];
        self.resultLabel.textAlignment = NSTextAlignmentCenter;
        self.resultLabel.textColor = [UIColor redColor];
        self.resultLabel.text = @"4 , 5";
        
        UIView *greyLine = [[UIView alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, 1)];
        greyLine.backgroundColor = [UIColor lightGrayColor];
        
        
        self.guessDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.deskNameLab.frame), (SCREEN_WIDTH - 40.0)/3.0, 64)];
        self.guessDateLabel.font = [UIFont systemFontOfSize:8 *BILI_WIDTH];
        self.guessDateLabel.textAlignment = NSTextAlignmentLeft;
        self.guessDateLabel.textColor = [UIColor lightGrayColor];
        
        self.beautyNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + (SCREEN_WIDTH - 40.0)/3.0, CGRectGetMaxY(self.deskNameLab.frame), (SCREEN_WIDTH - 40.0)/3.0, 64)];
        self.beautyNumLabel.font = [UIFont systemFontOfSize:8 *BILI_WIDTH];
        self.beautyNumLabel.textAlignment = NSTextAlignmentLeft;
        self.beautyNumLabel.textColor = [UIColor lightGrayColor];

        
        self.managerNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + ((SCREEN_WIDTH - 40.0)/3.0)*2.0, CGRectGetMaxY(self.deskNameLab.frame), (SCREEN_WIDTH - 40.0)/3.0, 64)];
        self.managerNumLabel.font = [UIFont systemFontOfSize:8 *BILI_WIDTH];
        self.managerNumLabel.textAlignment = NSTextAlignmentLeft;
        self.managerNumLabel.textColor = [UIColor lightGrayColor];

        self.customView = [[PGCustomView alloc] initWithFrame:CGRectZero];
        self.customView.layer.borderColor = UIColorFromRGB(0xED881B).CGColor;
        self.customView.layer.borderWidth = 1.0;
        [self.contentView addSubview:self.deskNameLab];
        [self.contentView addSubview:self.roundLab];
        [self.contentView addSubview:self.modifyButton];
        [self.contentView addSubview:self.cancelButton];
        [self.contentView addSubview:self.resultLabel];
        
        [self.contentView addSubview:greyLine];
        
        [self.contentView addSubview:self.guessDateLabel];
        [self.contentView addSubview:self.beautyNumLabel];
        [self.contentView addSubview:self.managerNumLabel];
        [self.contentView addSubview:self.customView];
        
    
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)drawHistoryTableCellWithInfo:(NSDictionary *)dict
{
    self.deskNameLab.text = dict[@"deskName"];
    self.roundLab.text = [NSString stringWithFormat:@"第 %@ 轮", dict[@"roundNumber"]];
    
    NSString *timestring = [[dict objectforNotNullKey:@"addTime"] description];
    NSMutableArray *array = [[timestring componentsSeparatedByString:@"-"] mutableCopy];
    if (array) {
        [array removeObjectAtIndex:0];
        NSString *string = [NSString stringWithFormat:@"%@-%@",[array firstObject],[array lastObject]];
        self.guessDateLabel.text = [NSString stringWithFormat:@"竞猜时间: %@", string];
    }else{
        self.guessDateLabel.text = @"暂无时间";
    }

    self.beautyNumLabel.text = [NSString stringWithFormat:@"包房佳丽: %@", dict[@"beautyWorkNumber"]];
    self.managerNumLabel.text = [NSString stringWithFormat:@"客户经理: %@", dict[@"managerWorkNumber"]];
    
    
    NSArray *orderArray = [dict objectForKey:@"orderDetailVoList"];
    self.customView.frame = CGRectMake(20, CGRectGetMaxY(self.guessDateLabel.frame), SCREEN_WIDTH - 40, 50 * [orderArray count] + 25);
    [self setNeedsLayout];
    [self.customView setNeedsDisplay];
    self.customView.detialsArray = orderArray;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
