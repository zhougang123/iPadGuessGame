//
//  MainViewController.m
//  PGGame
//
//  Created by RIMI on 15/9/26.
//  Copyright (c) 2015年 qfpay. All rights reserved.
//

#define LabelTag 1001

#import "MainViewController.h"
#import "BetButton.h"
#import "DeskInfoModel.h"
#import "GuessInfoModel.h"
#import "HIstoryListTableViewController.h"
#import "LoginViewContoller.h"


#define TableViewCellHeight 30 * BILI_WIDTH
#define TableViewCellFontSize 9 *BILI_WIDTH

typedef NS_ENUM(NSUInteger, TableViewType) {
    TableViewType_DeskInfo,
    TableViewType_BetInfo//酒水
};

typedef NS_ENUM(NSUInteger, CellLabelSType) {
    CellLabelSType_numberLabel = 8888,
    CellLabelSType_jialiLabel,
    CellLabelSType_managerLabel,
};


@interface MainViewController ()<GuessSureAlertViewDelegate,HistoryListTableViewControllerDelegate, UITableViewDataSource,UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate,UIAlertViewDelegate>
{
    DeskInfoModel *selectedDeskInfo;//选中的桌信息(桌号、佳丽、客户经理)
    BetButton *selectedBetButton;//选中的下注按钮(下注类型、赔率、酒水、酒水数量)
    UIButton *maskButton;//阴影按钮（tableView阴影背景）
    UITableView *tableListView;//列表（桌信息列表、下注列表）
    
    UILabel *drinksNumLabel;//计数label
    
    UIButton *historyBut;
}

@property (nonatomic ,strong)NSMutableArray *deskInfoArray;
@property (nonatomic ,strong)NSMutableArray *betInfoArray;
@property (nonatomic ,strong)NSMutableArray *managerInfoArray;

@property (nonatomic, strong)UIToolbar  *toolBar;
@property (nonatomic, strong)UIPickerView *deskPickerView;
@property (nonatomic, strong)UIPickerView *beautyPickerView;
@property (nonatomic, strong)UIPickerView *managerPickerView;

@property (nonatomic, strong)UITextField *selectDeskTF;
@property (nonatomic, strong)UITextField *selectBeautyTF;
@property (nonatomic, strong)UITextField *selectManagerTF;
@property (nonatomic, strong)UIButton    *deskButton;
@property (nonatomic, strong)UIButton    *beautyButton;
@property (nonatomic, strong)UIButton    *managerButton;

@property (nonatomic, strong)NSDictionary *deskInfoDist;
@property (nonatomic, strong)NSDictionary *beautyInfoDist;
@property (nonatomic, strong)NSDictionary *manmgerInfoDist;


@property (nonatomic, strong)NSMutableArray *drinkArray;

@property (nonatomic, strong)NSMutableArray *containerGuessArray;

@property (nonatomic, strong)GuessInfoModel *containerGuessInfo;

@property (nonatomic, strong)NSString *defaultDrinkID;

@property (nonatomic, strong)NSNumber *guessID;


@property (nonatomic, assign)BOOL isGuessModel;


@property (nonatomic, strong)DrinksModel *selectDrinkModel;
@end

@implementation MainViewController
- (UIPickerView *)deskPickerView
{
    if (_deskPickerView == nil) {
        _deskPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 216)];
        _deskPickerView.delegate = self;
        _deskPickerView.dataSource = self;
        _deskPickerView.backgroundColor = [UIColor whiteColor];
        _deskPickerView.tag = 10000;
    }
    return _deskPickerView;
    
}
- (UIPickerView *)beautyPickerView
{
    if (_beautyPickerView == nil) {
        _beautyPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 216)];
        _beautyPickerView.delegate = self;
        _beautyPickerView.dataSource = self;
        _beautyPickerView.backgroundColor = [UIColor whiteColor];
        _beautyPickerView.tag = 20000;
    }
    return _beautyPickerView;
}
- (UIPickerView *)managerPickerView
{
    if (_managerPickerView == nil) {
        _managerPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 216)];
        _managerPickerView.delegate = self;
        _managerPickerView.dataSource = self;
        _managerPickerView.backgroundColor = [UIColor whiteColor];
        _managerPickerView.tag = 30000;
    }
    return _managerPickerView;
}
//返回显示的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回当前列显示的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSInteger rows = 0;
    switch (pickerView.tag) {
        case 10000:
            rows = [self.deskInfoArray count];
            break;
        case 20000:
            rows = [self.betInfoArray count];
            break;
        case 30000:
            rows = [self.managerInfoArray count];
            break;
        default:
            break;
    }
    return rows;
}

//每行显示的文字样式
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view

{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 107, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14 * BILI_WIDTH];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    NSString *rowTitle = nil;
    
    switch (pickerView.tag) {
        case 10000:
            rowTitle = self.deskInfoArray[row][@"name"];
            break;
        case 20000:
            rowTitle = self.betInfoArray[row][@"workNumber"];
            break;
        case 30000:
            rowTitle = self.managerInfoArray[row][@"workNumber"];
            break;
        default:
            break;
    }
    titleLabel.text = rowTitle;
    return titleLabel;
    
}


