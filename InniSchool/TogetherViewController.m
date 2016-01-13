//
//  TogetherViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 18..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "TogetherViewController.h"
#import "TogetherAllViewController.h"
#import "TogetherAllPeopleViewController.h"
#import "CommonEmptyView.h"

@interface TogetherViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSArray *ar_CompleteList;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIView *v_TopBg;
@property (nonatomic, weak) IBOutlet UIView *v_TopSubBg;
@property (nonatomic, weak) IBOutlet UIView *v_BottomBg;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_Point;
@property (nonatomic, weak) IBOutlet UILabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UIButton *btn_MissionStatus;
@property (nonatomic, weak) IBOutlet UILabel *lb_CompleteCnt;
@end

@implementation TogetherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"우리 함께해요";
    
    [self initNavi];
    
    self.v_TopBg.layer.cornerRadius = 5.0f;
    self.v_TopSubBg.layer.cornerRadius = 5.0f;
    self.v_BottomBg.layer.cornerRadius = 5.0f;
    self.btn_MissionStatus.layer.cornerRadius = 5.0f;
    
    self.sv_Main.contentSize = CGSizeMake(0, self.v_BottomBg.frame.origin.y + self.v_BottomBg.frame.size.height + 10);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( self.isSubMode )
    {
        [self updateContents];
        self.isSubMode = NO;
    }
    else
    {
        [self updateList];
    }
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
    lb_Title.text = @"우리 함께해요";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    if( self.isSubMode )
    {
        self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItemWithWhiteColor:YES];
    }
}

- (void)updateList
{
    //http://127.0.0.1:7080/api/mission/selectMissionList.do?comBraRIdx=10001&userIdx=1004&searchType=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"1" forKey:@"searchType"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mission/selectMissionList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            self.dic_Info = nil;
                                            self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"MissionList"]];
                                            if( self.arM_List.count > 0 )
                                            {
                                                self.dic_Info = [self.arM_List firstObject];
                                            }
                                            
                                            [self updateContents];
                                        }
                                    }];
}

