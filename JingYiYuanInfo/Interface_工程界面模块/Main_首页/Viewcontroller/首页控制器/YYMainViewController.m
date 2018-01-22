//
//  YYMainViewController.m
//  壹元服务
//
//  Created by VINCENT on 2017/6/23.
//  Copyright © 2017年 北京京壹元资讯信息服务有限公司. All rights reserved.
//

#import "YYMainViewController.h"
#import "YYTabBarViewController.h"
#import "YYNavigationViewController.h"
#import "PresentAnimation.h"
#import "YYMessageController.h"
#import "YYMainSearchController.h"

#import "MJRefresh.h"
#import "MJExtension.h"

#import "UIView+YYViewInWindow.h"
#import "AppDelegate+YYAppService.h"

#import "YYMainModel.h"

#import "YYMainHeadBannerCell.h"
#import "YYMainRollwordsCell.h"
#import "YYMainEightBtnCell.h"
#import "YYMainMarketDataCell.h"
#import "YYMainPushCell.h"
#import "YYMainSrollpicCell.h"

#import "YYMainCycleWebviewController.h"
#import "YYDetailViewController.h"
#import "YYPushController.h"

#import "YYBaseInfoDetailController.h"
#import "YYShowOtherDetailController.h"
#import "YYNiuNewsDetailViewController.h"
#import "YYPushServiceDetailController.h"

#import "YYBottomContainerView.h"
#import "YYMainTouchTableView.h"

#import "IAPShare.h"

#define messageButtonWidth 25.f
#define searchButtonWidth 30.f
#define navSubviewHeight  30.f


@interface YYMainViewController ()<UIViewControllerTransitioningDelegate,UITableViewDelegate,UITableViewDataSource>

/** 导航栏View*/
@property (nonatomic, strong) UIView *navView;

/** 消息按钮*/
@property (nonatomic, strong) UIButton *messageBtn;

/** 搜索按钮*/
@property (nonatomic, strong) UIButton *searchBtn;

/** tableview*/
@property (nonatomic, strong) YYMainTouchTableView *tableview;

/** 数据源模型*/
@property (nonatomic, strong) YYMainModel *mainModel;

/** heightArr*/
@property (nonatomic, strong) NSArray *heights;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;

@property (nonatomic, assign) BOOL canScroll;

@end

@implementation YYMainViewController
{
//    YYPushController *_push;
//    YYContainerViewController *_footer;
    YYBottomContainerView *_footer;
    PresentAnimation *_presentAnimation;
}
#pragma mark -- lifeCycle 生命周期  ----------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _presentAnimation = [[PresentAnimation alloc] init];
//        self.transitioningDelegate = self;
//        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    YYLog(@"首页的navigationcontroller的地址  %p",self.navigationController);
    
    [kNotificationCenter addObserver:self selector:@selector(repeatClickTabbar:) name:YYTabbarItemDidRepeatClickNotification object:nil];
    [kNotificationCenter addObserver:self selector:@selector(acceptMsg:) name:YYMainVCLeaveTopNotificationName object:nil];

    //创建子控件们
    [self createSubviews];
    
    if (@available(iOS 11.0, *)) {
        self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever ;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self loadNewData];
    
    [self configRemoteNotice];
    //检测版本更新
    [(AppDelegate*)kAppDelegate checkAppUpDate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)dealloc {
    [kNotificationCenter removeObserver:self name:YYTabbarItemDidRepeatClickNotification object:nil];
    [kNotificationCenter removeObserver:self name:YYMainVCLeaveTopNotificationName object:nil];
    [kNotificationCenter removeObserver:self name:YYReceivedRemoteNotification object:nil];
}


#pragma mark -- inner Methods 自定义方法  ----------------------------------------

/**
 *  创建子控件们
 */
- (void)createSubviews {
    
    [self.view addSubview:self.tableview];
    
    _footer = [[YYBottomContainerView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, kSCREENHEIGHT-YYTopNaviHeight)];
    self.tableview.tableFooterView = _footer;
    
    [self.view addSubview:self.navView];
    [self.navView addSubview:self.searchBtn];
    [self.navView addSubview:self.messageBtn];
}

- (void)configRemoteNotice {
    
    [kNotificationCenter addObserver:self selector:@selector(receivedRemoteNotice:) name:YYReceivedRemoteNotification object:nil];
}


