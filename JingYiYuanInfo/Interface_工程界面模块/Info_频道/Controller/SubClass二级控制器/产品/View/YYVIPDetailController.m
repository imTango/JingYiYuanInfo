//
//  YYVIPDetailController.m
//  JingYiYuanInfo
//
//  Created by VINCENT on 2017/9/23.
//  Copyright © 2017年 北京京壹元资讯信息服务有限公司. All rights reserved.
//  购买会员

#import "YYVIPDetailController.h"
#import "YYIAPTool.h"

@interface YYVIPDetailController ()

/** buy*/
@property (nonatomic, strong) UIButton *buy;

@end

@implementation YYVIPDetailController


- (void)dealloc {
    
    [kNotificationCenter removeObserver:self name:YYIapSucceedNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = nil;
    [self.view addSubview:self.buy];
    [self.buy makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(50);
    }];
    
    [kNotificationCenter addObserver:self selector:@selector(pop:) name:YYIapSucceedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/** 购买会员*/
- (void)buyVip:(UIButton *)sender {
    
    YYUser *user = [YYUser shareUser];
    if (!user.isLogin) {
        [SVProgressHUD showErrorWithStatus:@"账号未登录"];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    
//    if (![user.groupid containsString:@"3"]) {
//        [SVProgressHUD showInfoWithStatus:@"非会员用户不能购买该产品"];
//        [SVProgressHUD dismissWithDelay:1];
//        return;
//    }
    
    [YYIAPTool buyProductByProductionId:@"com.yyapp_vip_1" type:@"1"];
}

- (void)pop:(NSNotification *)notice {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -- inner Methods 自定义方法  -------------------------------


//- (void)ttest {
// 
//    [YYIAPTool printReceipt];
//}


#pragma mark -- lazyMethods 懒加载区域  --------------------------

- (UIButton *)buy{
    if (!_buy) {
        _buy = [UIButton buttonWithType:UIButtonTypeCustom];
        _buy.enabled = NO;
        [_buy setTitle:@"购买会员" forState:UIControlStateNormal];
        [_buy setTitleColor:WhiteColor forState:UIControlStateNormal];
        [_buy setBackgroundColor:ThemeColor];
        [_buy addTarget:self action:@selector(buyVip:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buy;
}


//- (UIButton *)test {
//    
//    if (!_test) {
//        _test = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_test setTitle:@"test" forState:UIControlStateNormal];
//        [_test setTitleColor:WhiteColor forState:UIControlStateNormal];
//        [_test setBackgroundColor:ThemeColor];
//        [_test addTarget:self action:@selector(ttest) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _test;
//}


#pragma mark -------  wkWebview 代理方法  --------------------------------

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    [SVProgressHUD show];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    self.wkWebview.frame = CGRectMake(0, 0, kSCREENWIDTH, kSCREENHEIGHT-YYTopNaviHeight-50);
    YYWeakSelf
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        weakSelf.navigationItem.title = title;
    }];
    YYUser *user = [YYUser shareUser];
    NSString *js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%ld%%'",(NSInteger)user.webfont*100];
    [webView evaluateJavaScript:js completionHandler:nil];
    _buy.enabled = YES;
    [SVProgressHUD dismiss];
    
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    [self showPlaceHolder];
    [SVProgressHUD showErrorWithStatus:@"网络出错"];
    [SVProgressHUD dismissWithDelay:1];
}



@end