- (void)updateContents
{
    /*
     CompletedUserCnt = 1;
     CompletedYN = N;
     GetPoint = 10;
     MissionIdx = 11;
     MissionTitle = "\Ub2e4\Uac19\Uc774 \Ud48b\Uc720\Uc5b4\Ud578\Uc811";
     RN = 1;
     TodoEndDay = 20150531;
     TodoEndTime = 20;
     TodoStartDay = 20150429;
     TodoStartTime = 08;
     */
    
    //        self.dic_Info = [NSDictionary dictionaryWithDictionary:[self.arM_List firstObject]];
    
    static const NSInteger snEmptyViewTag = 878;
    
    UIView *view = (UIView *)[self.view viewWithTag:snEmptyViewTag];
    if( view )
    {
        [view removeFromSuperview];
    }

    if( self.dic_Info == nil )
    {
        UIView *v_EmptyContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        v_EmptyContainer.backgroundColor = [UIColor whiteColor];
        
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"CommonEmptyView" owner:self options:nil];
        CommonEmptyView *view = [topLevelObjects objectAtIndex:0];
        view.lb_Title.text = @"진행중인 미션이 없습니다.";
        v_EmptyContainer.tag = snEmptyViewTag;
        view.center = v_EmptyContainer.center;
        [v_EmptyContainer addSubview:view];
        [self.view addSubview:v_EmptyContainer];

        return;
    }
    
    self.lb_Date.text = [NSString stringWithFormat:@"%@ %@:00 ~ %@ %@:00",
                         [Util makeDate:[self.dic_Info objectForKey_YM:@"TodoStartDay"]],
                         [self.dic_Info objectForKey_YM:@"TodoStartTime"],
                         [Util makeDate:[self.dic_Info objectForKey_YM:@"TodoEndDay"]],
                         [self.dic_Info objectForKey_YM:@"TodoEndTime"]];
    
    [self.btn_Point setTitle:[NSString stringWithFormat:@" %ld", [[self.dic_Info objectForKey_YM:@"GetPoint"] integerValue]] forState:UIControlStateNormal];
    
    self.lb_Contents.text = [self.dic_Info objectForKey_YM:@"MissionTitle"];
    
    //  MissionList > TodoDTYN : 참여기간 중 여부 20150605일에 추가 됨

    //서버에 요청해야 할 사항
    if( [[self.dic_Info objectForKey_YM:@"CompletedYN"] isEqualToString:@"Y"] )
    {
        //완료 미션일 시
        [self.btn_MissionStatus setTitle:@"완료한 미션 입니다." forState:UIControlStateNormal];
        [self.btn_MissionStatus setTitleColor:[UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1] forState:UIControlStateNormal];
        [self.btn_MissionStatus setBackgroundColor:[UIColor colorWithHexString:@"EDEEEF"]];
        self.btn_MissionStatus.userInteractionEnabled = NO;
    }
    else
    {
//        NSDate *date = [NSDate date];
//        NSCalendar* calendar = [NSCalendar currentCalendar];
//        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
//        NSInteger nYear = [components year];
//        NSInteger nMonth = [components month];
//        NSInteger nDay = [components day];
//        NSInteger nHour = [components hour];
//        NSInteger nMinute = [components minute];
//
//        NSInteger nStartTime = [[NSString stringWithFormat:@"%@%@00", [self.dic_Info objectForKey_YM:@"TodoStartDay"], [self.dic_Info objectForKey_YM:@"TodoStartTime"]] integerValue];
//        NSInteger nEndTime = [[NSString stringWithFormat:@"%@%@00", [self.dic_Info objectForKey_YM:@"TodoEndDay"], [self.dic_Info objectForKey_YM:@"TodoEndTime"]] integerValue];
//        NSInteger nCurTime = [[NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute] integerValue];
//
//        if( nCurTime < nStartTime )
//        {
//            //현재 시간이 미션 시작 시간보다 작을 경우 @"참여시간이 아닙니다."
//            [self.btn_MissionStatus setTitle:@"참여시간이 아닙니다." forState:UIControlStateNormal];
//            [self.btn_MissionStatus setTitleColor:[UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1] forState:UIControlStateNormal];
//            [self.btn_MissionStatus setBackgroundColor:[UIColor colorWithHexString:@"EDEEEF"]];
//            self.btn_MissionStatus.userInteractionEnabled = NO;
//        }
//        else if( nCurTime > nEndTime )
//        {
//            //현재 시간이 미션 종료 시간보다 클 경우 @"참여하지 않은 미션입니다."
//            [self.btn_MissionStatus setTitle:@"참여하지 않은 미션입니다." forState:UIControlStateNormal];
//            [self.btn_MissionStatus setTitleColor:[UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1] forState:UIControlStateNormal];
//            [self.btn_MissionStatus setBackgroundColor:[UIColor colorWithHexString:@"EDEEEF"]];
//            self.btn_MissionStatus.userInteractionEnabled = NO;
//        }
//        else// if( nCurTime >= nStartTime && nCurTime <= nEndTime )
//        {
//            //미완일시
//            [self.btn_MissionStatus setTitle:@"완료 했어요!" forState:UIControlStateNormal];
//            [self.btn_MissionStatus setBackgroundColor:[UIColor colorWithHexString:@"68AB59"]];
//            self.btn_MissionStatus.userInteractionEnabled = YES;
//        }
        
        if( [[self.dic_Info objectForKey_YM:@"TodoDTYN"] isEqualToString:@"N"] )
        {
            [self.btn_MissionStatus setTitle:@"종료된 미션입니다." forState:UIControlStateNormal];
            [self.btn_MissionStatus setTitleColor:[UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1] forState:UIControlStateNormal];
            [self.btn_MissionStatus setBackgroundColor:[UIColor colorWithHexString:@"EDEEEF"]];
            self.btn_MissionStatus.userInteractionEnabled = NO;
        }
        else
        {
            //미완일시
            [self.btn_MissionStatus setTitle:@"완료 했어요!" forState:UIControlStateNormal];
            [self.btn_MissionStatus setBackgroundColor:[UIColor colorWithHexString:@"68AB59"]];
            self.btn_MissionStatus.userInteractionEnabled = YES;
        }
    }
    
    [self updateCompleteList];
}

