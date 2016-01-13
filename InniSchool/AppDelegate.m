//
//  AppDelegate.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 27..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//
//???
#import "AppDelegate.h"
#import "LeftSideMenuViewController.h"
#import "pushcat.h"
#import "SBJson.h"
#import "Update.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "GreenTubeViewController.h"
//#import "ActionSheetStringPicker.h"
#import "iToast.h"

static NSString *const kTrackingId = @"UA-38498709-1";
static NSString *const kAllowTracking = @"allowTracking";

@interface AppDelegate ()
@property (nonatomic, strong) UIViewController *vc_LeftMenu;
@property (nonatomic, strong) UINavigationController *mainNavi;
@property (nonatomic, strong) UINavigationController *loginNavi;
@property(nonatomic, assign) BOOL okToWait;
@property(nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSArray *colors = [NSArray arrayWithObjects:@"Red", @"Green", @"Blue", @"Orange", nil];
//    
//    [ActionSheetStringPicker showPickerWithTitle:@"Select a Color"
//                                            rows:colors
//                                initialSelection:0
//                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//                                           NSLog(@"Picker: %@", picker);
//                                           NSLog(@"Selected Index: %@", selectedIndex);
//                                           NSLog(@"Selected Value: %@", selectedValue);
//                                       }
//                                     cancelBlock:^(ActionSheetStringPicker *picker) {
//                                         NSLog(@"Block Picker Canceled");
//                                     }
//                                          origin:self.window];

    
    
    
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

#if TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults] setObject:@"a092f3aad2d92a4d3749de6189b13df99242c04809441f7715727bd9ee85d445" forKey:@"Token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#else
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge |
                                                                                             UIRemoteNotificationTypeSound |
                                                                                             UIRemoteNotificationTypeAlert)
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
#endif
    
    
    if( ![[NSUserDefaults standardUserDefaults] valueForKey:@"FirstBoot"] )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"PushOnOff"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"AutoLogin"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"IsLogin"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"ShowConfirm"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"FirstBoot"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    NSDictionary *dic_UserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if( dic_UserInfo != nil )
    {
        [self showPushPage:dic_UserInfo];
    }

    
    
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    
    self.mainNavi = [storyboard instantiateViewControllerWithIdentifier:@"MainNavi"];
    [Util setMainNaviBar:self.mainNavi.navigationBar];
    
    self.loginNavi = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavi"];
    [Util setLoginNaviBar:self.loginNavi.navigationBar];
    
    self.vc_LeftMenu = [storyboard instantiateViewControllerWithIdentifier:@"LeftSideMenuViewController"];
    
    
    //구글아날리틱스 초기화
    [self initializeGoogleAnalytics];
    
    [self initViewControllers];
    
    [[WebAPI sharedData] getAppStoreInfo:^(id resulte, NSError *error) {
        
        if( resulte )
        {
            NSString *str_Ver = @"";
            NSArray *ar = [resulte objectForKey:@"results"];
            for( NSInteger i = 0; i < ar.count; i++ )
            {
                NSDictionary *dic = ar[i];
                str_Ver = [dic objectForKey:@"version"];
                if( str_Ver != nil && str_Ver.length > 0 )
                {
                    break;
                }
            }
            
            CGFloat appStoreVersion = [str_Ver floatValue];
//            CGFloat currentVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] floatValue]; //이건 빌드버전을 가져옴..
            CGFloat currentVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue]; //이게 진짜 버전임

            if( appStoreVersion > currentVersion )
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"Update" owner:self options:nil];
                Update *v_Update = [topLevelObjects objectAtIndex:0];
                [self.window addSubview:v_Update];
                
//                UIAlertView *alert = CREATE_ALERT(nil, @"최신 버전이 출시되었습니다.\n업데이트 후 사용해 주세요.", @"닫기", @"업데이트");
//                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                    
//                    if( buttonIndex == 1 )
//                    {
//                        NSURL *appStoreURL = [NSURL URLWithString:kAppStoreURL];
//                        [[UIApplication sharedApplication] openURL:appStoreURL];
//                    }
//                }];
            }
        }
    }];

    
    // Override point for customization after application launch.
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //    NSString *msg = [NSString stringWithFormat:@"%@://%@ (%@)", [url scheme], [url query], sourceApplication];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
//    Inf_KakaoCenter *kakao = [Inf_KakaoCenter sharedInfKakao];
//    [kakao parseUrlFromKakao:url];
//    if (kakao.key && [kakao.key isEqualToString:@"greentube"]) {
//        [[Inf_MainViewCtrl mainPage] goPageType:GPT_GREEN_TUBE goSubPageType:GSPT_NONE withData:nil];
//    }
    
    NSLog(@"application openURL:(%@) sourceApplication:(%@) annotation:(%@)", url, sourceApplication, annotation);
    
    if ([KOSession isKakaoLinkCallback:url])
    {
        NSString *str_Query = [url query];
        NSArray *ar = [str_Query componentsSeparatedByString:@"="];
        if( ar.count > 1 )
        {
            NSString *str_GreenTubeIdx = ar[1];
            NSLog(@"%@", str_GreenTubeIdx);
            
            //그린튜브 디테일 페이지로 이동
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"GreenTubeNavi"];
            GreenTubeViewController *vc = (GreenTubeViewController *)[navi.viewControllers firstObject];
            vc.str_DetailIdx = str_GreenTubeIdx;
            [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
        }
        
        return YES;
    }

    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self sendHitsInBackground];
    completionHandler(UIBackgroundFetchResultNewData);
}

