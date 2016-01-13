//
//  MoviePlayerViewController.m
//  EmAritaum
//
//  Created by Kim Young-Min on 2014. 4. 7..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import "MoviePlayerViewController.h"

@interface MoviePlayerViewController ()
{
    BOOL isContinue;
    CGFloat fLastTime;
}
//@property (nonatomic, assign) BOOL isFullSee;   //끝까지 다 시청 했는지 여부
@property (nonatomic, strong) UIButton *btn_Close;
@property (nonatomic, strong) UIButton *btn_Pause;
@property (nonatomic, strong) UILabel *lb_PlayTime;
@property (nonatomic, strong) NSTimer *tm_Toggle;
@property (nonatomic, strong) NSTimer *tm_Time;
@end

@implementation MoviePlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( self.isSave )
    {
        isContinue = NO;
        
        UIView *v_Touch = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
        [self.view addSubview:v_Touch];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [v_Touch addGestureRecognizer:singleTap];

        self.btn_Close = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn_Close.frame = CGRectMake(self.view.frame.size.height - 70, 10, 60, 30);
        [self.btn_Close addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
        [self.btn_Close setTitle:@"닫기" forState:UIControlStateNormal];
        [self.btn_Close.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        [self.btn_Close.titleLabel setTextColor:[UIColor whiteColor]];
        self.btn_Close.layer.cornerRadius = 5.0f;
        self.btn_Close.layer.borderColor = [UIColor whiteColor].CGColor;
        self.btn_Close.layer.borderWidth = 1.0f;
        [self.view addSubview:self.btn_Close];
        
        //btn_stop
        
        self.btn_Pause = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn_Pause.frame = CGRectMake(0, 0, 120, 120);
        self.btn_Pause.center = CGPointMake(self.view.center.y, self.view.center.x);
        [self.btn_Pause setImage:BundleImage(@"btn_stop.png") forState:UIControlStateNormal];
        [self.btn_Pause addTarget:self action:@selector(onPause) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btn_Pause];
        
        
        //재생시간
        self.lb_PlayTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.height, 30)];
        self.lb_PlayTime.backgroundColor = [UIColor colorWithHexString:@"444444"];
        self.lb_PlayTime.font = [UIFont fontWithName:@"Helvetica" size:14];
        self.lb_PlayTime.textColor = [UIColor whiteColor];
        self.lb_PlayTime.textAlignment = NSTextAlignmentCenter;
        self.lb_PlayTime.text = @"00:00 / 00:00";
        [self.view addSubview:self.lb_PlayTime];

        self.btn_Close.alpha = self.btn_Pause.alpha = self.lb_PlayTime.alpha = NO;
        
        self.tm_Time = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onUpdateTime) userInfo:nil repeats:YES];
        [self.tm_Time fire];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//        [self.moviePlayer play];
//    }];
}

- (void)onUpdateTime
{
    NSInteger nPlayBackTime = (NSInteger)self.moviePlayer.currentPlaybackTime;
    NSInteger nTotalDuration = (NSInteger)self.moviePlayer.duration;
    
    NSInteger nTotalSec = nTotalDuration % 60;
    NSInteger nTotalMin = (nTotalDuration / 60) % 60;
    NSInteger nTotalHour = nTotalDuration / 3600;

    NSInteger nPlaySec = nPlayBackTime % 60;
    NSInteger nPlayMin = (nPlayBackTime / 60) % 60;
    NSInteger nPlayHour = nPlayBackTime / 3600;

    if( nTotalHour > 0 )
    {
        self.lb_PlayTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld / %02ld:%02ld:%02ld",
                                 nPlayHour,
                                 nPlayMin,
                                 nPlaySec,
                                 nTotalHour,
                                 nTotalMin,
                                 nTotalSec];
    }
    else
    {
        self.lb_PlayTime.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld",
                                 nPlayMin,
                                 nPlaySec,
                                 nTotalMin,
                                 nTotalSec];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    self.view.transform = CGAffineTransformIdentity;
//    CGFloat width = self.view.frame.size.width > self.view.frame.size.height ? self.view.frame.size.height : self.view.frame.size.width;
//    CGFloat height = self.view.frame.size.width > self.view.frame.size.height ? self.view.frame.size.width : self.view.frame.size.height;
//    self.view.bounds = CGRectMake(0, 0, width, height);
//
//}

