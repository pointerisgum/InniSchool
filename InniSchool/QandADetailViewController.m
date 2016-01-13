//
//  QandADetailViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 28..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "QandADetailViewController.h"
#import "MWPhotoBrowser.h"

@interface QandADetailViewController () <UIWebViewDelegate, MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation QandADetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initNavi];
    
    
    self.webView.delegate = self;
    
    NSString *str_Url = [NSString stringWithFormat:@"%@/front/webview/board/wvBoardQnaView.do?boardType=1102&boardIdx=%@&userIdx=%@",
                         kBaseUrl,
                         self.str_Idx,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
    [self.webView loadRequest:request];
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
    lb_Title.text = @"문의사항";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
}


//아래 이건 델리게이트를 설정해야 콜 됨
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if( [[[request URL] absoluteString] hasPrefix:@"toapp://"] )
    {
        NSString *jsData = [[request URL] absoluteString];
        NSArray *ar_Cert = [jsData componentsSeparatedByString:@"toapp://cmd?status=certi&"];
        if( ar_Cert.count > 1 )
        {
            NSString *str = [[ar_Cert objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *ar_Sep = [str componentsSeparatedByString:@"&"];
            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithCapacity:ar_Sep.count];
            for( NSString *str in ar_Sep )
            {
                NSArray *ar = [str componentsSeparatedByString:@"="];
                [dicM setValue:[ar objectAtIndex:1] forKey:[ar objectAtIndex:0]];
            }
            
            [self.navigationController popViewControllerAnimated:NO];
            
            //            if( [self.delegate respondsToSelector:@selector(webViewCancel)] )
            //            {
            //                [self.navigationController popViewControllerAnimated:NO];
            //                return YES;
            //            }
        }
        
        
        NSArray *jsDataArray = [jsData componentsSeparatedByString:@"toapp://"];
        
        //        //1보다크면 무조건 팝!!
        //        if( [jsDataArray count] > 1 )
        //        {
        //            [self.navigationController popViewControllerAnimated:YES];
        //            return YES;
        //        }
        
        NSString *jsString = [jsDataArray objectAtIndex:1]; //jsString == @"call objective-c from javascript"
        
        NSRange range = [jsString rangeOfString:@"CLOSE"];
        if (range.location != NSNotFound)
        {
            [self.navigationController popViewControllerAnimated:YES];
            return YES;
        }
        
        //이미지 클릭시
        range = [jsString rangeOfString:@"cmd?IMAGE"];
        if (range.location != NSNotFound)
        {
            jsString = [jsString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            jsString = [jsString stringByReplacingOccurrencesOfString:@"cmd?IMAGE<imgURL>" withString:@""];
            jsString = [jsString stringByReplacingOccurrencesOfString:@"</imgURL>" withString:@""];
            
            NSArray *ar_Tmp = [jsString componentsSeparatedByString:@";"];
            
            NSMutableArray *arM_ImageList = [NSMutableArray arrayWithCapacity:ar_Tmp.count];
            for( NSInteger i = 0; i < ar_Tmp.count; i++ )
            {
                [arM_ImageList addObject:ar_Tmp[i]];
            }
            
            
            
            
            
            NSInteger nImageCnt = ar_Tmp.count;
            self.thumbs = [NSMutableArray arrayWithCapacity:nImageCnt];
            self.ar_Photo = [NSMutableArray arrayWithCapacity:nImageCnt];
            
            for( NSInteger i = 0; i < nImageCnt; i++ )
            {
                NSString *str_Url = ar_Tmp[i];
                if( str_Url.length <= 0 || [str_Url hasPrefix:@"http"] == NO )
                {
                    continue;
                }
                [self.thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:str_Url]]];
                [self.ar_Photo addObject:[MWPhoto photoWithURL:[NSURL URLWithString:str_Url]]];
            }
            
            BOOL displayActionButton = NO;
            BOOL displaySelectionButtons = NO;
            BOOL displayNavArrows = YES;
            BOOL enableGrid = YES;
            BOOL startOnGrid = NO;
            
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = displayActionButton;
            browser.displayNavArrows = displayNavArrows;
            browser.displaySelectionButtons = displaySelectionButtons;
            browser.alwaysShowControls = displaySelectionButtons;
            browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            browser.wantsFullScreenLayout = YES;
#endif
            browser.enableGrid = enableGrid;
            browser.startOnGrid = startOnGrid;
            browser.enableSwipeToDismiss = YES;
            
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
            nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nc animated:YES completion:nil];
            
        }
        
        //
        
        NSLog(@"%@", jsString);
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"자바스크립트 연동" message:jsString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        //        [alert show];
        
        //        [self callJavaScriptFromObjectiveC];
        //        return NO;
        
    }
    
    return YES;
}


#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _ar_Photo.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _ar_Photo.count)
        return [_ar_Photo objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < _thumbs.count)
    {
        return [_thumbs objectAtIndex:index];
    }
    return nil;
}

@end