// We'll try to dispatch any hits queued for dispatch as the app goes into the background.
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self sendHitsInBackground];
}

// This method sends hits in the background until either we're told to stop background processing,
// we run into an error, or we run out of hits.  We use this to send any pending Google Analytics
// data since the app won't get a chance once it's in the background.
- (void)sendHitsInBackground
{
    self.okToWait = YES;
    __weak AppDelegate *weakSelf = self;
    __block UIBackgroundTaskIdentifier backgroundTaskId =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        weakSelf.okToWait = NO;
    }];
    
    if (backgroundTaskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    self.dispatchHandler = ^(GAIDispatchResult result) {
        // If the last dispatch succeeded, and we're still OK to stay in the background then kick off
        // again.
        if (result == kGAIDispatchGood && weakSelf.okToWait ) {
            [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    };
    [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)initializeGoogleAnalytics
{
//    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
//    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
//    // User must be able to opt out of tracking
//    [GAI sharedInstance].optOut =
//    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
//    // Initialize Google Analytics with a 120-second dispatch interval. There is a
//    // tradeoff between battery usage and timely dispatch.
//    [GAI sharedInstance].dispatchInterval = 120;
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
//    self.tracker = [[GAI sharedInstance] trackerWithName:@"InniSchool"
//                                              trackingId:kTrackingId];
    
    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    
    // If your app runs for long periods of time in the foreground, you might consider turning
    // on periodic dispatching.  This app doesn't, so it'll dispatch all traffic when it goes
    // into the background instead.  If you wish to dispatch periodically, we recommend a 120
    // second dispatch interval.
    // [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].dispatchInterval = -1;
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithName:@"InniSchool"
                                              trackingId:kTrackingId];
}


- (void)initViewControllers
{
    BOOL isAutoLogin = [[[NSUserDefaults standardUserDefaults] valueForKey:@"AutoLogin"] boolValue];
    if( !isAutoLogin )
    {
        //오토로그인이 아니면 무조건 로그인창 틀기
        [self showLoginView];
    }
    else
    {
        //로그인 유무에 따른 분기처리
        BOOL isLogin = [[[NSUserDefaults standardUserDefaults] valueForKey:@"IsLogin"] boolValue];
        if( isLogin )
        {
            //오토 로그인 상태이고 로그인된 상태면
            [self showMainView];
        }
        else
        {
            //로그인화면 틀기
            [self showLoginView];
        }
    }
}

- (void)showLoginView
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.sideMenuViewController setMainViewController:self.loginNavi animated:YES closeMenu:YES];
}