#pragma mark - MPMoviePlayerNotification
- (void)MPMoviePlayerPlaybackStateDidChange
{
    MPMoviePlaybackState playbackState = self.moviePlayer.playbackState;
    
    switch (playbackState)
    {
        case MPMoviePlaybackStateStopped:
//            if( self.dic_InfoMap && self.isStudyMode )
            if( self.dic_Info && self.isSave )
            {
                if( self.moviePlayer.currentPlaybackTime > 0 && self.moviePlayer.currentPlaybackTime >= self.moviePlayer.duration - 3 )
                {
                    //끝까지 다 시청한 경우
                    self.moviePlayer.currentPlaybackTime = self.moviePlayer.duration;
                    [self saveStatus];
                }
                else
                {
                    //중간에 종료한 경우
                    //기존시간보다 더 봤을 경우에만 진도저장
                    
                    //CompleteProgressRate 사용자의 기존 진도율
                    NSDictionary *dic_ContentsInfo = [self.dic_Info objectForKey:@"VODContentInfo"];
                    CGFloat fBeforeTime = [[dic_ContentsInfo objectForKey_YM:@"VODProcessingTime"] floatValue];

                    if( fBeforeTime < self.moviePlayer.currentPlaybackTime )
                    {
                        [self saveStatus];
                    }
                }
                
//                /**************테스트 코드*******************/
//                if( [self.delegate respondsToSelector:@selector(videoFinished:)] )
//                {
//                    [self.delegate videoFinished:@"1"];
//                }
//                /*****************************************/
                
                NSLog(@"시청한 시간: %f", self.moviePlayer.currentPlaybackTime);
                NSLog(@"종료이벤트 발생");
            }
            break;
        case MPMoviePlaybackStatePlaying:
        {
//            //스트리밍이라 안됨..
//            if( self.fProgTime >= self.moviePlayer.currentPlaybackTime )
//            {
//                self.moviePlayer.currentPlaybackTime = self.fProgTime;
//            }
            NSLog(@"총시간: %f", self.moviePlayer.duration);
            NSLog(@"MPMoviePlaybackStatePlaying");
            
            if( self.isSave )
            {
                //사용자가 학습완료한 시점 (이어보기 기능)
                NSDictionary *dic_ContentsInfo = [self.dic_Info objectForKey:@"VODContentInfo"];
                fLastTime = [[dic_ContentsInfo objectForKey_YM:@"VODProcessingTime"] floatValue];
                if( fLastTime > 0 && fLastTime < self.moviePlayer.duration && isContinue == NO )
                {
                    self.moviePlayer.currentPlaybackTime = fLastTime;
                }
            }
    }
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"MPMoviePlaybackStatePaused");
            isContinue = YES;
            break;
        case MPMoviePlaybackStateInterrupted:
            NSLog(@"MPMoviePlaybackStateInterrupted");
            break;
        case MPMoviePlaybackStateSeekingForward:
            NSLog(@"MPMoviePlaybackStateSeekingForward");
            break;
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"MPMoviePlaybackStateSeekingBackward");
            break;
        default:
            break;
    }
}

- (void)playbackDidFinish:(NSNotification *)noti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self]; // 동영상 상태 노티 제거

    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:self]; // 동영상 상태 노티 제거

    
    NSDictionary *userInfo = [noti userInfo]; // 종료 원인 파악
    if ([[userInfo objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue] == MPMovieFinishReasonUserExited)
    {
        NSLog(@"유저종료");
    }
    else
    {
//        self.isFullSee = YES;
        NSLog(@"자연종료");
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft];
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)saveStatus
{
//    http://211.232.113.65:7080/api/learn/updateIntegrationCourseProgressRateVOD.do?
    //comBraRIdx=10001
    //userIdx=1004
    //integrationCourseIdx=1
    //vodIdx=1              컨텐츠동영상 고유번호
    //vodType=587
    //vodProcessingTime=10  사용자가 학습완료한 지점
    //vodRunningTime=141    동영상 Running Time
    //contentType=831
    //integrationCourseNM=테스트과정 //차수명
    
    NSDictionary *dic_ContentsInfo = [self.dic_Info objectForKey:@"VODContentInfo"];

    NSInteger nRunningTime = (NSInteger)self.moviePlayer.duration;// [[dic_ContentsInfo objectForKey_YM:@"VODRunningTime"] integerValue];
    NSInteger nPlayTime = (NSInteger)self.moviePlayer.currentPlaybackTime;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[dic_ContentsInfo objectForKey_YM:@"VODIdx"] forKey:@"vodIdx"];
    [dicM_Params setObject:@"587" forKey:@"vodType"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nPlayTime] forKey:@"vodProcessingTime"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nRunningTime] forKey:@"vodRunningTime"];
    [dicM_Params setObject:@"831" forKey:@"contentType"];
    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseNM"] forKey:@"integrationCourseNM"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/updateIntegrationCourseProgressRateVOD.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            /*
                                             "처리결과
                                             0 : 실패
                                             1 : 성공"
                                             */
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            if( nCode == 0 )
                                            {
                                                //실패
                                                
                                            }
                                            else if( nCode == 1 )
                                            {
                                                //성공
                                                //성공하면 뷰 갱신하기
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadStudyDetailView" object:nil userInfo:nil];
                                            }
                                        }
                                    }];