- (UIToolbar *)toolBar
{
    if (_toolBar == nil) {
        _toolBar = [[ UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30 * BILI_WIDTH)];
        _toolBar.barStyle = UIBarStyleDefault;
        

        
        UIBarButtonItem *doneButton   = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(surePickerAction)];
        UIBarButtonItem *cancleButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPickerAction)];
        
        UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithTitle:@"选择房间信息"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:nil
                                                                       action:nil];
        titleButton.tintColor = [UIColor lightGrayColor];
        
        UIBarButtonItem *spaceButton1  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
        UIBarButtonItem *spaceButton2  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
        
        [_toolBar setItems:@[cancleButton, spaceButton1 ,titleButton, spaceButton2, doneButton]];
    }
    return _toolBar;
}
- (void)surePickerAction{
    if ([self.selectDeskTF isFirstResponder]) {
        NSInteger row1 = [self.deskPickerView selectedRowInComponent:0];
        [self.deskButton setTitle:self.deskInfoArray[row1][@"name"] forState:UIControlStateNormal];
        self.deskInfoDist = self.deskInfoArray[row1];
    }
    if ([self.selectBeautyTF isFirstResponder]) {
        NSInteger row2 = [self.beautyPickerView selectedRowInComponent:0];
        [self.beautyButton setTitle:self.betInfoArray[row2][@"workNumber"] forState:UIControlStateNormal];
        self.beautyInfoDist = self.betInfoArray[row2];

    }
    if ([self.selectManagerTF isFirstResponder]) {
        NSInteger row3 = [self.managerPickerView selectedRowInComponent:0];
        [self.managerButton setTitle:self.managerInfoArray[row3][@"workNumber"] forState:UIControlStateNormal];
        self.manmgerInfoDist = self.managerInfoArray[row3];

    }
    
    [self.selectDeskTF resignFirstResponder];
    [self.selectBeautyTF resignFirstResponder];
    [self.selectManagerTF resignFirstResponder];
}
- (void)cancelPickerAction
{
    [self.selectDeskTF resignFirstResponder];
    [self.selectBeautyTF resignFirstResponder];
    [self.selectManagerTF resignFirstResponder];

}
#pragma mark - configur UI

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xECECEF);
    
    self.isGuessModel = YES;
    
    self.deskInfoArray = [[NSMutableArray alloc] init];
    self.betInfoArray = [[NSMutableArray alloc] init];
    self.managerInfoArray = [[NSMutableArray alloc] init];
    self.drinkArray = [[NSMutableArray alloc] init];
    self.containerGuessArray = [[NSMutableArray alloc] init];
    
    
    self.selectDeskTF = [[UITextField alloc] initWithFrame:CGRectZero];
    self.selectDeskTF.inputView = self.deskPickerView;
    self.selectDeskTF.inputAccessoryView = self.toolBar;
    
    
    self.selectBeautyTF = [[UITextField alloc] initWithFrame:CGRectZero];
    self.selectBeautyTF.inputView = self.beautyPickerView;
    self.selectBeautyTF.inputAccessoryView = self.toolBar;
    
    self.selectManagerTF = [[UITextField alloc] initWithFrame:CGRectZero];
    self.selectManagerTF.inputView = self.managerPickerView;
    self.selectManagerTF.inputAccessoryView = self.toolBar;
    
    
    [self.view addSubview:self.selectDeskTF];
    [self.view addSubview:self.selectBeautyTF];
    [self.view addSubview:self.selectManagerTF];
    
    [self createUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)createUI{
    
    self.title = @"酒水竞猜";
   
    UIView *hederView = [self createHederView];
    
    CGFloat leftMargin = 10 * BILI_WIDTH;
    CGFloat topMargin = 16 * BILI_WIDTH;
    CGFloat margin = 18 * BILI_WIDTH;
    CGFloat buttonWidth = (SCREEN_WIDTH - (leftMargin * 2 +margin * 3))/4;
    CGFloat buttonHeight = 30 * BILI_WIDTH;
    
    WS(weakself);
    [SVProgressHUD show];
    [GMNetWorking getBetTypeAndOddsListWithTimeout:15 completion:^(id obj) {
        
        //创建投注按钮
        [SVProgressHUD showSuccessWithStatus:@"加载完成"];
        for (int i = 0 ; i < [obj count] ; i ++) {
            BetButton *button = [[BetButton alloc]initWithFrame:CGRectMake(leftMargin + i%4*(margin + buttonWidth) , CGRectGetMaxY(hederView.frame) + topMargin + i/4*(topMargin + buttonHeight), buttonWidth, buttonHeight)];
            
            BetModel *model = obj[i];
            button.betmodel = model;
            button.betTypeLabel.text = model.betType;
            button.oddsLabel.text = model.odds;
            button.tag = model.typeID;
            
            [button setBackgroundImage:[UIImage imageNamed:@"jincai_button_default"] forState:UIControlStateNormal];
            [button addTarget:weakself action:@selector(betButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [weakself.view addSubview:button];
            [weakself.view addSubview:button.betTypeLabel];
            [weakself.view addSubview:button.oddsLabel];
        }
        
        
        CGFloat confirmButWidth = 150 *BILI_WIDTH;
        CGFloat confirmButHeight = 25 *BILI_WIDTH;
        UIButton *confirm = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - confirmButWidth)/2, SCREEN_HEIGHT - confirmButHeight - 10 *BILI_WIDTH , confirmButWidth, confirmButHeight)];
        [confirm setBackgroundImage:[UIImage imageNamed:@"jingcai_button_submita"] forState:UIControlStateNormal];
        [confirm setTitle:@"确定竞猜" forState:UIControlStateNormal];
        confirm.titleLabel.font = [UIFont systemFontOfSize:9 * BILI_WIDTH];
        [confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirm addTarget:self action:@selector(sureGuessToServer) forControlEvents:UIControlEventTouchUpInside];
        
        maskButton = [self createMaskBut];
        tableListView = [self createDeskTableView];
        
        
        [self.view addSubview:confirm];
        [self.view addSubview:hederView];
        [self.view addSubview:maskButton];
        [self.view addSubview:tableListView];
        [self.view bringSubviewToFront:tableListView];
        
    } fail:^(NSString *error) {
        
        [SVProgressHUD showErrorWithStatus:error];
    }];
    
    

    
}