- (void)showMainView
{
    //메인뷰 띄우기전에 로그인 API 태우는 로직

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"userId"] forKey:@"userId"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"userPw"] forKey:@"userPass"];
    [dicM_Params setObject:@"644" forKey:@"accessDevice"];  //644는 iOS
    [dicM_Params setObject:[Util getIPAddress] forKey:@"accessIp"];
    
    [[WebAPI sharedData] callSyncWebAPIBlock:@"member/selectLoginCheck.do"
                                       param:dicM_Params
                                   withBlock:^(id resulte, NSError *error) {
                                       
                                       if( resulte )
                                       {
                                           NSDictionary *dic = [NSDictionary dictionaryWithDictionary:resulte];
                                           NSDictionary *dic_Info = [dic objectForKey:@"UserInfo"];
                                           NSDictionary *dic_Check = [dic_Info objectForKey:@"LoginCheckResult"];
                                           NSInteger nResultCode = [[dic_Check objectForKey:@"LoginCheckResultCode"] integerValue];
                                           NSLog(@"nResultCode : %@", [dic_Check objectForKey:@"LoginCheckResultCode"]);
                                           if( nResultCode == 1 )
                                           {
                                               NSDictionary *dic_Detail = [dic_Info objectForKey:@"UserInfoDetail"];

                                               //1이면 성공
                                               [[NSUserDefaults standardUserDefaults] setObject:[dic_Check objectForKey_YM:@"UserIdx"] forKey:@"userIdx"];
                                               [[NSUserDefaults standardUserDefaults] setObject:[dic_Detail objectForKey_YM:@"ComBraRIdx"] forKey:@"comBraRIdx"];
                                               [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsLogin"];
                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                               
                                               //싱글턴에 유저정보 저장
                                               [UserData sharedData].dicM_UserInfo = [NSMutableDictionary dictionaryWithDictionary:[dic_Info objectForKey:@"UserInfoDetail"]];
                                               
                                               [self showOnlyMainView];
                                           }
                                           else if( nResultCode == 7 )
                                           {
                                               ALERT_ONE(@"이용정지된 아이디 입니다");
                                               [self showLoginView];
                                           }
                                           else if( nResultCode == 8 )
                                           {
                                               ALERT_ONE(@"퇴사처리된 아이디 입니다");
                                               [self showLoginView];
                                           }
                                           else
                                           {
                                               //0이면 실패
                                               ALERT_ONE(@"로그인 정보가 잘못되었습니다");
                                               [self showLoginView];
                                           }
                                       }
                                   }];
}

//통신 빼고 메인뷰만 띄우기
- (void)showOnlyMainView
{
    //메인네비에 있는 메인뷰컨트롤러를 제외한 기존 뷰컨트롤러들을 날려준다
    NSMutableArray *arM = [NSMutableArray arrayWithArray:self.mainNavi.viewControllers];
    for( NSInteger i = 1; i < arM.count; i++ )
    {
        [arM removeObjectAtIndex:i];
    }
    self.mainNavi.viewControllers = [NSMutableArray arrayWithArray:arM];
    /////////////////
    
    
    self.sideMenuViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.vc_LeftMenu
                                                                             mainViewController:self.mainNavi];
    self.sideMenuViewController.shadowColor = [UIColor blackColor];
    self.sideMenuViewController.edgeOffset = (UIOffset){90, 0};//(UIOffset) { .horizontal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 18.0f : 0.0f };
    self.sideMenuViewController.zoomScale = 1;// UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.5634f : 0.85f;
    self.sideMenuViewController.delegate = self;
    self.window.rootViewController = self.sideMenuViewController;
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    /***********************************************************/
    NSString *str_Token = [[NSUserDefaults standardUserDefaults] valueForKey:@"Token"];
    NSString *str_UserId = [[NSUserDefaults standardUserDefaults] valueForKey:@"userId"];
    [[Pushcat get] registerPushcatWithTag:str_UserId Token:str_Token];
    /***********************************************************/
    
    
    BOOL isShowConfirm = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowConfirm"] boolValue];
    if( isShowConfirm )
    {
        NSString *str_Contents = @"앱 이용에 적합하지 않은 컨텐츠를 등록 하실 경우 게시자의 동의 없이 관리자에 의해 삭제 될 수 있음을 알려 드립니다.";
        
        UIAlertView *alert = CREATE_ALERT(nil, str_Contents, @"확인", nil);
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"ShowConfirm"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
    }
}
#pragma mark - TWTSideMenuViewControllerDelegate
- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sender {
    NSLog(@"willOpenMenu");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WillOpenMenu" object:nil userInfo:nil];
}

- (void)sideMenuViewControllerDidOpenMenu:(TWTSideMenuViewController *)sender {
    NSLog(@"didOpenMenu");
}

- (void)sideMenuViewControllerWillCloseMenu:(TWTSideMenuViewController *)sender {
    NSLog(@"willCloseMenu");
}

- (void)sideMenuViewControllerDidCloseMenu:(TWTSideMenuViewController *)sender {
    NSLog(@"didCloseMenu");
}


#pragma mark -
#pragma mark APNS Method
//iOS8 때문에 이 메소드 추가해 줘야 함 (ㅅㅂ -_-)
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types == UIUserNotificationTypeNone)
    {
        //푸쉬 허용 안함
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"PushOnOff"];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        //        [self initViewControllers];
    }
    else
    {
        //푸쉬 허용 함
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"PushOnOff"];
        [application registerForRemoteNotifications];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//APNS에 장치 등록 성공시 호출되는 콜백
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    
    for(NSInteger i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    
    NSLog(@"Token : %@", deviceId);
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"Token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//APNS에 장치 등록 실패시 호출되는 콜백
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"PushOnOff"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"deviceToken error : %@", error);
    
    [[NSUserDefaults standardUserDefaults] setObject:@"2c691a9f63bc901ac6631e796f134d79dd7c5bf6b44f9c10bbdda05144c918de" forKey:@"Token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //    [self initViewControllers];
}

