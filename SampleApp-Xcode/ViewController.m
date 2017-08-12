//
//  ViewController.m
//  SampleApp-Xcode
//
//  Created by Luu Lanh on 11/11/15.
//  Copyright © 2015 LuuLanh. All rights reserved.
//

#import "ViewController.h"
#import "MoMoPaySDK.h"

//SDK v.2.2
#import "MoMoDialogs.h"


@interface ViewController ()
{
    UILabel *lblMessage;
    UILocalNotification *noti;
    UITextField *txtAmount;
    
    //SDK v2.2
    MoMoDialogs *dialog;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NoficationCenterTokenReceived:) name:@"NoficationCenterTokenReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NoficationCenterCreateOrderReceived:) name:@"NoficationCenterCreateOrderReceived" object:nil];
    
    //SDK v.2.2
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NoficationCenterTokenStartRequest:) name:@"NoficationCenterTokenStartRequest" object:nil];
    ///
    [self buildLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    lblMessage.text = @"{MoMo Response}";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSString*) stringForCStr:(const char *) cstr{
    if(cstr){
        return [NSString stringWithCString: cstr encoding: NSUTF8StringEncoding];
    }
    return @"";
}

-(NSMutableDictionary*) getDictionaryFromComponents:(NSArray *)components{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // parse parameters to dictionary
    for (NSString *param in components) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        // get key, value
        NSString* key   = [elts objectAtIndex:0];
        key = [key stringByReplacingOccurrencesOfString:@"?" withString:@""];
        NSString* value = [elts objectAtIndex:1];
        
        ///Start Fix HTML Property issue
        if ([elts count]>2) {
            @try {
                value = [param substringFromIndex:([param rangeOfString:@"="].location+1)];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        ///End HTML Property issue
        if(value){
            value = [self stringForCStr:[value UTF8String]];
        }
        
        //
        if(key.length && value.length){
            [params setObject:value forKey:key];
        }
    }
    return params;
}


-(void)NoficationCenterCreateOrderReceived:(NSNotification*)notif
{
    //Payment Order Replied
//    NSString *responseString = [[NSString alloc] initWithData:[notif.object dataUsingEncoding:NSUTF8StringEncoding] encoding:NSUTF8StringEncoding];
//    
    NSLog(@"::MoMoPay Log::Request Payment Replied::%@",notif.object);
    lblMessage.text = [NSString stringWithFormat:@"Result: %@",notif.object];
    if ([notif.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *response = [[NSDictionary alloc] initWithDictionary:notif.object];
        
        int status = -1;
        @try {
            
        }
        @catch (NSException *exception) {
            status= [[response objectForKey:@"status"] intValue];
        }
        @finally {
            
        }
        
        if (status==0) {
            NSLog(@"::MoMoPay Log::Payment Success");
        }
        else
        {
            NSLog(@"::MoMoPay Log::Payment Error::%@",[response objectForKey:@"message"]);
        }
        lblMessage.text = [NSString stringWithFormat:@"%@:%@",[response objectForKey:@"status"],[response objectForKey:@"message"]];
        //continue your checkout order here
    }
}


-(void)NoficationCenterTokenReceived:(NSNotification*)notif
{
    if (dialog) {
        [dialog dismissViewControllerAnimated:YES completion:nil];
    }

    //Token Replied
    NSLog(@"::MoMoPay Log::Received Token Replied::%@",notif.object);
    lblMessage.text = [NSString stringWithFormat:@"%@",notif.object];
    
    NSString *sourceText = [notif.object stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"com.mservice.com.vn.MoMoTransfer://?"] withString:@""];
    
    ///fix UT8 String
    //sourceText = [sourceText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ////end fix UTF8 string
    
    //NSLog(@">>Parram %@",sourceText);
    
    NSArray *components = [sourceText componentsSeparatedByString:@"&"];
    
    NSDictionary *response = [self getDictionaryFromComponents:components];//(NSDictionary*)notif.object;
    NSString *status = [NSString stringWithFormat:@"%@",[response objectForKey:@"status"]];
    NSString *message = [NSString stringWithFormat:@"%@",[response objectForKey:@"message"]];
    if ([status isEqualToString:@"0"]) {
        
        NSLog(@"::MoMoPay Log: SUCESS TOKEN.");
        NSLog(@">>response::%@",notif.object);
        
        NSString *data = [NSString stringWithFormat:@"%@",[response objectForKey:@"data"]];
        NSString *phoneNumber =  [NSString stringWithFormat:@"%@",[response objectForKey:@"phonenumber"]];
        
        NSString *env = @"app";
        if (response[@"env"]) {
            env =  [NSString stringWithFormat:@"%@",[response objectForKey:@"env"]];
        }
        
        if (response[@"extra"] && [sourceText hasPrefix:@"https://payment.momo.vn/callbacksdk"]) {
            //Decode base 64 for using
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:response[@"extra"] options:0];
            extra = [[[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        lblMessage.text = [NSString stringWithFormat:@">>response:: SUCESS TOKEN. \n %@",notif.object];
        
        /*  SEND THESE PARRAM TO SERVER:  phoneNumber, data, env   */
        
    }else
    {
        if ([status isEqualToString:@"1"]) {
            NSLog(@"::MoMoPay Log: REGISTER_PHONE_NUMBER_REQUIRE.");
        }
        else if ([status isEqualToString:@"2"]) {
            NSLog(@"::MoMoPay Log: LOGIN_REQUIRE.");
        }
        else if ([status isEqualToString:@"3"]) {
            NSLog(@"::MoMoPay Log: NO_WALLET. You need to cashin to MoMo Wallet ");
        }
        else
        {
            NSLog(@"::MoMoPay Log: %@",message);
        }
    }
    
}

/*
 //SDK v.2.2
 //Dated: 7/25/17.
 */
-(void)NoficationCenterTokenStartRequest:(NSNotification*)notif
{
    if (notif.object != nil && [notif.object isEqualToString:@"MoMoWebDialogs"]) {
        dialog = [[MoMoDialogs alloc] init];
        [self presentViewController:dialog animated:YES completion:nil];
    }
}
-(void)buildLayout{
    //Code của bạn
    UIView *paymentArea = [[UIView alloc] initWithFrame:CGRectMake(20, 100, 300, 300)];
    [paymentArea setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *imgMoMo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [imgMoMo setImage:[UIImage imageNamed:@"momo.png"]];
    [paymentArea addSubview:imgMoMo];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 30)];
    lbl.text = @"DEVELOPMENT ENVIRONMENT";
    lbl.font = [UIFont systemFontOfSize:13];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [paymentArea addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 200, 30)];
    lbl.text = @"Pay by MoMo Wallet";
    lbl.font = [UIFont systemFontOfSize:13];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [paymentArea addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 30)];
    lbl.text = @"Amount";
    lbl.font = [UIFont systemFontOfSize:13];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [paymentArea addSubview:lbl];
    
    UIButton *btnPay = [[UIButton alloc] initWithFrame:CGRectMake(200, 60, 100, 30)];
    //    btnPay.titleLabel.text = @"Submit";
    [btnPay setTitle:@"Submit" forState:UIControlStateNormal];
    [btnPay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    //    [btnPay addTarget:self action:@"" forControlEvents:UIControlEventTouchUpInside];
    btnPay.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnPay setBackgroundColor:[UIColor blueColor]];
    //    [paymentArea addSubview:btnPay];
    
    txtAmount = [[UITextField alloc] initWithFrame:CGRectMake(60, 60, 100, 30)];
    txtAmount.text = @"59000";
    txtAmount.delegate = self;
    txtAmount.enabled = NO;
    txtAmount.placeholder = @"Enter amount...";
    txtAmount.font = [UIFont systemFontOfSize:14];
    [txtAmount setBackgroundColor:[UIColor lightGrayColor]];
    [paymentArea addSubview:txtAmount];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(60, 85, 100, 1)];
    [line setBackgroundColor:[UIColor grayColor]];
    [paymentArea addSubview:line];
    
    lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(60, 90, 300, 200)];
    lblMessage.text = @"{MoMo Response}";
    lblMessage.font = [UIFont systemFontOfSize:15];
    [lblMessage setBackgroundColor:[UIColor clearColor]];
    lblMessage.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    lblMessage.numberOfLines = 0;
    [paymentArea addSubview:lblMessage];
    
    //Tạo button Thanh toán bằng Ví MoMo
    
    NSString *username = [NSString stringWithFormat:@"username_accountId@yahoo.com"];//Tai khoan dang login de thuc hien giao dich nay (khong bat buoc)
    
    //Buoc 1: Khoi tao Payment info, add button MoMoPay
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd-hhmmssss"];
    
    NSString *extradata = @"{\"site_code\":\"008\",\"site_name\":\"CGV Cresent Mall\",\"screen_code\":0,\"screen_name\":\"Special\",\"movie_name\":\"Kẻ Trộm Mặt Trăng 3\",\"movie_format\":\"2D\",\"ticket\":{\"01\":{\"type\":\"std\",\"price\":110000,\"qty\":3}}}";
    
    NSMutableDictionary *paymentinfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"CGV19072017"],@"partnerCode",
                                        @"mua vé xem phim cgv",@"description",
                                        [NSNumber numberWithInt:59000],@"amount",
                                        [NSNumber numberWithInt:0],@"fee",
                                        extradata,@"extra",
                                        @"vi",@"language",
                                        username,@"username",
                                        @"4234234234234234",@"billid",
                                        @"4234234234234234",@"transid",
                                        nil];
    [[MoMoPayment shareInstant] setMoMoAppScheme:@"com.momo.appv2.ios"];//Development schema com.momo.appv2.ios , Production scheme com.mservice.com.vn.MoMoTransfer
    [[MoMoPayment shareInstant] setSubmitURL:@"http://118.69.187.119:9090/sdk/api/v1/payment/request"];
    [[MoMoPayment shareInstant] createPaymentInformation:paymentinfo];
    
    //Buoc 2: add button Thanh toan bang Vi MoMo vao khu vuc ban can hien thi (Vi du o day la vung paymentArea)
    ///Default MoMo Button [[MoMoPayment shareInstant] addMoMoPayDefaultButtonToView:paymentArea];
    
    ///Custom button
    [[MoMoPayment shareInstant] addMoMoPayCustomButton:btnPay forControlEvents:UIControlEventTouchUpInside toView:paymentArea];
    
    //Code của bạn
    [self.view addSubview:paymentArea];
    
}
@end