- (UIView *)createHederView{
    
    historyBut = [UIButton buttonWithType:UIButtonTypeCustom];
    historyBut.frame = CGRectMake(0, 0, 30 * BILI_WIDTH, 20 * BILI_WIDTH);
    [historyBut setTitle:@"竞猜历史" forState:UIControlStateNormal];
    [historyBut setTitleColor:TextGrayColor forState:UIControlStateNormal];
    historyBut.titleLabel.font = [UIFont systemFontOfSize:17];
    [historyBut addTarget:self action:@selector(historyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:historyBut];
    self.navigationItem.rightBarButtonItem = item;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"top_icon_exit"] style:UIBarButtonItemStylePlain target:self action:@selector(exitLogin)];
        self.navigationItem.leftBarButtonItem = leftItem;
    
    CGFloat hederViewHeight = 44 * BILI_WIDTH;
    UIView *hederView = [[UIView alloc]initWithFrame:CGRectMake(0, STATUS_AND_NAVI_BAR , SCREEN_WIDTH, hederViewHeight)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];
    
    hederView.backgroundColor = [UIColor whiteColor];
    //创建hederView按钮
    
    CGFloat width = SCREEN_WIDTH/3.0;
    UIImageView *deskIcon = [[UIImageView alloc] initWithFrame:CGRectMake(30 , 15 * BILI_WIDTH, 14 * BILI_WIDTH, 14 * BILI_WIDTH)];
    [deskIcon setImage:[UIImage imageNamed:@"jincai_icon_jiuzhuo"]];
    
    
    self.deskButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(deskIcon.frame), 13 * BILI_WIDTH, width - 20 * BILI_WIDTH - 30 * BILI_WIDTH, 18 * BILI_WIDTH)];
    self.deskButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.deskButton.layer.borderWidth = 1.0;
    [self.deskButton setTitle:@"桌号" forState:UIControlStateNormal];
    [self.deskButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.deskButton addTarget:self action:@selector(deskButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *beautyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(30 + width, 15 * BILI_WIDTH, 14 * BILI_WIDTH, 14 * BILI_WIDTH)];
    [beautyIcon setImage:[UIImage imageNamed:@"jincai_icon_jiali"]];
    
    self.beautyButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(beautyIcon.frame), 13 * BILI_WIDTH, width - 20 * BILI_WIDTH - 30 * BILI_WIDTH, 18 * BILI_WIDTH)];
    self.beautyButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.beautyButton.layer.borderWidth = 1.0;
    [self.beautyButton setTitle:@"佳丽" forState:UIControlStateNormal];
    [self.beautyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.beautyButton addTarget:self action:@selector(beautyButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *managerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(30 + width*2.0, 15 * BILI_WIDTH, 14 * BILI_WIDTH, 14 * BILI_WIDTH)];
    [managerIcon setImage:[UIImage imageNamed:@"jincai_icon_manager"]];
    
    self.managerButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(managerIcon.frame), 13 * BILI_WIDTH, width - 20 * BILI_WIDTH - 30 * BILI_WIDTH, 18 * BILI_WIDTH)];
    self.managerButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.managerButton.layer.borderWidth = 1.0;
    [self.managerButton setTitle:@"经理" forState:UIControlStateNormal];
    [self.managerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.managerButton addTarget:self action:@selector(managerButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [hederView addSubview:deskIcon];
    [hederView addSubview:self.deskButton];
    
    [hederView addSubview:beautyIcon];
    [hederView addSubview:self.beautyButton];
    
    [hederView addSubview:managerIcon];
    [hederView addSubview:self.managerButton];
    return hederView;
    
}
- (void)deskButtonAction{
    
    WS(weakSelf);
    
    
    if (self.isGuessModel == NO) {
        
        [SVProgressHUD showErrorWithStatus:@"目前为修改订单模式，不可修改桌号"];
        return;
    }
    [GMNetWorking getDeskListWithTimeout:30 completion:^(id respDesk) {
        NSDictionary *resDictDesk = (NSDictionary *)respDesk;
        if ([resDictDesk count] > 0) {
            NSArray *desks = resDictDesk[@"data"];
            [weakSelf.deskInfoArray removeAllObjects];
            [weakSelf.deskInfoArray addObjectsFromArray:desks];
            [weakSelf.selectDeskTF becomeFirstResponder];
        }else{
            [SVProgressHUD showErrorWithStatus:@"未获取到桌号列表"];
        }
        
    } fail:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error.lowercaseString];
        
    }];

    
    
}
- (void)beautyButtonAction{
    WS(weakSelf);
    if (self.isGuessModel == NO) {
        
        [SVProgressHUD showErrorWithStatus:@"目前为修改订单模式，不可修改佳丽"];
        return;
    }
    [GMNetWorking getBeautyListWithTimeout:30 completion:^(id respBeauty) {
        NSDictionary *resDictBeauty = (NSDictionary *)respBeauty;
        if ([resDictBeauty count] > 0) {
            NSArray *brauties = resDictBeauty[@"data"];
            [weakSelf.betInfoArray removeAllObjects];
            [weakSelf.betInfoArray addObjectsFromArray:brauties];
            
            [weakSelf.selectBeautyTF becomeFirstResponder];
        }else{
            [SVProgressHUD showErrorWithStatus:@"未获取到佳丽列表"];
        }
    } fail:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error.lowercaseString];
    }];

    

}
- (void)managerButtonAction{
    WS(weakSelf);
    if (self.isGuessModel == NO) {
        
        [SVProgressHUD showErrorWithStatus:@"目前为修改订单模式，不可修改经理"];
        return;
    }
    [GMNetWorking getManagerListWithTimeout:30.0 completion:^(id respManager) {
        NSDictionary *resDictManager = (NSDictionary *)respManager;
        if ([resDictManager count] > 0) {
            NSArray *managers = resDictManager[@"data"];
            [weakSelf.managerInfoArray removeAllObjects];
            [weakSelf.managerInfoArray addObjectsFromArray:managers];
            
            
            [self.selectManagerTF becomeFirstResponder];

        }else{
            [SVProgressHUD showErrorWithStatus:@"未获取到经理列表"];
        }
    } fail:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error.lowercaseString];
    }];
    

}
- (UITableView *)createDeskTableView{
    UITableView *deskTabV = [[UITableView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 160 * BILI_WIDTH) style:UITableViewStylePlain];
    deskTabV.tableFooterView = [[UIView alloc]init];
    deskTabV.delegate = self;
    deskTabV.dataSource = self;
    
    return deskTabV;
}