- (void)updateCompleteList
{
    //http://127.0.0.1:7080/api/mission/selectMissionCompletedUserList.do?comBraRIdx=10001&userIdx=1004&missionIdx=8
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"MissionIdx"] integerValue]] forKey:@"missionIdx"];
    [dicM_Params setObject:@"1" forKey:@"startRowNum"];
    [dicM_Params setObject:@"100" forKey:@"endRowNum"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"mission/selectMissionCompletedUserList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            self.ar_CompleteList = [NSArray arrayWithArray:[resulte objectForKey:@"MissionCompletedUserList"]];
                                            
                                            /*
                                             DeptName = "\Ubd80\Uc11c1";
                                             DutiesPositionParentIdx = 100;
                                             FullImgURL = "";
                                             ImgURL = "<null>";
                                             NameKR = "\Ubcf8\Uc0ac(\Ud14c\Uc2a4\Ud2b8)";
                                             */
                                            
                                            self.lb_CompleteCnt.text = [NSString stringWithFormat:@"현재 %@명 완료!", [NSString stringWithFormat:@"%ld", self.ar_CompleteList.count]];
                                            
                                            NSInteger nMax = self.ar_CompleteList.count;
                                            
                                            if( nMax > 6 )
                                            {
                                                nMax = 6;
                                            }

                                            CGFloat fX = 0.0f;
                                            for( NSInteger i = 0; i < nMax; i++ )
                                            {
                                                NSDictionary *dic = self.ar_CompleteList[i];
                                                NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
                                                
                                                //14, 47, 41, 41 // 6
                                                UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i == 0 ? 14 : fX, 47, 41, 41)];
                                                iv.contentMode = UIViewContentModeScaleAspectFill;
                                                iv.clipsToBounds = YES;
                                                iv.layer.cornerRadius = iv.frame.size.width/2;
                                                iv.layer.masksToBounds = YES;

                                                [iv setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_small2.png") usingCache:NO];
                                                
                                                [self.v_BottomBg addSubview:iv];
                                                
                                                fX = iv.frame.origin.x + iv.frame.size.width + 6;
                                            }
                                        }
                                    }];

}


#pragma mark - IBAction
- (IBAction)goMissionPress:(id)sender
{
    if( [[self.dic_Info objectForKey_YM:@"CompletedYN"] isEqualToString:@"N"] )
    {
        //http://127.0.0.1:7080/api/mission/insertMissionCompleted.do?comBraRIdx=10001&userIdx=1004&missionIdx=8
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"MissionIdx"] integerValue]] forKey:@"missionIdx"];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"mission/insertMissionCompleted.do"
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [GMDCircleLoader hide];

                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                switch (nCode) {
                                                    case 1:
                                                    {
                                                        ALERT_ONE(@"함께 해주어서\n고마워요 ^^");
                                                        
                                                        if( self.arM_List.count > 0 )
                                                        {
                                                            [self.arM_List removeObjectAtIndex:0];
                                                            self.dic_Info = [self.arM_List firstObject];
                                                            
                                                            [self updateList];
                                                        }
                                                        else
                                                        {
                                                            [self.btn_MissionStatus setTitle:@"완료한 미션 입니다." forState:UIControlStateNormal];
                                                            [self.btn_MissionStatus setTitleColor:[UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1] forState:UIControlStateNormal];
                                                            [self.btn_MissionStatus setBackgroundColor:[UIColor colorWithHexString:@"EDEEEF"]];
                                                            self.btn_MissionStatus.userInteractionEnabled = NO;
                                                        }
                                                    }
                                                        break;
                                                        
                                                    default:
                                                        [self.navigationController.view makeToast:@"오류"];
                                                        break;
                                                }
                                            }
                                        }];
    }
}

- (IBAction)goShowAllMission:(id)sender
{
    TogetherAllViewController *vc = [[TogetherAllViewController alloc]initWithNibName:@"TogetherAllViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goShowAllPeople:(id)sender
{
    TogetherAllPeopleViewController *vc = [[TogetherAllPeopleViewController alloc]initWithNibName:@"TogetherAllPeopleViewController" bundle:nil];
    vc.ar_List = [NSArray arrayWithArray:self.ar_CompleteList];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
