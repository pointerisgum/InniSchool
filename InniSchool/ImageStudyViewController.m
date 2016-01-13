//
//  ImageStudyViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 11..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "ImageStudyViewController.h"

@interface ImageStudyViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIButton *btn_Close;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@end

@implementation ImageStudyViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"학습하기(이미지)";

    UIView *v_Touch = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    [self.view addSubview:v_Touch];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [v_Touch addGestureRecognizer:singleTap];
    
    
    self.btn_Close = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_Close.frame = CGRectMake(self.view.frame.size.width - 70, 10, 60, 30);
    [self.btn_Close addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_Close setTitle:@"닫기" forState:UIControlStateNormal];
    [self.btn_Close.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [self.btn_Close.titleLabel setTextColor:[UIColor whiteColor]];
    self.btn_Close.layer.cornerRadius = 5.0f;
    self.btn_Close.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btn_Close.layer.borderWidth = 1.0f;
    [self.view addSubview:self.btn_Close];
    
    UISwipeGestureRecognizer *nextSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextSwipeGesture:)];
    nextSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;  //다음
    [self.view addGestureRecognizer:nextSwipeRecognizer];
    
    UISwipeGestureRecognizer *prevSwipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(prevSwipeGesture:)];
    prevSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;  //이전
    [self.view addGestureRecognizer:prevSwipeRecognizer];

    [self updateContents];
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


- (void)updateContents
{
    /*
     ContentMineType = "application/x-zip-compressed";
     FrameCnt = 11;
     FrameContentList =     (
     {
     FileName = "1.PNG";
     FileURL = "/contents_upload/051952/11111111/1.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/1.PNG";
     },
     {
     FileName = "2.PNG";
     FileURL = "/contents_upload/051952/11111111/2.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/2.PNG";
     },
     {
     FileName = "3.PNG";
     FileURL = "/contents_upload/051952/11111111/3.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/3.PNG";
     },
     {
     FileName = "4.PNG";
     FileURL = "/contents_upload/051952/11111111/4.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/4.PNG";
     },
     {
     FileName = "5.PNG";
     FileURL = "/contents_upload/051952/11111111/5.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/5.PNG";
     },
     {
     FileName = "6.PNG";
     FileURL = "/contents_upload/051952/11111111/6.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/6.PNG";
     },
     {
     FileName = "7.PNG";
     FileURL = "/contents_upload/051952/11111111/7.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/7.PNG";
     },
     {
     FileName = "8.PNG";
     FileURL = "/contents_upload/051952/11111111/8.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/8.PNG";
     },
     {
     FileName = "9.PNG";
     FileURL = "/contents_upload/051952/11111111/9.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/9.PNG";
     },
     {
     FileName = "10.PNG";
     FileURL = "/contents_upload/051952/11111111/10.PNG";
     FullFileURL = "http://52.68.160.225:80/api/contents_upload/051952/11111111/10.PNG";
     }
     );
     FrameProcessingCnt = 11;
     IntegrationCourseIdx = 36;
     */
    
    NSArray *ar_List = [self.dic_Info objectForKey:@"FrameContentList"];
    for( NSInteger i = 0; i < ar_List.count; i++ )
    {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i * self.sv_Main.frame.size.width, 0, self.sv_Main.frame.size.width, self.sv_Main.frame.size.height)];
        iv.tag = i + 1;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.clipsToBounds = YES;
        
        NSDictionary *dic = ar_List[i];
        NSString *str_ImageUrl = [dic objectForKey_YM:@"FullFileURL"];
        [iv setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
        
        [self.sv_Main addSubview:iv];
    }
    
    self.sv_Main.contentSize = CGSizeMake(self.sv_Main.frame.size.width * ar_List.count, 0);
    self.sv_Main.delegate = self;
    self.sv_Main.pagingEnabled = YES;
    self.sv_Main.minimumZoomScale = 1.0f;
    self.sv_Main.maximumZoomScale = 3.0f;
    [self.sv_Main setZoomScale:self.sv_Main.minimumZoomScale];
}


#pragma mark - UIScrollViewDelegate
- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    
    return frameToCenter;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSInteger nPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    UIView *view = [self.sv_Main viewWithTag:nPage + 1];
    view.frame = [self centeredFrameForScrollView:scrollView andUIView:view];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSInteger nPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    UIView *view = [self.sv_Main viewWithTag:nPage + 1];
    return view;
}


- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.btn_Close.alpha = !self.btn_Close.alpha;
                     }];
}


#pragma mark - IBAction
- (void)onClose
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

@end