- (UIButton *)createMaskBut{
    UIButton *maskBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [maskBut addTarget:self action:@selector(hiddenList) forControlEvents:UIControlEventTouchUpInside];
    maskBut.frame = self.view.frame;
    maskBut.backgroundColor = [UIColor blackColor];
    maskBut.alpha = 0.5;
    maskBut.hidden = YES;
    
    return maskBut;
}




- (void)updateBetButton:(BetButton *)but{
    
//    but.betmodel.drinksNumber = [NSNumber numberWithInteger:[drinksNumLabel.text integerValue]];
    
    if ([but.betmodel.drinksNumber intValue]==0) {
        
        [but setBackgroundImage:[UIImage imageNamed:@"jincai_button_default"] forState:UIControlStateNormal];
        but.betTypeLabel.textColor = TextGrayColor;
        but.oddsLabel.textColor = TextRedColor;
        but.isBetSelect = NO;


    }else{
        
        [but setBackgroundImage:[UIImage imageNamed:@"jincai_button_press"] forState:UIControlStateNormal];
        but.betTypeLabel.textColor = [UIColor whiteColor];
        but.oddsLabel.textColor = [UIColor whiteColor];
        but.isBetSelect = YES;
    }
    
   
}


#pragma mark - 事件响应

//点击了下注按钮
- (void)betButtonAction:(BetButton *)button{
   
    WS(weakSelf);
    selectedBetButton = button;
    
    BetModel *betModel = button.betmodel;
    
    [SVProgressHUD show];
    [GMNetWorking getDrinksListWithTimeout:30 completion:^(id obj) {
        
        NSArray *drinks = (NSArray *)obj;
        if ([drinks count] > 0) {
            [SVProgressHUD dismiss];
            
            [weakSelf.drinkArray removeAllObjects];
            [weakSelf.drinkArray addObjectsFromArray:drinks];
            weakSelf.containerGuessInfo = [[GuessInfoModel alloc] init];
            if (selectedBetButton.isBetSelect == YES) {
                for (int i = 0; i < [self.containerGuessArray count]; i++) {
                    GuessInfoModel *selectedModel = self.containerGuessArray[i];
                    if (selectedBetButton.tag == [selectedModel.oddsID integerValue]) {
                        weakSelf.containerGuessInfo.drinkID = selectedModel.drinkID;
                        weakSelf.containerGuessInfo.oddsID = selectedModel.oddsID;
                        weakSelf.containerGuessInfo.drinkNum = selectedModel.drinkNum;
                        weakSelf.containerGuessInfo.drinkName = selectedModel.drinkName;
                        weakSelf.containerGuessInfo.betModel = betModel;
                        drinksNumLabel.text = selectedModel.drinkNum;
                        weakSelf.defaultDrinkID = selectedModel.drinkID;
                        break;
                    }
                }
                
                for (DrinksModel *model in weakSelf.drinkArray) {
                    if (model.drinksID == [weakSelf.defaultDrinkID integerValue]) {
                        weakSelf.selectDrinkModel = model;
                        break;
                    }
                }
            }else{
                drinksNumLabel.text = @"0";
                DrinksModel *drinkInfo = weakSelf.drinkArray[0];
                weakSelf.selectDrinkModel = drinkInfo;
                weakSelf.containerGuessInfo.drinkID = [NSString stringWithFormat:@"%li", drinkInfo.drinksID];
                weakSelf.containerGuessInfo.drinkName = drinkInfo.name;
                weakSelf.containerGuessInfo.oddsID =[NSString stringWithFormat:@"%ld", button.tag];
                weakSelf.containerGuessInfo.drinkNum = @"0";
                weakSelf.containerGuessInfo.betModel = betModel;
                weakSelf.defaultDrinkID = [NSString stringWithFormat:@"%li", drinkInfo.drinksID];

            }
            
            
            [self showTableViewListWithType:TableViewType_BetInfo];
            [self updateBetButton:button];
            
            
            [tableListView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:@"没有获取到酒水信息"];
        }
        
    } fail:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error.lowercaseString];

    }];
    
}




//点击了竞猜历史按钮
- (void)historyButtonAction:(UIButton *)but{
    
    if (self.isGuessModel) {
        //竞猜模式
        
        HIstoryListTableViewController *historyVC = [[HIstoryListTableViewController alloc]init];
        historyVC.user = self.user;
        historyVC.delegate = self;
        historyVC.title = @"竞猜历史";
        [self.navigationController pushViewController:historyVC animated:YES];
        
    }else{
        //修改模式
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要退出修改吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 888;
        [alertView show];
    }
    
}

//点击了阴影按钮
- (void)hiddenList{
    
    self.containerGuessInfo = nil;
    
    CGRect frame = tableListView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    
    self.containerGuessInfo = nil;
    
    [UIView animateWithDuration:0.25 animations:^{
        tableListView.frame = frame;
        maskButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        maskButton.hidden = YES;
    }];
    
}

//点击了列表里面-
- (void)deleteButtonAction{
    
    NSInteger number = [drinksNumLabel.text integerValue];
    if (number <= 0) {
        [SVProgressHUD showErrorWithStatus:@"已经不能再减少了哦 - -!"];
        return;
    }
    
//    selectedBetButton.betmodel.drinksNumber = [NSNumber numberWithInteger:number - 1];
    
    drinksNumLabel.text = [[NSNumber numberWithInteger:number - 1] description];
    self.containerGuessInfo.drinkNum = drinksNumLabel.text;
}

//点击了列表里面的+
- (void)addbuttonAction{
    
    NSInteger number = [drinksNumLabel.text integerValue];
    if (number + 1 > self.selectDrinkModel.buyLimit) {
        [SVProgressHUD showErrorWithStatus:@"土豪，酒水数量已经很多了！ - -!"];
        return;
    }
    
//    selectedBetButton.betmodel.drinksNumber = [NSNumber numberWithInteger:number + 1];
    drinksNumLabel.text = [[NSNumber numberWithInteger:number + 1] description];
    self.containerGuessInfo.drinkNum = drinksNumLabel.text;
    
}

