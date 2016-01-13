//
//  ImagePlayerViewController.m
//  EmAritaum
//
//  Created by Kim Young-Min on 2014. 4. 7..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import "ImagePlayerViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ZoomView.h"

@interface ImagePlayerViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, strong) IBOutlet ZoomView *v_Zoom;
@property (nonatomic, strong) IBOutlet UIView *v_MenuBar;
@property (nonatomic, strong) IBOutlet UILabel *lb_Title;
@end

@implementation ImagePlayerViewController

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
    
    self.screenName = @"학습하기(이미지)";
    
    self.arM_List = [NSMutableArray array];

    NSDictionary *dic_ContentsInfo = [self.dic_Info objectForKey:@"FrameContentInfo"];
    if( [[dic_ContentsInfo objectForKey:@"FrameContentList"] isKindOfClass:[NSNull class]] == NO )
    {
        NSArray *ar_List = [dic_ContentsInfo objectForKey:@"FrameContentList"];
        for( NSInteger i = 0; i < ar_List.count; i++ )
        {
            NSDictionary *dic_ImageInfo = ar_List[i];
            NSString *str_ImageUrl = [dic_ImageInfo objectForKey_YM:@"FullFileURL"];
            [self.arM_List addObject:str_ImageUrl];
        }
    }

    self.v_Zoom.hidden = YES;
    
    self.sv_Main.minimumZoomScale = 1.0f;
    self.sv_Main.maximumZoomScale = 3.0f;
    
    [self.sv_Main setContentSize:CGSizeMake(self.sv_Main.bounds.size.height * self.arM_List.count, self.sv_Main.bounds.size.width)];
    
    self.sv_Main.delegate = self;

    for( int i = 0; i < self.arM_List.count; i++ )
    {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i * self.sv_Main.bounds.size.height, 0, self.sv_Main.bounds.size.height, self.sv_Main.bounds.size.width)];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.tag = i + 1;
        
        NSString *str_ImageUrl = [self.arM_List objectAtIndex:i];
//        NSURL *imageUrl = [NSURL URLWithString:str_ImageUrl];
        [iv setImageWithString:str_ImageUrl placeholderImage:nil usingCache:NO];
        [self.sv_Main addSubview:iv];
    }
    
    UISwipeGestureRecognizer *nextSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextSwipeGesture:)];
    nextSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;  //다음
    [self.view addGestureRecognizer:nextSwipeRecognizer];
    
    UISwipeGestureRecognizer *prevSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(prevSwipeGesture:)];
    prevSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;  //이전
    [self.view addGestureRecognizer:prevSwipeRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    [self updateTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( self.isStudy )
    {
        NSDictionary *dic_ContentsInfo = [self.dic_Info objectForKey:@"FrameContentInfo"];
        NSInteger nBeforeStatus = [[NSString stringWithFormat:@"%@", [dic_ContentsInfo objectForKey_YM:@"FrameProcessingCnt"]] integerValue];
        //
        if( nBeforeStatus > 1 )
        {
            if( IS_IOS8_OR_ABOVE )
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:@"학습중이던 차수였습니다\n기존 학습을 이어 보시겠습니까?"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:@"예"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [UIView animateWithDuration:0.3f
                                                                animations:^{
                                                                    
                                                                    self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width * (nBeforeStatus - 1), 0);
                                                                    
                                                                } completion:^(BOOL finished) {
                                                                    
                                                                    [self updateTitle];
                                                                }];
                                           }];
                
                [alertController addAction:okAction];
                
                
                UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"아니요"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               
                                           }];
                
                [alertController addAction:cancelAction];


                [self presentViewController:alertController animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = CREATE_ALERT(nil, @"학습중이던 차수였습니다\n기존 학습을 이어 보시겠습니까?", @"예", @"아니요");
                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if( buttonIndex == 0 )
                    {
                        [UIView animateWithDuration:0.3f
                                         animations:^{
                                             
                                             self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width * (nBeforeStatus - 1), 0);
                                             
                                         } completion:^(BOOL finished) {
                                             
                                             [self updateTitle];
                                         }];
                    }
                }];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (void)updateTitle
{
    NSInteger nCurPage = (self.sv_Main.contentOffset.x / self.sv_Main.frame.size.width) + 1;
    self.lb_Title.text = [NSString stringWithFormat:@"%ld / %lu", (long)nCurPage, (unsigned long)[self.arM_List count]];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( self.isStudy == NO )
    {
        [self updateTitle];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if( self.v_Zoom.hidden == YES )
    {
        NSInteger nPage = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
        UIImageView *iv = (UIImageView *)[self.sv_Main viewWithTag:nPage + 1];
        self.v_Zoom.iv_Zoom.image = iv.image;
        self.v_Zoom.hidden = NO;
        //        [self.v_Zoom viewForZoomingInScrollView:self.v_Zoom.sv_Zoom];
    }
    
    return nil;
}


#pragma mark - UIGestureCallBack
- (void)prevSwipeGesture:(UISwipeGestureRecognizer *)gesture
{
    if( self.v_Zoom.hidden == NO )
    {
        self.v_Zoom.hidden = YES;
    }

    if( self.sv_Main.contentOffset.x > 0 )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Main.contentOffset = CGPointMake(self.sv_Main.contentOffset.x - self.sv_Main.frame.size.width, self.sv_Main.contentOffset.y);
                             
                         } completion:^(BOOL finished) {
                             
                             [self updateTitle];
                         }];
    }
}

