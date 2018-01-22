//
//  YYProductionDetailController.m
//  JingYiYuanInfo
//
//  Created by VINCENT on 2017/9/20.
//  Copyright © 2017年 北京京壹元资讯信息服务有限公司. All rights reserved.
//  产品的详情，可购买

#import "YYProductionDetailController.h"
#import "YYIAPTool.h"

@interface YYProductionDetailController ()

/** buy*/
@property (nonatomic, strong) UIButton *buy;

@end

@implementation YYProductionDetailController

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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

/** 购买会员*/
- (void)buyProduct:(UIButton *)sender {
    
    YYUser *user = [YYUser shareUser];
    if (!user.isLogin) {
        [SVProgressHUD showErrorWithStatus:@"账号未登录"];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    if (![user.groupid containsString:@"3"]) {
        [SVProgressHUD showInfoWithStatus:@"非会员用户不能购买该产品"];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"产品提示" message:@"如欲了解关于产品的详细信息，请与我们的客服代表联系，点击确定拨打客服电话：010-87777077" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([kApplication canOpenURL:[NSURL URLWithString:@"telprompt://010-87777077"]]) {
            [kApplication openURL:[NSURL URLWithString:@"telprompt://010-87777077"]];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:confirm];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    //暂停购买资格，使用alert提示用户与客服代表联系
//    [YYIAPTool buyProductByProductionId:self.productionId type:@"3"];
    
}

- (void)pop:(NSNotification *)notice {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -------  wkWebview 代理方法  --------------------------------

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    [SVProgressHUD show];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    self.wkWebview.frame = CGRectMake(0, 0, kSCREENWIDTH, kSCREENHEIGHT-YYTopNaviHeight-50);
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        self.navigationItem.title = title;
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
    [SVProgressHUD dismiss];
}


#pragma mark -- lazyMethods 懒加载区域  --------------------------

- (UIButton *)buy{
    if (!_buy) {
        _buy = [UIButton buttonWithType:UIButtonTypeCustom];
        _buy.enabled = NO;
        [_buy setTitle:@"购买" forState:UIControlStateNormal];
        [_buy setTitleColor:WhiteColor forState:UIControlStateNormal];
        [_buy setBackgroundColor:ThemeColor];
        [_buy addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buy;
}


@end