/** 两次点击maincontroller*/
- (void)repeatClickTabbar:(NSNotification *)notice {
    
    if (self.view.window == nil) return;
    if (![self.view yy_intersectsWithAnotherView:nil]) return;
    
    [self.tableview.mj_header beginRefreshing];
//    [self.tableview scrollsToTop];
//    [self.tableview scrollRectToVisible:CGRectZero animated:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        [self.tableview setContentOffset:CGPointMake(0, 0) animated:YES];
    });
    
}


/** tab离开顶部时的通知*/
-(void)acceptMsg : (NSNotification *)notification{
    //NSLog(@"%@",notification);
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

/**
 *  点击消息按钮，进入消息列表
 */
- (void)messageClick:(UIButton *)messageBtn {
    YYLog(@"点击消息按钮");
    YYMessageController *message = [[YYMessageController alloc] init];
    message.jz_wantsNavigationBarVisible = YES;
    [self.navigationController pushViewController:message animated:YES];
}

/**
 *  跳转搜索页
 */
- (void)searchClick:(UIButton *)search {
    YYLog(@"首页搜索按钮点击");
    YYMainSearchController *mainSearchVc = [[YYMainSearchController alloc] init];
    mainSearchVc.jz_wantsNavigationBarVisible = NO;
    [self.navigationController pushViewController:mainSearchVc animated:YES];
}

/**
 *  刷新数据
 */
- (void)loadNewData {

    //请求成功自动缓存，如果当前数据源有数据，说明是手动刷新的操作，这时不用将缓存赋值给数据源，如果没有，则是第一次初始化等，需要将缓存赋值给数据源等success时，再重新赋值，覆盖掉之前的
    
//    [PPNetworkHelper GET:mainUrl parameters:nil success:^(id responseObject) {
//
//        [self.tableview.mj_header endRefreshing];
//        if (responseObject) {
//            self.mainModel = [YYMainModel mj_objectWithKeyValues:responseObject];
//            [self.tableview reloadData];
//        }
//    } failure:^(NSError *error) {
//        [self.tableview.mj_header endRefreshing];
//        [SVProgressHUD showErrorWithStatus:NETERRORMSG];
//        [SVProgressHUD dismissWithDelay:1];
//    }];
    [PPNetworkHelper GET:mainUrl parameters:nil responseCache:^(id responseCache) {
        if (!_mainModel.roll_pic.count && responseCache) {

            self.mainModel = [YYMainModel mj_objectWithKeyValues:responseCache];
            [self.tableview reloadData];
        }
    } success:^(id responseObject) {

        [self.tableview.mj_header endRefreshing];
        if (responseObject) {

            self.mainModel = [YYMainModel mj_objectWithKeyValues:responseObject];
            [self.tableview reloadData];
        }

    } failure:^(NSError *error) {

        [self.tableview.mj_header endRefreshing];
        [SVProgressHUD showErrorWithStatus:NETERRORMSG];
        [SVProgressHUD dismissWithDelay:1];
    }];
    
    
}

#pragma -- mark TableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = YYRGB(239, 239, 239);
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
        case 1:
            return 0.00001;
            break;
            
        default:
            return 5.0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.00001;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma -- mark TableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (indexPath.section) {
        case 0:{
            YYMainHeadBannerCell *bannerCell = [tableView dequeueReusableCellWithIdentifier:YYMainHeadBannerCellID];
            bannerCell.headBannerModels = self.mainModel.roll_pic;
            return bannerCell;
        }
            break;
        
        case 1:{
            YYMainRollwordsCell *rollwordsCell = [tableView dequeueReusableCellWithIdentifier:YYMainRollwordsCellID];
            rollwordsCell.rollwordsModels = self.mainModel.roll_words;
//            rollwordsCell.rollwordsBlock = ^(NSInteger index, YYMainRollwordsCell *cell){
//#warning 文字轮播的跳转
//                
//            };
            return rollwordsCell;
        }
            break;
            
        case 2:{
            
            YYMainEightBtnCell *eightbtnCell = [tableView dequeueReusableCellWithIdentifier:YYMainEightBtnCellID];

            return eightbtnCell;
        }
            break;
            
        case 3:{
            YYMainMarketDataCell *marketdataCell = [tableView dequeueReusableCellWithIdentifier:YYMainMarketDataCellID];
            [marketdataCell.dataImageView sd_setImageWithURL:[NSURL URLWithString:self.mainModel.zhishu.picurl] placeholderImage:imageNamed(@"placeholder")];
            return marketdataCell;
        }
            break;
            
        case 4:{
            
            YYMainPushCell *pushCell = [tableView dequeueReusableCellWithIdentifier:YYMainPostMsgCellID];
            if (self.mainModel.post_msg) {
                pushCell.postmsgmodel = self.mainModel.post_msg;
            }

            return pushCell;
        }
            break;
            
        default:{
            
            YYMainSrollpicCell *scrollpicCell = [tableView dequeueReusableCellWithIdentifier:YYMainSrollpicCellID];
            scrollpicCell.srollpicModels = self.mainModel.sroll_pic;
            
            return scrollpicCell;
        }
            break;
    }

}

