//
//  Defines.h
//  Kizzl
//
//  Created by Kim Young-Min on 13. 5. 28..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIAlertView+NSCookbook.h"
#import "Util.h"
#import "Toast+UIView.h"
#import "WebAPI.h"
#import "UIViewController+YM.h"
#import "OHActionSheet.h"
#import "UIImageView+AFNetworking.h"
#import "GAI.h"
#import "AppDelegate.h"
#import "YmBaseViewController.h"
#import "UIImageView+AFNetworking.h"
#import <UIKit/UIKit.h>
#import "GMDCircleLoader.h"
#import "DoAlertView.h"
#import "UIColor+expanded.h"
#import "UINavigationBar+Addition.h"
#import "NSDictionary+Extend.h"
#import "Common.h"
#import "TWTSideMenuViewController.h"
#import "UserData.h"
#import "GTMNSString+HTML.h"
#import "ShowUserInfo.h"
#import "SVProgressHUD.h"

#define SYSTEM_VERSION                              ([[UIDevice currentDevice] systemVersion])
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)
//#define IS_IOS8_OR_ABOVE                            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
#define IS_IOS8_OR_ABOVE                            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define k1PxLineColor  [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1]


static const NSString *kAppStoreId = @"608161525";  //스킨푸드 앱스토어 아이디

static const NSInteger kTitleArrowTag = 88;
static const NSInteger kTitleButtonTag = 89;

//#define degreesToRadians(degrees) ((degrees)/180.0 * M_PI)
#define degreesToRadian(x) (M_PI * (x) / 180.0)

////구글 아날리틱스 아이디
//static NSString *const kTrackingId = @"UA-38498709-1";
//static NSString *const kAllowTracking = @"allowTracking";

static const NSInteger kNaviTitleTag = 5613;

#define NSEUCKREncoding (-2147481280)

//테섭
//#define kBaseUrl                    @"http://58.236.189.77:8198"  //테섭
//#define kBaseUrlHttps               @"http://58.236.189.77:8198"  //테섭

//실섭
#define kBaseUrl                @"http://innischool.com"  //실섭
#define kBaseUrlHttps                @"https://innischool.com"  //실섭

//#define kLocal                  @"http://112.216.0.179:8284"    //Local

//AppStoreUrl

#define kAppStoreURL            @"https://itunes.apple.com/kr/app/iniseukul/id608161525?mt=8"
#define kMarketURL              @""

//동영상 저장 저장경로
#define kFileSavePath              [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Log"]

//레티나 체크
#define IS_RETINA               ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

//iOS7 체크
#define IS_IOS7_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

//3.5인치 체크
#define IS_3_5Inch              ([UIScreen mainScreen].applicationFrame.size.height < 548.0f)

//4인치 체크
#define IS_4Inch                ([UIScreen mainScreen].applicationFrame.size.height == 568.0f)

//GCD
#define AsyncBlock(block)       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define SyncBlock(block)        dispatch_sync(dispatch_get_main_queue(), block)


#define ALERT(TITLE, MSG, DELEGATE, BTN_TITLE1, BTN_TITLE2){UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:TITLE message:MSG delegate:DELEGATE cancelButtonTitle:nil otherButtonTitles:BTN_TITLE1, BTN_TITLE2, nil];[alertView show];}

#define ALERT_ONE(MSG){UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:MSG delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];[alertView show];}

#define CREATE_ALERT(TITLE, MSG, BTN_TITLE1, BTN_TITLE2){[[UIAlertView alloc]initWithTitle:TITLE message:MSG delegate:nil cancelButtonTitle:nil otherButtonTitles:BTN_TITLE1, BTN_TITLE2, nil]}

#define BundleImage(IMAGE_NAME) [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:IMAGE_NAME]]


#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


#ifdef DEBUG
//#define NSLog(fmt, ...) NSLog((@"%s[Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define NSLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__)
#else
#define NSLog(...)
#endif


#ifndef popover_PopoverViewCompatibility_h
#define popover_PopoverViewCompatibility_h

#ifdef __IPHONE_6_0

#define UITextAlignmentCenter       NSTextAlignmentCenter
#define UITextAlignmentLeft         NSTextAlignmentLeft
#define UITextAlignmentRight        NSTextAlignmentRight
#define UILineBreakModeTailTruncation   NSLineBreakByTruncatingTail
#define UILineBreakModeMiddleTruncation NSLineBreakByTruncatingMiddle
#define UILineBreakModeWordWrap         NSLineBreakByWordWrapping

#endif

#endif

