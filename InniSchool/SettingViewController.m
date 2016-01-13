//
//  SettingViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
@property (nonatomic, weak) IBOutlet UISwitch *sw_Push;
@property (nonatomic, weak) IBOutlet UILabel *lb_Version;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"설정";
    
    [self initNavi];
    
    self.sw_Push.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushOnOff"] boolValue];
    self.lb_Version.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initNavi
{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"환경설정";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItemWithWhiteColor:YES];
}


#pragma mark - IBAction
- (IBAction)goPushOnOff:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sw.on] forKey:@"PushOnOff"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if( sw.on )
    {
        UIApplication *application = [UIApplication sharedApplication];
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
    }
    else
    {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

@end