//어플 실행중에 알림도착
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self showPushPage:userInfo];
    
    
    //중요!!!!!!!!!!!!!!
    //푸쉬캣을 쓸때는 서버 도메인과 호스트를 바꿔줘야 함
    //!!!!!!!!!!!!!!!!!!!
    
    
    
    
    
    /*
     imgUrl : 이미지 URL
     title : 푸쉬 제목
     link : 푸쉬 터치시 이동할 경로
     link_idx : 이동할 경로 인덱스
     push_type : 푸쉬 타입
     msg : 푸쉬 내용
     
     
     
     
     
     
     
     push_type 값에 따른 푸쉬형태
     notice : 알림바
     popup : 팝업
     */
    
    
    
    //푸쉬켓 메소드인 recvContent 를 써서 푸쉬로 받은 타입을 한번 더 태운후 json리턴값을 받아서 화면이동처리를 한다.
    
    
    
    //    [self showPushPage:userInfo];
    
    
    
    
    //    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    //    //    NSLog(@"%@", [aps objectForKey:@"type"]);
    //
    //    UIAlertView *alert = CREATE_ALERT(nil, [aps objectForKey:@"alert"], @"확인", nil);
    //    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
    //
    ////        NSString *str_Url = [userInfo valueForKey:@"link"];
    ////
    ////        [[NSUserDefaults standardUserDefaults] setValue:str_Url forKey:@"Link"];
    ////        [[NSUserDefaults standardUserDefaults] synchronize];
    ////
    ////        if( str_Url != nil && str_Url.length > 0 )
    ////        {
    ////            [[NSNotificationCenter defaultCenter] postNotificationName:@"LinkNoti"
    ////                                                                object:nil
    ////                                                              userInfo:nil];
    ////        }
    //    }];
    
    //    [self showPushPage:userInfo];
}

- (void)showPushPage:(NSDictionary *)userInfo
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSString *str_TaskId = [userInfo valueForKey:@"task_id"];
    NSLog(@"%@", str_TaskId);
    
    NSString *str_Result = [[Pushcat get] recvContent:str_TaskId];
    NSString *str_EncResult = [str_Result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic_Result = [NSJSONSerialization JSONObjectWithData:[str_EncResult dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    /*
     dic_Result 결과
     imgUrl = "http://switter.theskinfood.com/front/file_upload/20150310094559.jpg";
     link = 0;
     "link_idx" = "";
     msg = 2;
     "push_type" = notice;
     tag = support00;
     title = 1;
     */
    NSLog(@"%@", dic_Result);
    
    if( [[dic_Result objectForKey_YM:@"push_type"] isEqualToString:@"notice"] )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        //일반푸쉬
        NSInteger nLinkIdx = [[dic_Result objectForKey_YM:@"link"] integerValue];
        switch (nLinkIdx)
        {
            case 0:
                //메인
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *mainNavi = [storyboard instantiateViewControllerWithIdentifier:@"MainNavi"];
                        [Util setMainNaviBar:mainNavi.navigationBar];
                        [self.sideMenuViewController setMainViewController:mainNavi animated:YES closeMenu:YES];
                    }
                }];
            }
                break;

            case 1:
                //이달의 강의
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"StudyNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                break;
                
            case 2:
                //학습 자료실
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"StudyLibNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;
                
            case 3:
                //그린튜브
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"GreenTubeNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;
                
            case 4:
                //그린위키
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"WikiNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;
                
            case 5:
                //지식창고
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"KnowInNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;

            case 6:
                //우리 함께해요
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"TogetherNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;

            case 7:
                //우리 공부해요
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"WeStudyNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;

            case 8:
                //문의사항
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"AskingNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;

            case 9:
                //공지사항
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"NotiNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;

            case 10:
                //마이 페이지
            {
                UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"이동", @"닫기");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"MyPageNavi"];
                        [self.sideMenuViewController setMainViewController:navi animated:YES closeMenu:YES];
                    }
                }];
            }
                
                break;
        }
    }
    else if( [[dic_Result objectForKey_YM:@"push_type"] isEqualToString:@"popup"] )
    {
        //팝업
        UIAlertView *alert = CREATE_ALERT([dic_Result valueForKey:@"title"], [dic_Result valueForKey:@"msg"], @"확인", nil);
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    }
}

@end
