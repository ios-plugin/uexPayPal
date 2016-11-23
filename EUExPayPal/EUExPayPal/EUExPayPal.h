//
//  EUExPayPal.h
//  EUExPayPal
//
//  Created by ertf on 16/4/18.
//  Copyright © 2016年 ertf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppCanKit/AppCanKit.h>
#import "PayPalMobile.h"

@interface EUExPayPal : EUExBase <PayPalPaymentDelegate>
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic,strong)ACJSFunctionRef *fuct;
@end
