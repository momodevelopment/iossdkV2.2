# MoMo Android SDK

At a minimum, MoMo SDK is designed to work with iOS 8.0 or newest.


## Installation

To use the MoMo iOS SDK, Import MoMoPaySDK framework into your project
Include: MoMoConfig, MoMoDialogs, MoMoPayment

Step 1. Config file Plist
```
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string></string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.abcFoody.LuckyLuck</string>
    </array>
  </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>com.momo.appv2.ios</string>
</array>
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```
Step 2. Import SDK
AppDelegate instance
```
#import "MoMoPayment.h"

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [[MoMoPayment shareInstant] handleOpenUrl:url];
    return YES;
}
```

Step 3. Update Layout Payment
```
#import "MoMoPayment.h"
#import "MoMoDialogs.h"
```

NSNotificationCenter registration

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NoficationCenterTokenReceived:) name:@"NoficationCenterTokenReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NoficationCenterTokenStartRequest:) name:@"NoficationCenterTokenStartRequest" object:nil];
    ///
    [self updateLayout];
}
-(void)processMoMoNoficationCenterTokenReceived:(NSNotification*)notif{

}
-(void)NoficationCenterTokenStartRequest:(NSNotification*)notif
{
    if (notif.object != nil && [notif.object isEqualToString:@"MoMoWebDialogs"]) {
        dialog = [[MoMoDialogs alloc] init];
        [self presentViewController:dialog animated:YES completion:nil];
    }
}
```
Add Button Action to Pay Via MOMO
Button title: EN = MoMo Wallet , VI = Ví MoMo
```
-(void)updateLayout{
    //STEP 1: INIT ORDER INFO
    NSMutableDictionary *paymentinfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            [NSNumber numberWithInt:10000],@"amount",
                                            [NSNumber numberWithInt:0],@"fee",
                                            @"Buy CGV Cinemas",@"description",
                                            @"{\"key1\":\"value1\",\"key2\":\"value2\"}",@"extra", //OPTIONAL
                                            @"vi",@"language",
                                            username,@"username",
                                            @"Người dùng",@"usernamelabel",
                                            nil];
    [[MoMoPayment shareInstant] initPaymentInformation:paymentinfo momoAppScheme:@"com.mservice.com.vn.MoMoTransfer" environment:MOMO_SDK_PRODUCTION];

    //STEP 2: ADD BUTTON ACTION TO PAY VIA MOMO WALLET
    [[MoMoPayment shareInstant] addMoMoPayCustomButton:buttonMoMo forControlEvents:UIControlEventTouchUpInside toView:yourPaymentView];

}
```
