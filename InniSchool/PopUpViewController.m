//
//  PopUpViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 28..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "PopUpViewController.h"

@interface PopUpViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *iv_Contents;
@property (nonatomic, weak) IBOutlet UIButton *btn_Toggle;
@end

@implementation PopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self updateList];
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

- (void)updateList
{
    [self.iv_Contents setImageWithString:self.str_Url placeholderImage:BundleImage(@"") usingCache:NO];

    
//    //http://52.68.160.225/api/mypage/selectInniDiaryImage.do
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
//    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
//    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mypage/selectInniDiaryImage.do"
//                                        param:dicM_Params
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        if( resulte )
//                                        {
//                                            NSDictionary *dic = [resulte objectForKey:@"InniDiaryImageInfo"];
//                                            
//                                            NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
//                                            if( str_ImageUrl && str_ImageUrl.length > 0 )
//                                            {
//                                                [self.iv_Contents setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"") usingCache:NO];
//                                            }
//                                        }
//                                    }];
}

- (IBAction)goNoSee:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
}

- (IBAction)goClose:(id)sender
{
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    
    if( self.btn_Toggle.selected )
    {
        //오늘 하루 보지 않기를 눌렀다면 현재 날짜를 저장함 (나중에 비교할때 쓰기 위함)
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%04ld%02ld%02ld", nYear, nMonth, nDay] forKey:@"popUpTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