//点击了列表里的确定按钮
- (void)confirmButtonAction{
    
    if ([self.containerGuessInfo.drinkNum integerValue] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请选择下注的瓶数"];
        if (selectedBetButton.isBetSelect == YES) {
            selectedBetButton.oddsLabel.text = self.containerGuessInfo.betModel.odds;
            
            for (int i = 0; i < [self.containerGuessArray count]; i++) {
                GuessInfoModel *model = self.containerGuessArray[i];
                if (selectedBetButton.tag == [model.oddsID integerValue]) {
                    [self.containerGuessArray removeObject:model];
                    break;
                }
            }
            
            selectedBetButton.betmodel.drinksNumber = [NSNumber numberWithInteger:0];
            drinksNumLabel.text = @"0";
            [self updateBetButton:selectedBetButton];
            [self hiddenList];
        }
        return;
    }
    for (GuessInfoModel *model in self.containerGuessArray) {
        if ([model.oddsID isEqualToString:self.containerGuessInfo.oddsID] ) {
            [self.containerGuessArray removeObject:model];
            break;
        }
    }
    [self.containerGuessArray addObject:self.containerGuessInfo];
    
    
    selectedBetButton.oddsLabel.text = [NSString stringWithFormat:@"%@ 瓶 %@", self.containerGuessInfo.drinkNum, self.containerGuessInfo.drinkName];
    
    selectedBetButton.betmodel.drinksNumber = [NSNumber numberWithInteger:[drinksNumLabel.text integerValue]];
    drinksNumLabel.text = @"0";
    self.selectDrinkModel = nil;
    
    self.containerGuessInfo = nil;
    [self updateBetButton:selectedBetButton];
    [self hiddenList];
}



#pragma  mark - Custom Methon

//展现tableView
- (void)showTableViewListWithType:(TableViewType)tableViewType{
    
    tableListView.tag = tableViewType;
    maskButton.alpha = 0;
    maskButton.hidden = NO;
    CGRect frame = tableListView.frame;
    frame.origin.y = SCREEN_HEIGHT - frame.size.height;
    [tableListView reloadData];
    [UIView animateWithDuration:0.25 animations:^{
        maskButton.alpha = 0.5;
        tableListView.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}

//配置选择桌信息HederView
- (void)configurationDeskTableHederView:(UIView *)hederView{
    
    CGFloat labelW = SCREEN_WIDTH / 3;
    UILabel *deskNumberLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelW, TableViewCellHeight)];
    deskNumberLb.textAlignment = NSTextAlignmentCenter;
    deskNumberLb.font = [UIFont systemFontOfSize:TableViewCellFontSize];
    
    UILabel *jialiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(deskNumberLb.frame), 0, labelW, TableViewCellHeight)];
    jialiLabel.textAlignment = NSTextAlignmentCenter;
    jialiLabel.font = [UIFont systemFontOfSize:TableViewCellFontSize];
    
    UILabel *managerNumberLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(jialiLabel.frame), 0, labelW, TableViewCellHeight)];
    managerNumberLb.textAlignment = NSTextAlignmentCenter;
    managerNumberLb.font = [UIFont systemFontOfSize:TableViewCellFontSize];
    
    deskNumberLb.text = @"桌号";
    jialiLabel.text = @"佳丽";
    managerNumberLb.text = @"客户经理";
    
    [hederView addSubview:deskNumberLb];
    [hederView addSubview:jialiLabel];
    [hederView addSubview:managerNumberLb];

    
}

