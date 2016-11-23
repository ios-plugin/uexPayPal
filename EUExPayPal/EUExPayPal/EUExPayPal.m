//
//  EUExPayPal.m
//  EUExPayPal
//
//  Created by ertf on 16/4/18.
//  Copyright © 2016年 ertf. All rights reserved.
//

#import "EUExPayPal.h"
#import "EUtility.h"
@implementation EUExPayPal

-(void)init:(NSMutableArray*)inArguments{
    if(inArguments.count<1){
        return;
    }
    ACArgsUnpack(NSDictionary*info) = inArguments;
    NSString *mode= [info objectForKey:@"mode"]?:@"production";
    NSString * clientId = [info objectForKey:@"clientId"];//my-client-id-for-Production or my-client-id-for-Sandbox
    
    
    self.environment = PayPalEnvironmentNoNetwork;
    if ([mode isEqualToString:@"production"]) {
        self.environment = PayPalEnvironmentProduction;
         [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction:clientId}];
    }
    if ([mode isEqualToString:@"sandbox"]) {
        self.environment = PayPalEnvironmentSandbox;
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox:clientId}];
    }
    if ([mode isEqualToString:@"noNetwork"]) {
        self.environment = PayPalEnvironmentNoNetwork;
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",PayPalEnvironmentSandbox:@"YOUR_CLIENT_ID_FOR_SANDBOX"}];
    }
    
    _payPalConfig = [[PayPalConfiguration alloc] init];
#if HAS_CARDIO
    _payPalConfig.acceptCreditCards = YES;
#else
    _payPalConfig.acceptCreditCards = NO;// NO, the SDK will only support paying with PayPal, not with credit cards.
#endif
    [PayPalMobile preconnectWithEnvironment:self.environment];
    NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
}
-(void)pay:(NSMutableArray*)inArguments{
    if(inArguments.count<1){
        return;
    }
    ACArgsUnpack(NSDictionary*info,ACJSFunctionRef *func) = inArguments;
    self.fuct = func;
   
    NSString *currency= [info objectForKey:@"currency"];
    NSString *itemDesc = [info objectForKey:@"desc"];
    NSString *total = [NSString stringWithFormat:@"%@",[info objectForKey:@"amount"]];
    NSDecimalNumber *amount = [[NSDecimalNumber alloc] initWithString:total];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = amount;
    payment.currencyCode = currency;
    payment.shortDescription = itemDesc;
    payment.items = nil;
    payment.paymentDetails = nil;
    if (!payment.processable) {
        return;
    }
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                configuration:self.payPalConfig delegate:self];
    
    [[self.webViewEngine viewController] presentViewController:paymentViewController animated:YES completion:nil];
   
  


}
#pragma mark PayPalPaymentDelegate methods
const static NSString *kPluginName=@"uexPayPal";
- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
    [self.fuct executeWithArguments:ACArgsPack(@(0),completedPayment.confirmation)];
    [[self.webViewEngine viewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    if (paymentViewController.state == 0) {
        [[self.webViewEngine viewController] dismissViewControllerAnimated:YES completion:nil];
    }
    [self.fuct executeWithArguments:ACArgsPack(@(1),paymentViewController.state == 0?@"cancel":@"processing")];
}
@end
