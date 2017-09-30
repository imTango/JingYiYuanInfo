//
//  YYMineAboutUsViewController.m
//  壹元服务
//
//  Created by VINCENT on 2017/4/25.
//  Copyright © 2017年 北京京壹元资讯信息服务有限公司. All rights reserved.
//

#import "YYMineAboutUsViewController.h"
#import "YYMineIntroduceDetailController.h"
#import "UIView+YYCategory.h"

static NSString * const reviewURL = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1266188538&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";


@interface YYMineAboutUsViewController ()<UITableViewDelegate,UITableViewDataSource>

/** tableView*/
@property (nonatomic, strong) UITableView *tableView;

/** uiimageview*/
@property (nonatomic, strong) UIImageView *logoImageView;

/** version*/
@property (nonatomic, strong) UILabel *version;

/** tip*/
@property (nonatomic, strong) UILabel *tip;

@end

@implementation YYMineAboutUsViewController

#pragma mark -- lifeCycle 生命周期  --------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = GrayBackGroundColor;
    [self configSubView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}


#pragma mark -- layout 子控件配置及相关布局方法  ---------------------------

- (void)configSubView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, 120) style:UITableViewStylePlain];
//    tableView.yy_center = self.view.yy_center;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.rowHeight = 40;
    tableView.backgroundColor = WhiteColor;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:imageNamed(@"logo")];
//    logoImageView.yy_centerX = self.view.centerX;
//    logoImageView.yy_y = 150;
    self.logoImageView = logoImageView;
    [self.view addSubview:logoImageView];
    [logoImageView cutRoundViewRadius:10];
    
    UILabel *version = [[UILabel alloc] init];
//                        WithFrame:CGRectMake(0, CGRectGetMaxY(logoImageView.frame)+10, 150, 20)];
    version.centerX = self.view.centerX;
    version.textColor = UnenableTitleColor;
    version.font = UnenableTitleFont;
    version.text = [NSString stringWithFormat:@"当前版本  %@",kAppVersion];
    version.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:version];
    self.version = version;
    
    
    UILabel *tip = [[UILabel alloc] init];
//                    WithFrame:CGRectMake(0, 0, kSCREENWIDTH, 45)];
//    tip.centerX = self.view.centerX;
    tip.numberOfLines = 0;
    tip.yy_y = kSCREENHEIGHT-45;
    tip.textColor = UnenableTitleColor;
    tip.font = UnenableTitleFont;
    tip.text = @"【投资是一种生活】\n顺势而为，止盈止损，细水长流是王道\n借力上行，稳中求胜，互利共赢是共识";
    tip.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tip];
    self.tip = tip;
    
    
    
    [self.tableView makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(self.view);
        make.centerY.equalTo(self.view);
//        make.center.equalTo(self.view);
//        make.width.equalTo(self.view.width);
        make.height.equalTo(120);
    }];
    
    [self.version makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.tableView.top).offset(-60);
    }];
    
    [self.logoImageView makeConstraints:^(MASConstraintMaker *make) {
        
//        make.width.height.equalTo(60);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.version.top).offset(-10);
    }];
    
    
    [self.tip makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view.bottom).offset(-20);
        make.width.equalTo(self.view);
        make.centerX.equalTo(self.view.centerX);
    }];
    
}


#pragma -- mark TableViewDelegate  -----------------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            
            YYMineIntroduceDetailController *introduce = [[YYMineIntroduceDetailController alloc] init];
            introduce.url = appIntroduceUrl;
            introduce.title = @"壹元介绍";
            [self.navigationController pushViewController:introduce animated:YES];
        }
            break;
        
        case 1:{
            
            YYMineIntroduceDetailController *introduce = [[YYMineIntroduceDetailController alloc] init];
            introduce.url = userProtocolUrl;
            introduce.title = @"用户声明及协议";
            [self.navigationController pushViewController:introduce animated:YES];
        }
            break;
            
        default:{
            
            if([kApplication canOpenURL:[NSURL URLWithString:reviewURL]]) {
            
                [kApplication openURL:[NSURL URLWithString:reviewURL]];
            }
        }
            break;
    }
}

#pragma -- mark TableViewDataSource  --------------
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString*cellID = @"cellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [[self titles] objectAtIndex:indexPath.row];
    return cell;
}




- (NSArray *)titles {
    return @[@"壹元介绍",@"用户声明及协议",@"给我们评分"];
}


@end
