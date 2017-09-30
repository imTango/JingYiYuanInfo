//
//  YYIAPTool.m
//  JingYiYuanInfo
//
//  Created by VINCENT on 2017/9/23.
//  Copyright © 2017年 北京京壹元资讯信息服务有限公司. All rights reserved.
//

#import "YYIAPTool.h"
#import "YYUser.h"

#import "NSString+Base64.h"

@implementation YYIAPTool

+ (void)buyProductByProductionId:(NSString *)productionId {
    
//    [SVProgressHUD showWithStatus:@"购买时请不要关闭应用..."];
    
    YYUser *user = [YYUser shareUser];
    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:productionId,@"productid",@"1",@"type",user.userid,USERID, nil];
    [YYHttpNetworkTool GETRequestWithUrlstring:preIapOrderUrl parameters:para success:^(id response) {
        
        if (response && ![response[@"state"] isEqualToString:@"0"]) {
            
            [self buyProduct:productionId];
            YYLog(@"生成预支付订单成功");
        }else {
            YYLog(@"生成预支付订单失败");
        }
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"支付失败，请稍后重试"];
        [SVProgressHUD dismissWithDelay:1];
    } showSuccessMsg:nil];
    
    
}

+ (void)buyProduct:(NSString *)productionId {
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    if(![IAPShare sharedHelper].iap) {
        // ProductID_diamond1 我这里是宏，产品id一般为你工程的 Bundle ID+数字
        // 我这里是6个内购的商品
        NSSet* dataSet = [[NSSet alloc] initWithObjects:productionId,nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    
    //yes为生产环境  no为沙盒测试模式
    // 客户端做收据校验有用  服务器做收据校验忽略...
    [IAPShare sharedHelper].iap.production = NO;
    
    
    // 请求商品信息
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         
         if(response.products.count > 0 ) {
             //取出第一件商品id
             SKProduct *product = response.products[0];
             
             [[IAPShare sharedHelper].iap buyProduct:product
                                        onCompletion:^(SKPaymentTransaction* trans){
                                            
                                            if(trans.error)
                                            {
                                                
                                                
                                                YYLog(@"Fail  ????  %@",[trans.error localizedDescription]);
                                                
                                            }else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                                                
                                                [self showAlertWithTitle:@"购买成功,内购同步可能较慢，请您耐心等待，如有问题，请致电客服"];
                                                // 这个 receipt 就是内购成功 苹果返回的收据
                                                NSData *receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                                                
                                                
                                                /******这里我将receipt base64加密，把加密的收据 和 产品id，一起发送到app服务器********/
#warning 等待后台提供传输加密文件的接口 验证支付结果
                                                NSString *receiptBase64 = [NSString base64StringFromData:receipt length:[receipt length]];
                                                //
                                                [self sendReceiptToServer:receiptBase64 paymentTransaction:trans];
                                                //                    [self sendCheckReceiptWithBase64:receiptBase64 productID:product.productIdentifier];
                                                /*******上面的sendCheckReceipt请求成功了，会返回用户购买的钻石数量*******/
                                                
                                                //客户端做收据验证 (不建议)
                                                //  [[IAPShare sharedHelper].iap checkReceipt:receipt onCompletion:^(NSString *response, NSError *error) {
                                                //   NSLog(@"购买验证---%@",response);
                                                //  }];
                                                
                                            }
                                            else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                                if (trans.error.code == SKErrorPaymentCancelled) {
                                                    [SVProgressHUD showErrorWithStatus:@"您取消了此次购买"];
                                                    
                                                    YYLog(@"SKErrorPaymentCancelled用户取消了购买");
                                                    
                                                }else if (trans.error.code == SKErrorClientInvalid) {
                                                    [SVProgressHUD showErrorWithStatus:@"设备未能发送购买请求"];
                                                    YYLog(@"SKErrorPaymentCancelled设备不允许内购买");
                                                    
                                                }else if (trans.error.code == SKErrorPaymentInvalid) {
                                                    [SVProgressHUD showErrorWithStatus:@""];
                                                    YYLog(@"SKErrorPaymentCancelled用户取消了购买");
                                                    
                                                }else if (trans.error.code == SKErrorPaymentNotAllowed) {
                                                    [SVProgressHUD showErrorWithStatus:@""];
                                                    YYLog(@"SKErrorPaymentCancelled设备未打开内购买权限");
                                                    
                                                }else if (trans.error.code == SKErrorStoreProductNotAvailable) {
                                                    [SVProgressHUD showErrorWithStatus:@""];
                                                    YYLog(@"SKErrorStoreProductNotAvailable产品失效");
                                                    
                                                }else{
                                                    [SVProgressHUD showErrorWithStatus:@""];
                                                    YYLog(@"SKErrorPaymentCancelled用户取消了购买");
                                                    
                                                }
                                                [SVProgressHUD dismissWithDelay:1];
                                            }
                                        }];
         }else{
             //  ..未获取到商品
             [self showAlertWithTitle:@"未获取到商品"];
         }
     }];
    
}


+ (void)showAlertWithTitle:(NSString *)title {
    
    [SVProgressHUD showInfoWithStatus:title];
    [SVProgressHUD dismissWithDelay:3];
    
}

//http://yyapp.1yuaninfo.com/app/application/apple_pay.php  name值apple_receipt

+ (void)sendReceiptToServer:(NSString *)base64Str paymentTransaction:(SKPaymentTransaction *)paymentTransaction {
    
    //先存储交易信息，等待后台返回的状态码，如果是是0，直接删除
    [[IAPShare sharedHelper].iap provideContentWithTransaction:paymentTransaction];
//    NSDictionary *para = [NSDictionary dictionaryWithObjectsAndKeys:base64Str,@"name", nil];
    
    [YYHttpNetworkTool POSTRequestWithUrlstring:IAPReceiptUrl parameters:@{@"apple_receipt":base64Str} success:^(id response) {
        
        if ([response[@"state"] isEqualToString:@"0"]) {
            YYLog(@"购买成功，并给后台同步返回成功验证");
//            [[SKPaymentQueue defaultQueue] finishTransaction:paymentTransaction];
        }
        YYLog(@"IAP收据验证%@",response);
    } failure:^(NSError *erro) {
//        [[SKPaymentQueue defaultQueue] finishTransaction:paymentTransaction];
        YYLog(@"error : %@",erro);
    } showSuccessMsg:nil];
    
}


@end