#pragma mark -- scrollview 代理方法

/**
 *  滚动时的代理方法，改变导航栏的颜色及搜索按钮尺寸
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat alpha = (contentOffsetY-35)/100;
    if (alpha >= 1) {
        alpha = 1;
    }else if(alpha <= 0){
        alpha = 0;
    }
    [self.navView setBackgroundColor:[ThemeColor colorWithAlphaComponent:alpha]];
    
    CGRect frame = self.searchBtn.frame;
    
    if (contentOffsetY > 75) {//变大啦啦啦
        frame.size.width = kSCREENWIDTH-60;
        frame.origin.x = 40;
        [UIView animateWithDuration:0.5 animations:^{
            self.searchBtn.frame = frame;
        }];
    }else if (contentOffsetY < 50) {//变小啦啦啦
        frame.size.width = 30;
        frame.origin.x = kSCREENWIDTH - 50;
        [UIView animateWithDuration:0.5 animations:^{
            self.searchBtn.frame = frame;
        }];
    }
    
    CGFloat tabOffsetY = [_tableview rectForFooterInSection:5].origin.y + [_tableview rectForFooterInSection:5].size.height - YYTopNaviHeight;
    CGFloat offsetY = scrollView.contentOffset.y;
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    if (offsetY>=(int)tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
    }else{
        _isTopIsCanNotMoveTabView = NO;
    }
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:YYMainVCGoTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
            scrollView.showsVerticalScrollIndicator = NO;
            _canScroll = NO;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            //NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
                scrollView.showsVerticalScrollIndicator = NO;
            }
        }
    }

}


#pragma mark -------  自定义modal转场的代理方法  ---------------------------

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return _presentAnimation;
}



#pragma mark -- 推送区域  -------------------------------------

//处理远程推送通知
- (void)receivedRemoteNotice:(NSNotification *)notice {
    
    YYLogFunc
    YYLog(@"userinfo  ----  %@",notice.userInfo);
    AppDelegate *delegate = (AppDelegate *)kAppDelegate;
    if (delegate.remoteNotice) {
        //未运行APP接收到远程推送并打开
        [self handleRemoteNotice:delegate.remoteNotice];
        delegate.remoteNotice = nil;
    }else {
        //    [self handleRemoteNotice:notice.userInfo];
        //已经运行APP之后接收到了远程消息，
        [self showAlertNotice:notice.userInfo];
    }
}

/** 处理推送的后续动作 跳转详情页*/
- (void)handleRemoteNotice:(NSDictionary *)userInfo {
    
    NSString *type = userInfo[@"type"];
//    YYUser *user = [YYUser shareUser];
    
    YYTabBarViewController *tab = (YYTabBarViewController *)kKeyWindow.rootViewController;
    YYNavigationViewController  *nav = tab.selectedViewController;
    UIViewController *vc = nav.visibleViewController;
    
    if ([type isEqualToString:@"1"]) {//1普通资讯,
        
        YYBaseInfoDetailController *detail = [[YYBaseInfoDetailController alloc] init];
        detail.url = [NSString stringWithFormat:@"%@%@",infoWebJointUrl,userInfo[@"id"]];
        detail.newsId = userInfo[@"id"];
        detail.jz_wantsNavigationBarVisible = YES;
        [vc.navigationController pushViewController:detail animated:YES];
    }else if ([type isEqualToString:@"2"]) {//2演出,
        
        YYShowOtherDetailController *detail = [[YYShowOtherDetailController alloc] init];
        detail.url = [NSString stringWithFormat:@"%@%@",showWebJointUrl,userInfo[@"id"]];
        detail.jz_wantsNavigationBarVisible = YES;
        [vc.navigationController pushViewController:detail animated:YES];
    }else if ([type isEqualToString:@"3"]) {//3牛人资讯
        
        YYNiuNewsDetailViewController *detail = [[YYNiuNewsDetailViewController alloc] init];
        detail.url = [NSString stringWithFormat:@"%@%@",niuWebJointUrl,userInfo[@"id"]];
        detail.niuNewsId = userInfo[@"id"];
        detail.jz_wantsNavigationBarVisible = YES;
        [vc.navigationController pushViewController:detail animated:YES];
    }else if ([type isEqualToString:@"365"]) {//365推送
        
        if ([vc isKindOfClass:[YYPushController class]]) {
            return;
        }
        YYPushController *push = [[YYPushController alloc] init];
        push.pushId = userInfo[@"id"];
        push.jz_wantsNavigationBarVisible = YES;
        [vc.navigationController pushViewController:push animated:YES];
    }else if ([type isEqualToString:@"sp_time"]) {//按时间推送
        
//        YYPushServiceDetailController *serviceDetail = [[YYPushServiceDetailController alloc] init];
//        serviceDetail.url = [NSString stringWithFormat:@"%@&id=%@",pushDetailJointUrl,userInfo[@"id"]];
//        serviceDetail.jz_wantsNavigationBarVisible = YES;
//        [vc.navigationController pushViewController:serviceDetail animated:YES];
        
        [self showAlertNotice:userInfo];
//        [self dispatchRemoteSpecialNotice:userInfo];
    }else if ([type isEqualToString:@"sp_num"]) {//按次数推送
        
        [self showAlertNotice:userInfo];
//        [self dispatchRemoteSpecialNotice:userInfo];
    }
}


