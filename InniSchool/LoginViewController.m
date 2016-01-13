//
//  LoginViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 4. 27..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginDetailViewController.h"

@interface LoginViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
//@property (nonatomic, weak) IBOutlet UnderLineButton *btn_SignUp;
@property (nonatomic, weak) IBOutlet UIPageControl *pg;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.title = @"111";
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    [self.navigationController.navigationBar setTranslucent:NO];

    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if( [segue.identifier isEqualToString:@"Login"] )
    {
        UIImageView *iv = (UIImageView *)[self.sv_Main viewWithTag:self.pg.currentPage + 1];
        LoginDetailViewController *vc = [segue destinationViewController];
        vc.i_Bg = iv.image;
    }
    else
    {
        
    }
}


- (void)updateList
{
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"member/selectLoginBackgroundImage.do"
                                        param:nil
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            /*
                                             ImgCount = 3;
                                             ImgUrlList =     (
                                             "http://52.68.160.225:80/api/file_upload/login/grace_01.jpg",
                                             "http://52.68.160.225:80/api/file_upload/login/grace_02.jpg",
                                             "http://52.68.160.225:80/api/file_upload/login/grace_03.jpg"
                                             );
                                             */
                                            
                                            self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"ImgUrlList"]];
                                            
                                            self.sv_Main.contentSize = CGSizeMake(self.ar_List.count * self.sv_Main.frame.size.width, 0);
                                            
                                            for( NSInteger i = 0; i < self.ar_List.count; i++ )
                                            {
                                                UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i * self.sv_Main.frame.size.width, 0,
                                                                                                               self.sv_Main.frame.size.width, self.sv_Main.frame.size.height)];
                                                iv.tag = i + 1;
                                                iv.contentMode = UIViewContentModeScaleAspectFill;
                                                iv.clipsToBounds = YES;
                                                [iv setImageWithString:self.ar_List[i] placeholderImage:BundleImage(@"") usingCache:NO];
                                                
                                                [self.sv_Main addSubview:iv];
                                            }
                                        }
                                    }];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger nPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pg.currentPage = nPage;
}

@end