//配置下注HederView
- (void)configurationBetTableHederView:(UIView *)hederView{
    
    CGFloat buttonTopMargin = 8 * BILI_WIDTH;
    UIButton *deletebutton = [[UIButton alloc]initWithFrame:CGRectMake(10 *BILI_WIDTH, buttonTopMargin, 14 *BILI_WIDTH, 14 * BILI_WIDTH)];
    [deletebutton setBackgroundImage:[UIImage imageNamed:@"jiushui_icon_-"] forState:UIControlStateNormal];
    [deletebutton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    drinksNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(deletebutton.frame)+ 10 * BILI_WIDTH, 10, 40 * BILI_WIDTH, TableViewCellHeight - 21)];
    drinksNumLabel.text = [selectedBetButton.betmodel.drinksNumber description];
    drinksNumLabel.text = [self.containerGuessInfo.drinkNum integerValue] > 0 ? self.containerGuessInfo.drinkNum : @"0";
    drinksNumLabel.textAlignment = NSTextAlignmentCenter;
    drinksNumLabel.font = [UIFont systemFontOfSize:10 *BILI_WIDTH];
    drinksNumLabel.layer.borderWidth = 1.0;
    drinksNumLabel.layer.borderColor = UIColorFromRGB(0xe0e0e0).CGColor;
    
    UIButton *addButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(drinksNumLabel.frame) + 10 *BILI_WIDTH, buttonTopMargin, CGRectGetWidth(deletebutton.frame), CGRectGetHeight(deletebutton.frame))];
    [addButton setBackgroundImage:[UIImage imageNamed:@"jiushui_icon_+"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addbuttonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *oddsLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(addButton.frame) +15*BILI_WIDTH, 10, 100 *BILI_WIDTH, TableViewCellHeight -21)];
    NSString *betType = selectedBetButton.betmodel.betType;
    oddsLabel.text = [NSString stringWithFormat:@"%@ (%@)",betType,selectedBetButton.betmodel.odds];
    oddsLabel.textColor = UIColorFromRGB(0xffa30b);
    oddsLabel.font = [UIFont systemFontOfSize:8 *BILI_WIDTH];
    oddsLabel.textAlignment = NSTextAlignmentCenter;
    oddsLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    
    UIButton* cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - CGRectGetWidth(drinksNumLabel.frame)*2 - 8*BILI_WIDTH - 10, 10,CGRectGetWidth(drinksNumLabel.frame), CGRectGetHeight(drinksNumLabel.frame))];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:10 *BILI_WIDTH];
    [cancelButton setTitleColor:UIColorFromRGB(0x545454) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(hiddenList) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setBackgroundColor:UIColorFromRGB(0xe0e0e0)];
    cancelButton.layer.cornerRadius = 8.0;
    
    UIButton *domeButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(cancelButton.frame) + 8 *BILI_WIDTH, 10, CGRectGetWidth(cancelButton.frame), CGRectGetHeight(cancelButton.frame))];
    
    [domeButton setTitle:@"确定" forState:UIControlStateNormal];
    [domeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [domeButton setBackgroundColor:UIColorFromRGB(0xffa30b)];
    [domeButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
    domeButton.layer.cornerRadius = 8.0;
    
    [hederView addSubview:domeButton];
    [hederView addSubview:cancelButton];
    [hederView addSubview:oddsLabel];
    [hederView addSubview:addButton];
    [hederView addSubview:drinksNumLabel];
    [hederView addSubview:deletebutton];
}


#pragma  mark - tableViewMethon

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger row;
    
    if (tableView.tag == TableViewType_DeskInfo) {
        //选择桌号、佳丽、客户经理
        
        row = self.deskInfoArray.count;
    }else{
        //选择下注酒水
        row = self.drinkArray.count;
    }
    
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSString *identifier = tableView.tag == TableViewType_DeskInfo? @"DeskInfoCell" : @"BetInfoCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BetInfoCell"];
//    if (!cell) {
//        if (tableView.tag == TableViewType_DeskInfo) {
//            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeskInfoCell"];
//        }else{
//            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BetInfoCell"];
//        }
//    }
    
    if (tableView.tag == TableViewType_DeskInfo) {
        DeskInfoModel *deskinfo = self.deskInfoArray[indexPath.row];
        CGFloat labelW = (SCREEN_WIDTH ) / 3;
        
        UILabel *deskNumberLb =(UILabel *) [cell.contentView viewWithTag:CellLabelSType_numberLabel];
        if (!deskinfo) {
        
            deskNumberLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelW, TableViewCellHeight)];
            deskNumberLb.textAlignment = NSTextAlignmentCenter;
            deskNumberLb.font = [UIFont systemFontOfSize:TableViewCellFontSize];
            deskNumberLb.tag = CellLabelSType_numberLabel;
            [cell.contentView addSubview:deskNumberLb];
        }
        
        UILabel *jialiLabel = (UILabel *)[cell.contentView viewWithTag:CellLabelSType_jialiLabel];
        if (!jialiLabel) {
            jialiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(deskNumberLb.frame), 0, labelW, TableViewCellHeight)];
            jialiLabel.textAlignment = NSTextAlignmentCenter;
            jialiLabel.font = [UIFont systemFontOfSize:TableViewCellFontSize];
            jialiLabel.tag = CellLabelSType_jialiLabel;
            [cell.contentView addSubview:jialiLabel];
        }
        
        UILabel *managerNumberLb = (UILabel *)[cell.contentView viewWithTag:CellLabelSType_managerLabel];
        if (!managerNumberLb) {
            managerNumberLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(jialiLabel.frame), 0, labelW, TableViewCellHeight)];
            managerNumberLb.textAlignment = NSTextAlignmentCenter;
            managerNumberLb.font = [UIFont systemFontOfSize:TableViewCellFontSize];
            managerNumberLb.tag = CellLabelSType_managerLabel;
            [cell.contentView addSubview:managerNumberLb];
            [cell layoutIfNeeded];
        }
        
        deskNumberLb.text = deskinfo.deskNumber;
        jialiLabel.text = deskinfo.jiali;
        NSString *manager = deskinfo.manager;
        managerNumberLb.text = manager;

        
    }else{
        UIImageView *selectIcon =[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, (TableViewCellHeight - 22)/2.0, 22, 22)];
        [cell.contentView addSubview:selectIcon];
        
        
        cell.textLabel.font = [UIFont systemFontOfSize:TableViewCellFontSize];
        DrinksModel *model = self.drinkArray[indexPath.row];
        if ([self.defaultDrinkID integerValue] == model.drinksID) {
            [selectIcon setImage:[UIImage imageNamed:@"jiushui_icon_xuanz"]];
        }else{
            [selectIcon setImage:nil];
            
        }
        cell.textLabel.text = model.name;
    }
    
    
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *hederView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TableViewCellHeight+1)];
    hederView.backgroundColor = [UIColor whiteColor];
    if (tableView.tag == TableViewType_DeskInfo) {
        //选择桌信息列表
        [self configurationDeskTableHederView:hederView];
        
    }else{
        [self configurationBetTableHederView:hederView];
        
    }
    
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, TableViewCellHeight, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = UIColorFromRGB(0xd0d0d0);
    [hederView addSubview:lineView];
    
    return hederView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return TableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return TableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == TableViewType_BetInfo) {
        
        DrinksModel *drinkInfo = self.drinkArray[indexPath.row];
        
        
        self.defaultDrinkID = [NSString stringWithFormat:@"%li", drinkInfo.drinksID];
        self.containerGuessInfo.drinkID = [NSString stringWithFormat:@"%li", drinkInfo.drinksID];
        self.containerGuessInfo.drinkName = drinkInfo.name;
        
        NSInteger selectNum = [drinksNumLabel.text integerValue];
        if (selectNum > drinkInfo.buyLimit) {
            self.containerGuessInfo.drinkNum = [NSString stringWithFormat:@"%li", drinkInfo.buyLimit];
        }
        self.selectDrinkModel = drinkInfo;
        
        [tableListView reloadData];
    }
}


- (void)sureGuessToServer
{
    
    if (self.deskInfoDist == nil) {
        [SVProgressHUD showErrorWithStatus:@"请先选择房间号"];
        return;
    }
    
    if (self.beautyInfoDist == nil) {
        [SVProgressHUD showErrorWithStatus:@"请选择佳丽"];
        return;
        
    }
    
    if (self.manmgerInfoDist == nil) {
        [SVProgressHUD showErrorWithStatus:@"请选择经理"];
        return;
    }
    
    if ([self.containerGuessArray count] <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请先下注"];
        return;
    }
    
    
    GuessSureAlertView *alert= [[GuessSureAlertView alloc] initWithGuessArray:self.containerGuessArray];
    alert.delegate = self;
    [alert show];
    
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}


