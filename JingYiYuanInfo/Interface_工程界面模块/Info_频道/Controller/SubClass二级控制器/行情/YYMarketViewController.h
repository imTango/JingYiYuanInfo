//
//  YYMarketViewController.h
//  壹元服务
//
//  Created by VINCENT on 2017/8/8.
//  Copyright © 2017年 北京京壹元资讯信息服务有限公司. All rights reserved.
//

#import "YPTabBarController.h"


@interface YYMarketViewController : YPTabBarController

/** datas*/
@property (nonatomic, strong) NSArray *datas;

/** fatherId*/
@property (nonatomic, assign) NSInteger fatherId;

/** selectIndex*/
//@property (nonatomic, assign) NSInteger selectIndex;

@end
