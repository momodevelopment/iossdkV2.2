//
//  MoMoPayment.h
//  SampleApp-Xcode
//
//  Created by Luu Lanh on 9/30/15.
//  Copyright (c) 2015 LuuLanh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MoMoPayment : NSObject
+(MoMoPayment*)shareInstant;
- (void)initializingAppBundleId:(NSString*)bundleid merchantId:(NSString*)merchantId merchantName:(NSString*)merchantname merchantNameTitle:(NSString*)merchantNameTitle billTitle:(NSString*)billTitle;
-(void)requestPayment:(NSMutableDictionary*)parram;
-(void)requestToken;
-(void)handleOpenUrl:(NSURL*)url;
-(void)createPaymentInformation:(NSMutableDictionary*)info;
-(void)addMoMoPayDefaultButtonToView:(UIView*)parrentView;
-(UIButton*)addMoMoPayCustomButton:(UIButton*)button forControlEvents:(UIControlEvents)controlEvents toView:(UIView*)parrentView;
-(NSString*)getAction;
-(void)setAction:(NSString*)action;
-(void)updateAmount:(long long)amt;
/*
 //SDK v.2.2
 //Dated: 7/25/17.
 */
-(void)setSubmitURL:(NSString*)submitUrl;
-(NSMutableDictionary*)getPaymentInfo;
-(void)requestWebpaymentData:(NSMutableDictionary*)dataPost requestType:(NSString*)requesttype;
-(NSString*)getDeviceInfoString;
-(void)setMoMoAppScheme:(NSString*)bundleId;
@end