//    /*
//     과정정보의 lect_edate >= 오늘날짜 이면 호출한다
//     화면 상단의 X 버튼 클릭시 학습하기에서 불러온 ProgTime 보다 현재 진행 ProgTime이 크면 호출 동영상 재생을 멈추고 현재 재생시간으로 초단위로 ProgTime값을 전달
//     동영상이 끝까지 재생후 멈췄을 경우에도 해당 API 호출
//     과정상태
//     0 : 과정종료
//     1 : 학습중
//     2 : 학습완료 시험보기창 호출(웹뷰) 3: 학습완료별점평가호출
//     4 : 학습완료 지식인 시험 호출(웹뷰)
//     */
//    
//    
//    //학습이 종료되었다면 진행상태를 저장하지 않는다
//    //이미 수료했으면 저장하지 않고 리턴
////    NSString *str_IsClear = [self.dic_InfoMap objectForKey_YM:@"CertificateYN"];
////    if( [str_IsClear isEqualToString:@"Y"] )
////    {
////        return;
////    }
//    
//    //이미 종료된 학습이라면 리턴 (해야 하는데 뭘로 구분하지?) 02.27
//    
//    
//    
////    URL : http://112.216.0.179:8080/api/course/insertSubProcessProgressRatVideo
//    
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
//    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"userIdx"] forKey:@"userIdx"];
//    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"brandIdx"] forKey:@"brandIdx"];
//    [dicM_Params setObject:[self.dic_InfoMap objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"]; //차수 idx
//    [dicM_Params setObject:[self.dic_ContentsList objectForKey_YM:@"ProcessIdx"] forKey:@"processIdx"];   //과정 idx
//    [dicM_Params setObject:[self.dic_ContentsList objectForKey_YM:@"SubProcessIdx"] forKey:@"subProcessIdx"];    //차시 idx
//    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", (NSInteger)self.moviePlayer.currentPlaybackTime] forKey:@"currentTime"];  //사용자가 학습을 종료한 시점의 동영상시간(단위:초)
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"course/insertSubProcessProgressRateVideo"
//                                   param:dicM_Params
//                               withBlock:^(id resulte, NSError *error) {
//                                   
//                                   if( resulte )
//                                   {
//                                       NSArray *ar = [NSArray arrayWithArray:[resulte valueForKey:@"resultData"]];
//                                       if( ar.count > 0 )
//                                       {
//                                           NSDictionary *dic = [ar firstObject];
//                                           NSInteger nCode = [[dic valueForKey:@"ResultCode"] integerValue];
//                                           if( nCode == 0 )
//                                           {
//                                               //저장성공
//                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadStudyDetailView" object:nil userInfo:nil];
//                                           }
//                                           else
//                                           {
//                                               //저장 실패
//                                           }
//                                       }
//                                       else
//                                       {
//                                           //저장실패
//                                       }
//                                   }
//                               }];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self playButtonToggle];
}

- (void)playButtonToggle
{
    [self.tm_Toggle invalidate];
    self.tm_Toggle = nil;
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.btn_Close.alpha = !self.btn_Close.alpha;
                         self.btn_Pause.alpha = !self.btn_Pause.alpha;
                         self.lb_PlayTime.alpha = !self.lb_PlayTime.alpha;
                         
                     }completion:^(BOOL finished) {
                         
                         if( self.btn_Close.alpha == YES )
                         {
                             self.tm_Toggle = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(playButtonToggle) userInfo:nil repeats:NO];
                         }
                     }];
}

- (void)onPause
{
    if( self.moviePlayer.playbackState == MPMoviePlaybackStatePaused )
    {
        //현재 상태가 일시정지면 재생으로
        [self.moviePlayer play];
        [self.btn_Pause setImage:BundleImage(@"btn_stop.png") forState:UIControlStateNormal];
        
        [self playButtonToggle];
    }
    else if( self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying )
    {
        //현재 상태가 재생이면 일시정지로
        [self.moviePlayer pause];
        [self.btn_Pause setImage:BundleImage(@"btn_play1.png") forState:UIControlStateNormal];
    }
}

- (void)onClose
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                                                  
                                 [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self]; // 동영상 상태 노티 제거
                                 
                                 [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:self]; // 동영상 상태 노티 제거
                             }];
}

@end