- (void)nextSwipeGesture:(UISwipeGestureRecognizer *)gesture
{
    if( self.v_Zoom.hidden == NO )
    {
        self.v_Zoom.hidden = YES;
    }
    
    if( self.sv_Main.contentOffset.x < ([self.arM_List count] - 1) * self.sv_Main.frame.size.width )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Main.contentOffset = CGPointMake(self.sv_Main.contentOffset.x + self.sv_Main.frame.size.width, self.sv_Main.contentOffset.y);
                             
                         } completion:^(BOOL finished) {
                             
                             [self updateTitle];
                         }];
    }
}

- (void)tapGesture:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.v_MenuBar.alpha = !self.v_MenuBar.alpha;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}


#pragma mark - IBAction
- (IBAction)goClosed:(id)sender
{
    if( self.isStudy )
    {
        //http://127.0.0.1:7080/api/learn/updateIntegrationCourseProgressRateFrame.do?
        //comBraRIdx=10001
        //userIdx=1004
        //integrationCourseIdx=13
        //frameProcessingCnt=3
        //frameCnt=22
        //contentType=829
        //integrationCourseNM=과정!
        
        NSDictionary *dic_ContentsInfo = [self.dic_Info objectForKey:@"FrameContentInfo"];
        
        //사용자의 기존 진도율
        NSInteger nBeforeStatus = [[NSString stringWithFormat:@"%@", [dic_ContentsInfo objectForKey_YM:@"FrameProcessingCnt"]] integerValue];
        
        //사용자의 현재 진도율
        NSInteger nCurPage = (self.sv_Main.contentOffset.x / self.sv_Main.frame.size.width) + 1;
        if( nCurPage > nBeforeStatus )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseIdx"] forKey:@"integrationCourseIdx"];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nCurPage] forKey:@"frameProcessingCnt"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.arM_List.count] forKey:@"frameCnt"];
            [dicM_Params setObject:@"829" forKey:@"contentType"];
            [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"IntegrationCourseNM"] forKey:@"integrationCourseNM"];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"learn/updateIntegrationCourseProgressRateFrame.do"
                                                param:dicM_Params
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                if( resulte )
                                                {
                                                    NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                    if( nCode == 1 )
                                                    {
                                                        [self closeModal];
                                                    }
                                                    else
                                                    {
                                                        [self.navigationController.view makeToast:@"진도율 저장 오류"];
                                                        [self performSelector:@selector(closeModal) withObject:nil afterDelay:1.0f];
                                                    }
                                                }
                                            }];
        }
        else
        {
            [self closeModal];
        }
    }
    else
    {
        [self closeModal];
    }
}

- (void)closeModal
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

@end