/** 处理远程发送的特色服务的信息*/
- (void)dispatchRemoteSpecialNotice:(NSDictionary *)userinfo {
    
    
}


//特色服务需弹框,APP在前台需弹框提醒，是否查看新闻
- (void)showAlertNotice:(NSDictionary *)userInfo {
    
    NSString *alertTitle = @"";
    NSString *alertBody = @"";
    
    alertTitle = userInfo[@"aps"][@"alert"][@"title"];
    alertBody = userInfo[@"aps"][@"alert"][@"body"];
    NSString *type = userInfo[@"type"];
    
    if ([type isEqualToString:@"sp_num"] || [type isEqualToString:@"sp_time"]) {
    
        alertBody = userInfo[@"aps"][@"alert"][@"tip"];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertBody preferredStyle:UIAlertControllerStyleAlert];
   
    YYWeakSelf
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        YYLog(@"点击了取消");
        if ([type isEqualToString:@"sp_num"] || [type isEqualToString:@"sp_time"]) {//按次数推送
            
            [weakSelf feedback:userInfo isLookUp:@"0"];
        }else {
            
            [weakSelf handleRemoteNotice:userInfo];
        }
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([type isEqualToString:@"sp_num"] || [type isEqualToString:@"sp_time"]) {//按次数推送
            
            [weakSelf feedback:userInfo isLookUp:@"1"];
        }else {
            
            [weakSelf handleRemoteNotice:userInfo];
        }
    }]];
    
    [kKeyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}


/* 第一次点击按次推送的消息  确认已查看*/
- (void)feedback:(NSDictionary *)userInfo isLookUp:(NSString *)isLookUp{
    
    YYUser *user = [YYUser shareUser];
    //权限判断
    NSString *type = [self type:userInfo[@"tip"]];
    
    if ([type isEqualToString:@"1"] && [isLookUp isEqualToString:@"1"]) {
        
        YYTabBarViewController *tab = (YYTabBarViewController *)kKeyWindow.rootViewController;
        YYNavigationViewController  *nav = tab.selectedViewController;
        UIViewController *vc = nav.visibleViewController;
        
        YYPushServiceDetailController *serviceDetail = [[YYPushServiceDetailController alloc] init];
        //    serviceDetail.url = [NSString stringWithFormat:@"%@&orderid=%@&id=%@&userid=%@",pushDetailJointUrl,userInfo[@"orderid"],userInfo[@"id"],user.userid];
        
        serviceDetail.url = [NSString stringWithFormat:@"?%@&userid=%@&type=%@&yesno=%@",pushDetailJointUrl,user.userid,type,isLookUp];
        serviceDetail.jz_wantsNavigationBarVisible = YES;
        [vc.navigationController pushViewController:serviceDetail animated:YES];
    }else {
        
        NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:user.userid,USERID,type,@"type",isLookUp,@"yesno", nil];
        [YYHttpNetworkTool GETRequestWithUrlstring:pushDetailJointUrl parameters:para success:^(id response) {
            
            //给后台发报告  用户取消或者没有资格并点击了确定
            YYLog(@"给后台发报告  用户取消或者没有资格并点击了确定 成功");
        } failure:^(NSError *error) {
            
        } showSuccessMsg:nil];
    }
    
}


