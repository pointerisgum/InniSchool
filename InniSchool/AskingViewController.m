//
//  AskingViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 11..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "AskingViewController.h"
#import "AskingWriteViewController.h"
#import "QandADetailViewController.h"

@interface AskingViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIWebView *web_FAQ;
@property (nonatomic, weak) IBOutlet UIWebView *web_QnA;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bar;
@property (nonatomic, weak) IBOutlet UIButton *btn_FAQ;
@property (nonatomic, weak) IBOutlet UIButton *btn_QnA;
@end

@implementation AskingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"문의사항";
    
    [self initNavi];
    
    self.web_FAQ.delegate = self;
    self.web_QnA.delegate = self;

    self.btn_FAQ.selected = YES;
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.sv_Main addGestureRecognizer:swipeLeft];
    [self.sv_Main addGestureRecognizer:swipeRight];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self updateList];

    if( self.btn_FAQ.selected )
    {
        self.sv_Main.contentOffset = CGPointZero;
    }
    else
    {
        self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItemWithWhiteColor:YES];
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
    if( self.btn_FAQ.selected )
    {
        NSString *str_Url = [NSString stringWithFormat:@"%@/front/webview/board/wvBoardList.do?boardType=1103&userIdx=%@",
                             kBaseUrl,
                             [[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"]];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
        [self.web_FAQ loadRequest:request];
    }
    else
    {
        NSString *str_Url = [NSString stringWithFormat:@"%@/front/webview/board/wvBoardList.do?boardType=1102&userIdx=%@",
                             kBaseUrl,
                             [[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"]];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
        [self.web_QnA loadRequest:request];
    }
}


#pragma mark - UIWebViewDelegate
//아래 이건 델리게이트를 설정해야 콜 됨
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //toapp://cmd?VIEW%3CboardIdx%3E70%3C/boardIdx%3E

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
        jsString = [jsString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSRange range = [jsString rangeOfString:@"CLOSE"];
        if (range.location != NSNotFound)
        {
            [self.navigationController popViewControllerAnimated:YES];
            return YES;
        }
        
        range = [jsString rangeOfString:@"VIEW"];
        if (range.location != NSNotFound)
        {
            NSArray *ar_Sep = [jsString componentsSeparatedByString:@"<boardIdx>"];
            if( ar_Sep.count > 1 )
            {
                NSString *str_Idx = ar_Sep[1];
                ar_Sep = [str_Idx componentsSeparatedByString:@"</boardIdx>"];
                if( ar_Sep.count > 1 )
                {
                    str_Idx = [ar_Sep firstObject];
                    QandADetailViewController *vc = [[QandADetailViewController alloc]initWithNibName:@"QandADetailViewController" bundle:nil];
                    vc.str_Idx = str_Idx;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            return YES;
        }


        NSLog(@"%@", jsString);
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"자바스크립트 연동" message:jsString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        //        [alert show];
        
        //        [self callJavaScriptFromObjectiveC];
        //        return NO;
        
    }
    
    return YES;
}


#pragma mark - UIGesture
- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    [self.view endEditing:YES];
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if( self.sv_Main.contentOffset.x == 0 )
        {
            [self goMenuToggle:self.btn_QnA];
        }
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if( self.sv_Main.contentOffset.x > 0 )
        {
            [self goMenuToggle:self.btn_FAQ];
        }
    }
}


#pragma mark - IBAction
- (IBAction)goMenuToggle:(id)sender
{
    if( sender == self.btn_FAQ )
    {
        if( self.btn_FAQ.selected == NO )
        {
            self.btn_FAQ.selected = YES;
            self.btn_QnA.selected = NO;
            [self updateList];
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_FAQ.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointZero;
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
    }
    else
    {
        if( self.btn_QnA.selected == NO )
        {
            self.btn_QnA.selected = YES;
            self.btn_FAQ.selected = NO;
            [self updateList];
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_QnA.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
    }
}

- (IBAction)goWrite:(id)sender
{
    AskingWriteViewController *vc = [[AskingWriteViewController alloc]initWithNibName:@"AskingWriteViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

@end
