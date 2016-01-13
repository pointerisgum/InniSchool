//
//  JoinViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 11..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "JoinViewController.h"

@interface JoinViewController () <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation JoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
    
    self.webView.delegate = self;
    
    NSString *str_Url = [NSString stringWithFormat:@"%@/front/webview/member/wvMemberJoin.do", kBaseUrlHttps];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
    [self.webView loadRequest:request];
    
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"회원가입";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];

    self.navigationController.navigationBarHidden = NO;
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
        
        NSLog(@"%@", jsString);
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"자바스크립트 연동" message:jsString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        //        [alert show];
        
        //        [self callJavaScriptFromObjectiveC];
        //        return NO;
        
    }
    
    return YES;
}

@end