- (NSString *)type:(NSString *)tip {
    
    if ([tip isEqualToString:@"尊敬的会员，您有新的股票信息，是否确认需要？"]) {
        return @"1";
    }else if ([tip isEqualToString:@"尊敬的会员，您已达持股上限3支（以上），再次与您确认是否需要？"]) {
        return @"1";
    }else if ([tip isEqualToString:@"尊敬的会员，您已达服务期限已过。"]) {
        return @"0";
    }else if ([tip isEqualToString:@"尊敬的会员，您尚未购买此服务，请联系客服010-87777898。"]) {
        return @"0";
    }else if ([tip isEqualToString:@"尊敬的用户，您尚未成为会员，请联系客服010-87777898。"]) {
        return @"0";
    }
    return @"0";
}

#pragma mark -- lazyMethods 懒加载区域  -------------------------------------

/** 
 *  导航栏
 */
- (UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREENWIDTH, YYTopNaviHeight)];
        _navView.backgroundColor = [ThemeColor colorWithAlphaComponent:0.f];
    }
    return _navView;
}

- (UIButton *)messageBtn{
    if (!_messageBtn) {
        _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _messageBtn.frame = CGRectMake(10, YYTopNaviHeight-navSubviewHeight-7, messageButtonWidth, navSubviewHeight);
        [_messageBtn setImage:imageNamed(@"yyfw_main_message_22x22") forState:UIControlStateNormal];
        [_messageBtn setTitleColor:WhiteColor forState:UIControlStateNormal];
        [_messageBtn addTarget:self action:@selector(messageClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageBtn;
}

- (UIButton *)searchBtn{
    if (!_searchBtn) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchBtn.frame = CGRectMake(kSCREENWIDTH-50, YYTopNaviHeight-navSubviewHeight-7, searchButtonWidth, navSubviewHeight);
        [_searchBtn setImage:imageNamed(@"yyfw_search_translucent_19x19_") forState:UIControlStateNormal];
        [_searchBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
//        [_searchBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [_searchBtn setTitle:@"   搜索股票、基金、债券" forState:UIControlStateNormal];
        _searchBtn.layer.masksToBounds = YES;
        _searchBtn.titleLabel.font = SubTitleFont;
        _searchBtn.layer.cornerRadius = navSubviewHeight/2;
        _searchBtn.backgroundColor = YYRGBA(200, 200, 200, 0.7);
        [_searchBtn addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBtn;
}


- (YYMainModel *)mainModel{
    if (!_mainModel) {
        _mainModel = [[YYMainModel alloc] init];
    }
    return _mainModel;
}

- (YYMainTouchTableView *)tableview{
    if (!_tableview) {
        _tableview = [[YYMainTouchTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.estimatedRowHeight = 100;
        _tableview.rowHeight = UITableViewAutomaticDimension;
        
        MJWeakSelf
        _tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            YYStrongSelf
            [strongSelf loadNewData];
            //给热搜和牛人发送通知，主界面刷新后子界面也要刷新
            [kNotificationCenter postNotificationName:YYMainRefreshNotification object:nil];
        }];
        
        [_tableview registerClass:[YYMainHeadBannerCell class] forCellReuseIdentifier:YYMainHeadBannerCellID];
        [_tableview registerClass:[YYMainRollwordsCell class] forCellReuseIdentifier:YYMainRollwordsCellID];
        [_tableview registerClass:[YYMainEightBtnCell class] forCellReuseIdentifier:YYMainEightBtnCellID];
        [_tableview registerClass:[YYMainMarketDataCell class] forCellReuseIdentifier:YYMainMarketDataCellID];
        [_tableview registerClass:[YYMainPushCell class] forCellReuseIdentifier:YYMainPostMsgCellID];
        [_tableview registerClass:[YYMainSrollpicCell class] forCellReuseIdentifier:YYMainSrollpicCellID];
    
        [_tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableview.contentInset = UIEdgeInsetsMake(0, 0, YYTabBarH, 0);
        [_tableview setSeparatorInset:UIEdgeInsetsMake(0, 0, YYTabBarH, 0)];

    }
    
    return _tableview;
}

- (NSArray *)heights{
    if (!_heights) {
        //头部轮播等比例0.6，快讯36，八个icon20*3+60*2，行情数据87，推送消息154，横幅轮播宽度的0.2倍
        _heights = [NSArray arrayWithObjects:@(kSCREENWIDTH*0.6), @36, @180, @87, @154, @(kSCREENWIDTH*0.2), @((float)kSCREENHEIGHT-64-49), nil];
    }
    return _heights;
}

@end