- (void)guessSureAlertSubmitToServer
{
    if (!self.isGuessModel) {
        [self guessModifySubmitToServer:self.guessID];
        return;
    }
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    

    [paramDict setValue:self.deskInfoDist[@"id"] forKey:@"deskId"];

    [paramDict setValue:self.beautyInfoDist[@"id"] forKey:@"beautyId"];

    [paramDict setValue:self.manmgerInfoDist[@"id"] forKey:@"managerId"];
    
    [paramDict setValue:self.user.userID forKey:@"waiterId"];

    
    NSMutableArray *guessArray = [[NSMutableArray alloc] init];
    
    for (GuessInfoModel *model in self.containerGuessArray) {
        NSMutableDictionary *guessDict = [[NSMutableDictionary alloc] init];
        [guessDict setValue:model.oddsID forKey:@"oddsId"];
        [guessDict setValue:model.drinkNum forKey:@"drinkNum"];
        [guessDict setValue:model.drinkID forKey:@"drinkId"];
        [guessArray addObject:guessDict];
    }
    
    
    
    [paramDict setValue:guessArray forKey:@"orderDetailVoList"];
    
    
    [SVProgressHUD show];
    WS(weakSelf);
    
    [GMNetWorking submitGuessToServer:paramDict completion:^(id obj) {
        [SVProgressHUD showInfoWithStatus:@"竞猜成功"];
        
        for (int i = 0; i < [self.containerGuessArray count]; i++) {
            GuessInfoModel *model = self.containerGuessArray[i];
            BetButton *button = (BetButton *)[weakSelf.view viewWithTag:[model.oddsID integerValue]];
            button.oddsLabel.text = button.betmodel.odds;
            button.betmodel.drinksNumber = [NSNumber numberWithInteger:0];
            [self updateBetButton:button];
        }
        
        [weakSelf.containerGuessArray removeAllObjects];
        
        
        
        
    } fail:^(NSString *error) {
        if ([error isEqualToString:@"竞猜未开始或已结束"]) {
            for (int i = 0; i < [self.containerGuessArray count]; i++) {
                GuessInfoModel *model = self.containerGuessArray[i];
                BetButton *button = (BetButton *)[weakSelf.view viewWithTag:[model.oddsID integerValue]];
                button.isBetSelect = NO;
                button.oddsLabel.text = button.betmodel.odds;
                button.betmodel.drinksNumber = [NSNumber numberWithInteger:0];
                [self updateBetButton:button];
            }
            
            [weakSelf.containerGuessArray removeAllObjects];
        }
      
        
        [SVProgressHUD showErrorWithStatus:error.description];
    }];
    
    
    
    
}


//@property (nonatomic, strong) NSString *oddsID;
//@property (nonatomic, strong) NSString *drinkNum;
//@property (nonatomic, strong) NSString *drinkID;
//@property (nonatomic, strong) NSString *drinkName;
//@property (nonatomic, strong) BetModel *betModel;


//
//@property (nonatomic , strong)NSString *odds;//赔率
//
//@property (nonatomic , strong)NSString *betType;//押注类型
//@property (nonatomic , assign)NSInteger typeID;
//@property (nonatomic , strong)DrinksModel* drinksModel;
//@property (nonatomic , strong)NSNumber *drinksNumber;//下注酒水数量


//@property (nonatomic ,assign)NSInteger drinksID;
//@property (nonatomic ,strong)NSString *name;
//@property (nonatomic ,strong)NSNumber *price;
//@property (nonatomic ,assign)NSInteger buyLimit;

//修改订单====
- (void)clickCellModifyButtonWithDataSource:(NSDictionary *)dataSource{
    
    //清楚以前的赌注
    for (int i = 0; i < [self.containerGuessArray count]; i++) {
        GuessInfoModel *model = self.containerGuessArray[i];
        BetButton *button = (BetButton *)[self.view viewWithTag:[model.oddsID integerValue]];
        button.oddsLabel.text = button.betmodel.odds;
        button.betmodel.drinksNumber = [NSNumber numberWithInteger:0];
        [self updateBetButton:button];
    }
    self.containerGuessInfo = nil;
    selectedBetButton = nil;
    [self.containerGuessArray removeAllObjects];
    
    
    
    //显示要修改的赌注
    NSArray *orderList = dataSource[@"orderDetailVoList"];

    for (int i = 0; i < [orderList count]; i++) {
        NSDictionary *detial = orderList[i];
        GuessInfoModel *mode = [[GuessInfoModel alloc] init];
        
        mode.customID  = [NSString stringWithFormat:@"%@",detial[@"id"]];
        mode.oddsID    = [NSString stringWithFormat:@"%@",detial[@"oddsId"]];
        mode.drinkNum  = [NSString stringWithFormat:@"%@",detial[@"drinkNum"]];;
        mode.drinkName = [NSString stringWithFormat:@"%@",detial[@"drinkName"]];
        mode.drinkID   = [NSString stringWithFormat:@"%@",detial[@"drinkId"]];
        
        BetButton *betButton = (BetButton *)[self.view viewWithTag:[mode.oddsID integerValue]];
        betButton.oddsLabel.text = [NSString stringWithFormat:@"%@ 瓶 %@", mode.drinkNum, mode.drinkName];
        betButton.betmodel.drinksNumber = [NSNumber numberWithInteger:[mode.drinkNum integerValue]];
        mode.betModel = betButton.betmodel;
        [self.containerGuessArray addObject:mode];
        [self updateBetButton:betButton];
        
    }
    
    self.deskInfoDist = @{@"deskName":dataSource[@"deskName"],@"id":dataSource[@"deskId"]};
    self.beautyInfoDist = @{@"beautyWorkNumber":dataSource[@"beautyWorkNumber"],@"id":dataSource[@"beautyId"]};
    self.manmgerInfoDist = @{@"managerWorkNumber":dataSource[@"managerWorkNumber"],@"id":dataSource[@"managerId"]};
    //竞猜ID
    self.guessID = dataSource[@"id"];
    
    [self.deskButton setTitle:[NSString stringWithFormat:@"%@", dataSource[@"deskName"]] forState:UIControlStateNormal];
    [self.beautyButton setTitle:[NSString stringWithFormat:@"%@", dataSource[@"beautyWorkNumber"]] forState:UIControlStateNormal];
    [self.managerButton setTitle:[NSString stringWithFormat:@"%@", dataSource[@"managerWorkNumber"]] forState:UIControlStateNormal];
    
    self.isGuessModel = NO;///竞猜模式下不可以修改房间信息
    
    self.title = @"修改竞猜订单";
    [historyBut setTitle:@"退出修改" forState:UIControlStateNormal];
    
    
}





