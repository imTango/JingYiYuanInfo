//
//  YYProjectCell.m
//  JingYiYuanInfo
//
//  Created by VINCENT on 2017/9/24.
//  Copyright © 2017年 北京京壹元资讯信息服务有限公司. All rights reserved.
//

#import "YYProjectCell.h"
#import "YYProjectModel.h"
#import "YYTagView.h"

@interface YYProjectCell()

/** leftImageView*/
@property (nonatomic, strong) UIImageView *leftImageView;

/** 项目图片上的标签*/
@property (nonatomic, strong) UILabel *imageTagLabel;

/** 项目标题*/
@property (nonatomic, strong) UILabel *title;

/** 项目描述*/
@property (nonatomic, strong) UILabel *subTitle;

/** 标签1*/
@property (nonatomic, strong) YYTagView *tag1;

/** 价格*/
@property (nonatomic, strong) UILabel *hits;

/** 在线咨询*/
@property (nonatomic, strong) UIButton *connect;

@end

@implementation YYProjectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self configSubView];
        [self masonrySubView];
    }
    return self;
}

#pragma mark -- layout 子控件配置及相关布局方法  ---------------------------

- (void)configSubView {
    
    UIImageView *leftImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:leftImageView];
    self.leftImageView = leftImageView;
    
    UILabel *imageTagLabel = [[UILabel alloc] init];
    imageTagLabel.textAlignment = NSTextAlignmentCenter;
    imageTagLabel.font = UnenableTitleFont;
    imageTagLabel.textColor = WhiteColor;
    imageTagLabel.backgroundColor = OrangeColor;
    [self.leftImageView addSubview:imageTagLabel];
    self.imageTagLabel = imageTagLabel;
    
    UILabel *title = [[UILabel alloc] init];
    title.font = TitleFont;
    title.textColor = TitleColor;
    [self.contentView addSubview:title];
    self.title = title;
    
    UILabel *subTitle = [[UILabel alloc] init];
    subTitle.font = UnenableTitleFont;
    subTitle.textColor = SubTitleColor;
    subTitle.numberOfLines = 2;
    [self.contentView addSubview:subTitle];
    self.subTitle = subTitle;
    
    YYTagView *tag1 = [[YYTagView alloc] init];
    tag1.rightMargin = YYInfoCellSubMargin;
    [self.contentView addSubview:tag1];
    self.tag1 = tag1;
    
    UILabel *hits = [[UILabel alloc] init];
    hits.font = UnenableTitleFont;
    hits.textColor = UnenableTitleColor;
    [self.contentView addSubview:hits];
    self.hits = hits;
    
    UIButton *connect = [UIButton buttonWithType:UIButtonTypeCustom];
    connect.titleLabel.font = SubTitleFont;
    [connect setBackgroundColor:OrangeColor];
    [connect setTitleColor:WhiteColor forState:UIControlStateNormal];
    connect.layer.cornerRadius = 2;
    [self.contentView addSubview:connect];
    self.connect = connect;
    
}

- (void)masonrySubView {
    
    [self.leftImageView makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.offset(YYCommonCellLeftMargin);
        make.width.equalTo(100);
        make.height.equalTo(80);
    }];
    
    [self.imageTagLabel makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.equalTo(self.leftImageView);
        make.width.equalTo(15);
    }];
    
    [self.title makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.leftImageView);
        make.right.equalTo(-YYCommonCellRightMargin);
        make.left.equalTo(self.leftImageView.right).offset(YYInfoCellCommonMargin);
    }];
    
    [self.subTitle makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.title.bottom).offset(3);
        make.right.equalTo(-YYCommonCellRightMargin);
        make.left.equalTo(self.title);
    }];
    
    [self.tag1 makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.leftImageView);
        make.left.equalTo(self.leftImageView.right).offset(YYInfoCellCommonMargin);
    }];
    
    [self.hits makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.tag1.right).offset(YYInfoCellSubMargin);
        make.centerY.equalTo(self.tag1);
    }];
    
    [self.connect makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.offset(-YYCommonCellRightMargin);
        make.bottom.equalTo(self.leftImageView);
        make.width.equalTo(70);
        make.height.equalTo(25);
    }];
    
}



- (void)setProjectModel:(YYProjectModel *)projectModel {
    
    _projectModel = projectModel;
    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:projectModel.picurl] placeholderImage:imageNamed(@"placeholder")];
    if (projectModel.label.length) {
        self.imageTagLabel.hidden = NO;
        self.imageTagLabel.text = projectModel.label;
    }else {
        self.imageTagLabel.hidden = YES;
    }
    self.title.text = projectModel.title;
    self.subTitle.text = projectModel.desc;
    
    self.tag1.title = projectModel.auth_tag;
//    if (![projectModel.auth_tag isEqualToString:@""]) {
//
//    }else {
//
//    }
    [self.tag1 setNeedsLayout];
    self.hits.text = projectModel.hits;
    [self.connect setTitle:@"在线咨询" forState:UIControlStateNormal];
    
}


@end