- (void)guessModifySubmitToServer:(NSNumber *)guessID
{
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    
    
    [paramDict setValue:self.deskInfoDist[@"id"] forKey:@"deskId"];
    
    [paramDict setValue:self.beautyInfoDist[@"id"] forKey:@"beautyId"];
    
    [paramDict setValue:self.manmgerInfoDist[@"id"] forKey:@"managerId"];
    
    [paramDict setValue:self.user.userID forKey:@"waiterId"];
    
    [paramDict setValue:guessID forKey:@"id"];
    
    NSMutableArray *guessArray = [[NSMutableArray alloc] init];
    
    for (GuessInfoModel *model in self.containerGuessArray) {
        NSMutableDictionary *guessDict = [[NSMutableDictionary alloc] init];
       
        if (model.customID) {
            [guessDict setValue:model.customID forKey:@"id"];
        }
        [guessDict setValue:model.oddsID forKey:@"oddsId"];
        [guessDict setValue:model.drinkNum forKey:@"drinkNum"];
        [guessDict setValue:model.drinkID forKey:@"drinkId"];
        [guessArray addObject:guessDict];
    }
    
    
    
    [paramDict setValue:guessArray forKey:@"orderDetailVoList"];
    
    
    [SVProgressHUD show];
    WS(weakSelf);
    
    [GMNetWorking submitGuessToServer:paramDict completion:^(id obj) {
        [SVProgressHUD showInfoWithStatus:@"修改成功"];
        
        for (int i = 0; i < [self.containerGuessArray count]; i++) {
            GuessInfoModel *model = self.containerGuessArray[i];
            BetButton *button = (BetButton *)[weakSelf.view viewWithTag:[model.oddsID integerValue]];
            button.oddsLabel.text = button.betmodel.odds;
            button.betmodel.drinksNumber = [NSNumber numberWithInteger:0];
            [self updateBetButton:button];
        }
        
        [weakSelf.containerGuessArray removeAllObjects];
        
        self.deskInfoDist = nil;
        self.beautyInfoDist = nil;
        self.manmgerInfoDist = nil;
        
        [self.deskButton setTitle:@"桌号" forState:UIControlStateNormal];
        [self.beautyButton setTitle:@"佳丽" forState:UIControlStateNormal];
        [self.managerButton setTitle:@"经理" forState:UIControlStateNormal];
        
        self.isGuessModel = YES;
        self.title = @"酒水竞猜";
        [historyBut setTitle:@"竞猜历史" forState:UIControlStateNormal];
        
        
        
    } fail:^(NSString *error) {
        
        for (int i = 0; i < [self.containerGuessArray count]; i++) {
                    GuessInfoModel *model = self.containerGuessArray[i];
                    BetButton *button = (BetButton *)[weakSelf.view viewWithTag:[model.oddsID integerValue]];
                    button.isBetSelect = NO;
                    button.oddsLabel.text = button.betmodel.odds;
                    button.betmodel.drinksNumber = [NSNumber numberWithInteger:0];
                    [self updateBetButton:button];
                }
        
                [weakSelf.containerGuessArray removeAllObjects];
        
        self.deskInfoDist = nil;
        self.beautyInfoDist = nil;
        self.manmgerInfoDist = nil;
        
        [self.deskButton setTitle:@"桌号" forState:UIControlStateNormal];
        [self.beautyButton setTitle:@"佳丽" forState:UIControlStateNormal];
        [self.managerButton setTitle:@"经理" forState:UIControlStateNormal];
        
        [SVProgressHUD showErrorWithStatus:error.description];
        self.isGuessModel = YES;
        self.title = @"酒水竞猜";
        [historyBut setTitle:@"竞猜历史" forState:UIControlStateNormal];
    }];
    
    
    
    
}


//退出登录
- (void)exitLogin{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要退出登录吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 1000;
    [alert show];
    
   
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    
    if (alertView.tag == 1000) {
        LoginViewContoller *loginVC = [[LoginViewContoller alloc]init];
        UINavigationController *loginNavi = [[UINavigationController alloc]initWithRootViewController:loginVC];
        [self.navigationController presentViewController:loginNavi animated:NO completion:^{
            
        }];
    }else if (alertView.tag == 888){
        //退出竞猜
        
        //1.修改右边按钮文字  2.修改title  3.清除下注按钮数据  4.清除佳丽经理桌号数据 5.isguessModle设为YES

         [historyBut setTitle:@"竞猜历史" forState:UIControlStateNormal];
        self.title = @"酒水竞猜";
        
        //清楚以前的赌注
        for (int i = 0; i < [self.containerGuessArray count]; i++) {
            GuessInfoModel *model = self.containerGuessArray[i];
            BetButton *button = (BetButton *)[self.view viewWithTag:[model.oddsID integerValue]];
            button.oddsLabel.text = button.betmodel.odds;
            button.betmodel.drinksNumber = [NSNumber numberWithInteger:0];
            [self updateBetButton:button];
        }
        self.containerGuessInfo = nil;
        selectedBetButton = nil;
        [self.containerGuessArray removeAllObjects];
        
        self.deskInfoDist = nil;
        self.beautyInfoDist = nil;
        self.manmgerInfoDist = nil;
        
        [self.deskButton setTitle:@"桌号" forState:UIControlStateNormal];
        [self.beautyButton setTitle:@"佳丽" forState:UIControlStateNormal];
        [self.managerButton setTitle:@"经理" forState:UIControlStateNormal];
        
        self.isGuessModel = YES;
    }
}




@end
