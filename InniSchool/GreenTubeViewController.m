//
//  GreenTubeViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 7..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GreenTubeViewController.h"
#import "ODRefreshControl.h"
#import "AwesomeMenu.h"
#import "FeedTextCell.h"
#import "FeedImageCell.h"
#import "FeedMovieCell.h"
#import "FeedVoteCell.h"
#import "MWPhotoBrowser.h"
#import "SubTagUIImageView.h"
#import "GreenTubeDetailViewController.h"
#import "GreenTubeWriteViewController.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "GreenTubeSearchViewController.h"
#import "GreenTubeModifyViewController.h"
#import "KILabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

static const NSInteger snFeedEmptyTag = 99;
static const NSInteger snArchiveEmptyTag = 88;
static const NSInteger kMoreListCount = 20;
static const CGFloat kLodingHeight = 100.0f;

typedef NS_ENUM(NSUInteger, ViewMode){
    kFeed,
    kArchive
};

@interface GreenTubeViewController () <UISearchBarDelegate, AwesomeMenuDelegate, UIScrollViewDelegate, MWPhotoBrowserDelegate>
{
    NSInteger nFeedStartRow;
    NSInteger nArchiveStartRow;
}
@property (nonatomic, assign) BOOL isFeedMoreLoading;
@property (nonatomic, assign) BOOL isArchiveMoreLoading;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) ODRefreshControl *refreshControl1;
@property (nonatomic, strong) ODRefreshControl *refreshControl2;
@property (nonatomic, assign) ViewMode viewMode;
@property (nonatomic, strong) AwesomeMenuItem *awesomeView;
@property (nonatomic, strong) NSMutableArray *arM_FeedList;
@property (nonatomic, strong) NSMutableArray *arM_ArchiveList;
@property (nonatomic, strong) NSArray *ar_ColorList;
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableDictionary *kakaoTalkLinkObjects;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bar;
@property (nonatomic, weak) IBOutlet UIButton *btn_Feed;
@property (nonatomic, weak) IBOutlet UIButton *btn_Archive;
@property (nonatomic, weak) IBOutlet UITableView *tbv_FeedList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_ArchiveList;
@end

@implementation GreenTubeViewController

- (void) disableScrollsToTopPropertyOnAllSubviewsOf:(UIView *)view
{
    for (UIView *subview in view.subviews)
    {
        if ([subview isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)subview).scrollsToTop = NO;
        }
        [self disableScrollsToTopPropertyOnAllSubviewsOf:subview];
    }
}

- (void)statusBarClicked
{
    if( self.viewMode == kFeed )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                            
                             self.tbv_FeedList.contentOffset = CGPointZero;
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.tbv_ArchiveList.contentOffset = CGPointZero;
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"그린튜브";
    
    self.isUpdating = self.isFeedMoreLoading = self.isArchiveMoreLoading = NO;
    
    nFeedStartRow = nArchiveStartRow = 1;
    
    self.kakaoTalkLinkObjects = [[NSMutableDictionary alloc] init];
    
    self.refreshControl1 = [[ODRefreshControl alloc] initInScrollView:self.tbv_FeedList];
    self.refreshControl1.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl1 addTarget:self action:@selector(feedRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_FeedList addSubview:self.refreshControl1];
    
    self.refreshControl2 = [[ODRefreshControl alloc] initInScrollView:self.tbv_ArchiveList];
    self.refreshControl2.tintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.refreshControl2 addTarget:self action:@selector(archiveRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tbv_ArchiveList addSubview:self.refreshControl2];
    
//    [self disableScrollsToTopPropertyOnAllSubviewsOf:self.view];
//    self.sv_Main.scrollsToTop = NO;
//////    self.tbv_FeedList.delegate = self;
//////    self.tbv_ArchiveList.delegate = self;
//    self.tbv_FeedList.scrollsToTop = YES;
//    self.tbv_ArchiveList.scrollsToTop = YES;

    //스테터스바 터치 업
    UIView* statusBarInterceptView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    CGRect frame = statusBarInterceptView.frame;
    frame.size.height = 64.0f;
    frame.size.width = frame.size.width / 2;
    statusBarInterceptView.frame = frame;
    
    CGPoint point = statusBarInterceptView.center;
    point.x = self.navigationController.view.center.x;
    statusBarInterceptView.center = point;
    
    statusBarInterceptView.userInteractionEnabled = YES;
//    statusBarInterceptView.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusBarClicked)];
    [statusBarInterceptView addGestureRecognizer:tapRecognizer];
    //    [[[UIApplication sharedApplication].delegate window] addSubview:statusBarInterceptView];
    [self.navigationController.view addSubview:statusBarInterceptView];
    /////////////
    
    
    [self.tbv_FeedList registerClass:FeedImageCell.class forCellReuseIdentifier:@"FeedImageCell"];
    [self.tbv_FeedList registerClass:FeedTextCell.class forCellReuseIdentifier:@"FeedTextCell"];
    [self.tbv_FeedList registerClass:FeedMovieCell.class forCellReuseIdentifier:@"FeedMovieCell"];
    [self.tbv_FeedList registerClass:FeedVoteCell.class forCellReuseIdentifier:@"FeedVoteCell"];
    
    [self.tbv_FeedList registerNib:[UINib nibWithNibName:NSStringFromClass([FeedImageCell class]) bundle:nil] forCellReuseIdentifier:@"FeedImageCell"];
    [self.tbv_FeedList registerNib:[UINib nibWithNibName:NSStringFromClass([FeedTextCell class]) bundle:nil] forCellReuseIdentifier:@"FeedTextCell"];
    [self.tbv_FeedList registerNib:[UINib nibWithNibName:NSStringFromClass([FeedMovieCell class]) bundle:nil] forCellReuseIdentifier:@"FeedMovieCell"];
    [self.tbv_FeedList registerNib:[UINib nibWithNibName:NSStringFromClass([FeedVoteCell class]) bundle:nil] forCellReuseIdentifier:@"FeedVoteCell"];
    
    
    [self.tbv_ArchiveList registerClass:FeedImageCell.class forCellReuseIdentifier:@"FeedImageCell"];
    [self.tbv_ArchiveList registerClass:FeedTextCell.class forCellReuseIdentifier:@"FeedTextCell"];
    [self.tbv_ArchiveList registerClass:FeedMovieCell.class forCellReuseIdentifier:@"FeedMovieCell"];
    [self.tbv_ArchiveList registerClass:FeedVoteCell.class forCellReuseIdentifier:@"FeedVoteCell"];
    
    [self.tbv_ArchiveList registerNib:[UINib nibWithNibName:NSStringFromClass([FeedImageCell class]) bundle:nil] forCellReuseIdentifier:@"FeedImageCell"];
    [self.tbv_ArchiveList registerNib:[UINib nibWithNibName:NSStringFromClass([FeedTextCell class]) bundle:nil] forCellReuseIdentifier:@"FeedTextCell"];
    [self.tbv_ArchiveList registerNib:[UINib nibWithNibName:NSStringFromClass([FeedMovieCell class]) bundle:nil] forCellReuseIdentifier:@"FeedMovieCell"];
    [self.tbv_ArchiveList registerNib:[UINib nibWithNibName:NSStringFromClass([FeedVoteCell class]) bundle:nil] forCellReuseIdentifier:@"FeedVoteCell"];

    
    self.viewMode = kFeed;
    
    [self addAwesomeMenu];
    
    
    self.ar_ColorList = @[@"78588C", @"589079", @"58869B", @"615D71"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadSnsFeed:)
                                                 name:@"ReloadSnsFeed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadOneSnsFeed:)
                                                 name:@"ReloadOneSnsFeed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiRemoveItem:)
                                                 name:@"notiRemoveItem"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiRemoveItemAtFeedIdx:)
                                                 name:@"notiRemoveItemAtFeedIdx"
                                               object:nil];
    
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.sv_Main addGestureRecognizer:swipeLeft];
    [self.sv_Main addGestureRecognizer:swipeRight];
    
    if( self.str_DetailIdx.length > 0 )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
        [dicM_Params setObject:@"0" forKey:@"searchType"];
        [dicM_Params setObject:self.str_DetailIdx forKey:@"snsFeedIdx"];
        
        self.str_DetailIdx = nil;
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsList.do"
                                            param:dicM_Params
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                NSArray *ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"SNSList"]];
                                                if( ar.count > 0 )
                                                {
                                                    NSDictionary *dic = [ar firstObject];
                                                    GreenTubeDetailViewController *vc = [[GreenTubeDetailViewController alloc]initWithNibName:@"GreenTubeDetailViewController" bundle:nil];
                                                    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                            }
                                        }];
    }
    
    [self updateList];
}

- (void)reloadSnsFeed:(NSNotification *)noti
{
    if( self.viewMode == kFeed )
    {
        [self.arM_FeedList removeAllObjects];
        self.arM_FeedList = nil;
        
        nFeedStartRow = 1;
        
        [self updateList];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.tbv_FeedList.contentOffset = CGPointZero;
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    else
    {
        [self.arM_ArchiveList removeAllObjects];
        self.arM_ArchiveList = nil;
        
        nArchiveStartRow = 1;
        
        [self updateList];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.tbv_ArchiveList.contentOffset = CGPointZero;
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)reloadOneSnsFeed:(NSNotification *)noti
{
    [self updateListOneItem:[[noti object] integerValue]];
}

- (void)notiRemoveItem:(NSNotification *)noti
{
    if( self.viewMode == kFeed )
    {
        [self.arM_FeedList removeObjectAtIndex:[[noti object] integerValue]];
        [self.tbv_FeedList reloadData];
    }
    else
    {
        [self.arM_ArchiveList removeObjectAtIndex:[[noti object] integerValue]];
        [self.tbv_ArchiveList reloadData];
    }
}

- (void)notiRemoveItemAtFeedIdx:(NSNotification *)noti
{
    NSInteger nDeleteFeedIdx = [[noti object] integerValue];
    NSMutableArray *arM = nil;
    if( self.viewMode == kFeed )
    {
        arM = [NSMutableArray arrayWithArray:self.arM_FeedList];
    }
    else
    {
        arM = [NSMutableArray arrayWithArray:self.arM_ArchiveList];
    }
    
    for( NSInteger i = 0; i < arM.count; i++ )
    {
        NSDictionary *dic = arM[i];
        NSInteger nFeed = [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue];
        if( nDeleteFeedIdx == nFeed )
        {
            [arM removeObjectAtIndex:i];
            break;
        }
    }
    
    if( self.viewMode == kFeed )
    {
        self.arM_FeedList = [NSMutableArray arrayWithArray:arM];
        [self.tbv_FeedList reloadData];
    }
    else
    {
        self.arM_ArchiveList = [NSMutableArray arrayWithArray:arM];
        [self.tbv_ArchiveList reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNavi];
    
    if( self.viewMode == kFeed )
    {
        self.sv_Main.contentOffset = CGPointZero;
    }
    else
    {
        self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)feedRefresh:(UIRefreshControl *)sender
{
    [self.arM_FeedList removeAllObjects];
    self.arM_FeedList = nil;
    
    nFeedStartRow = 1;
    
    [self updateList];
}

- (void)archiveRefresh:(UIRefreshControl *)sender
{
    [self.arM_ArchiveList removeAllObjects];
    self.arM_ArchiveList = nil;
    
    nArchiveStartRow = 1;
    
    [self updateList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
}

- (void)addAwesomeMenu
{
    //    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    //    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    //
    //    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:BundleImage(@"menu1_text.png")
                                                           highlightedImage:BundleImage(@"menu1_text_p.png")
                                                               ContentImage:nil
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:BundleImage(@"menu2_movie.png")
                                                           highlightedImage:BundleImage(@"menu2_movie_p.png")
                                                               ContentImage:nil
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:BundleImage(@"menu3_photo.png")
                                                           highlightedImage:BundleImage(@"menu3_photo_p.png")
                                                               ContentImage:nil
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem4 = [[AwesomeMenuItem alloc] initWithImage:BundleImage(@"menu4_poll.png")
                                                           highlightedImage:BundleImage(@"menu4_poll_p.png")
                                                               ContentImage:nil
                                                    highlightedContentImage:nil];
    
    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, nil];
    
    self.awesomeView = [[AwesomeMenuItem alloc] initWithImage:BundleImage(@"menu_write.png")
                                             highlightedImage:nil
                                                 ContentImage:nil
                                      highlightedContentImage:nil];
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds startItem:self.awesomeView menuItems:menus];
    menu.delegate = self;
    
    menu.menuWholeAngle = 2.0;
    menu.farRadius = 110.0f;
    menu.endRadius = 100.0f;
    menu.nearRadius = 90.0f;
    menu.animationDuration = 0.3f;
    menu.startPoint = CGPointMake(self.view.center.x, self.view.frame.size.height - 96);
    
    [self.view addSubview:menu];
}

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    self.awesomeView.image = BundleImage(@"menu_write.png");
    for( NSInteger i = 0; i < menu.menuItems.count; i++ )
    {
        UIView *view = menu.menuItems[i];
        view.hidden = YES;
    }
    
    GreenTubeWriteViewController *vc = [[GreenTubeWriteViewController alloc]initWithNibName:@"GreenTubeWriteViewController" bundle:nil];
    
    switch (idx)
    {
        case 0:
            vc.writeMode = kText;
            break;
            
        case 1:
            vc.writeMode = kMovie;
            break;
            
        case 2:
            vc.writeMode = kImage;
            break;
            
        case 3:
            vc.writeMode = kVote;
            break;
            
        default:
            break;
    }
    
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (void)awesomeMenuDidFinishAnimationClose:(AwesomeMenu *)menu
{
    self.awesomeView.image = BundleImage(@"menu_write.png");
    for( NSInteger i = 0; i < menu.menuItems.count; i++ )
    {
        UIView *view = menu.menuItems[i];
        view.hidden = YES;
    }
}

- (void)awesomeMenuDidFinishAnimationOpen:(AwesomeMenu *)menu
{
    self.awesomeView.image = BundleImage(@"menu_close.png");
}

- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    for( NSInteger i = 0; i < menu.menuItems.count; i++ )
    {
        UIView *view = menu.menuItems[i];
        view.hidden = NO;
    }
}

- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
//    NSLog(@"@@@@@@@@@@@");
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //integrationCourseIdx
    
    //    if( [segue.identifier isEqualToString:@"Detail"] )
    //    {
    //        NSIndexPath *indexPath = (NSIndexPath *)sender;
    //        NSDictionary *dic = nil;
    //        if( self.viewMode == kFeed )
    //        {
    //            dic = self.arM_FeedList[indexPath.section];
    //        }
    //        else
    //        {
    //            dic = self.arM_ArchiveList[indexPath.section];
    //        }
    //
    //        StudyDetailViewController *vc = [segue destinationViewController];
    //        vc.dic_Info = dic;
    //    }
}


- (void)initNavi
{
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:self.navigationItem.titleView.frame];
    lb_Title.font = [UIFont fontWithName:@"Helvetica" size:16];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = @"그린튜브";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItemWithWhiteColor:YES];
    self.navigationItem.rightBarButtonItem = [self rightSearchIcon];
}

//네비게이션 서치바 오버라이드
- (void)searchMenuPress:(id)sender
{
    self.searchBar = [[UISearchBar alloc]init];
    [self.searchBar sizeToFit];
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.delegate = self;
    [self performSelector:@selector(onShowKeyboard) withObject:nil afterDelay:0.1f];
    
    self.navigationItem.leftBarButtonItem = [self leftCancelButton];
    self.navigationItem.rightBarButtonItem = [self rightSearchButton];
    
    //    self.searchDisplayController.searchBar.hidden = NO;
    //    self.searchDisplayController.searchBar.showsCancelButton = YES;
    //
    //    self.searchDisplayController.searchBar.barStyle = UIBarStyleBlack;
    //    [self.searchDisplayController setActive:YES animated:YES];
}

- (void)onShowKeyboard
{
    [self.searchBar becomeFirstResponder];
}

- (void)cancelButtonPress:(id)sender
{
    //취소버튼 눌렀을때
    [self initNavi];
}

- (void)searchButtonPress:(id)sender
{
    //검색버튼 눌렀을때
    [self showSearchResultView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self showSearchResultView];
}

- (void)showSearchResultView
{
    if( self.searchBar.text.length > 0 )
    {
        GreenTubeSearchViewController *vc = [[GreenTubeSearchViewController alloc]initWithNibName:@"GreenTubeSearchViewController" bundle:nil];
        vc.str_Keyword = self.searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateList
{
    //http://127.0.0.1:7080/api/sns/selectSnsList.do?userIdx=1004&comBraRIdx=10001&searchType=0&startRowNum=1&endRowNum=20
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    
    if( self.viewMode == kFeed )
    {
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nFeedStartRow] forKey:@"startRowNum"];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nFeedStartRow + kMoreListCount] forKey:@"endRowNum"];
        
        [dicM_Params setObject:@"1" forKey:@"searchType"];
        
        self.sv_Main.contentOffset = CGPointZero;
    }
    else
    {
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nArchiveStartRow] forKey:@"startRowNum"];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nArchiveStartRow + kMoreListCount] forKey:@"endRowNum"];
        
        [dicM_Params setObject:@"2" forKey:@"searchType"];
        
        self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
    }
    
    NSLog(@"웹통신 시작");

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        NSLog(@"웹통신 종료");

                                        UIView *view = (UIView *)[self.tbv_FeedList viewWithTag:snFeedEmptyTag];
                                        [view removeFromSuperview];
                                        
                                        view = (UIView *)[self.tbv_ArchiveList viewWithTag:snArchiveEmptyTag];
                                        [view removeFromSuperview];
                                        
                                        if( resulte )
                                        {
                                            if( self.viewMode == kFeed )
                                            {
                                                NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"SNSList"]];

                                                if( ar.count <= 0 )
                                                {
                                                    self.isFeedMoreLoading = NO;
                                                }
                                                else
                                                {
                                                    self.isFeedMoreLoading = YES;
                                                }

                                                if( self.arM_FeedList == nil || self.arM_FeedList.count <= 0 )
                                                {
                                                    self.arM_FeedList = [NSMutableArray arrayWithArray:ar];
                                                }
                                                else
                                                {
                                                    [self.arM_FeedList addObjectsFromArray:ar];
                                                }
                                                
                                                nFeedStartRow = self.arM_FeedList.count;
                                                nFeedStartRow++;
                                                
                                                if( self.arM_FeedList == nil || self.arM_FeedList.count <= 0 )
                                                {
                                                    [self showFeedEmptyView];
                                                }
                                                
                                                
                                                
                                                
                                                
                                                
                                                NSLog(@"리로드 시작");

                                                [self.tbv_FeedList reloadData];
                                                
                                                NSLog(@"리로드 종료");
                                                
                                                
                                                
                                                
                                                
                                                self.tbv_FeedList.contentSize = CGSizeMake(self.tbv_FeedList.contentSize.width, self.tbv_FeedList.contentSize.height);
                                                
                                                [self.refreshControl1 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                            }
                                            else
                                            {
                                                NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"SNSList"]];

                                                if( ar.count <= 0 )
                                                {
                                                    self.isArchiveMoreLoading = NO;
                                                }
                                                else
                                                {
                                                    self.isArchiveMoreLoading = YES;
                                                }

                                                if( self.arM_ArchiveList == nil || self.arM_ArchiveList.count <= 0 )
                                                {
                                                    self.arM_ArchiveList = [NSMutableArray arrayWithArray:ar];
                                                }
                                                else
                                                {
                                                    [self.arM_ArchiveList addObjectsFromArray:ar];
                                                }
                                                
                                                nArchiveStartRow = self.arM_ArchiveList.count;
                                                nArchiveStartRow++;
                                                
                                                if( self.arM_ArchiveList == nil || self.arM_ArchiveList.count <= 0 )
                                                {
                                                    //수료가 없을때
                                                    [self showArchiveEmptyView];
                                                }
                                                
                                                [self.tbv_ArchiveList reloadData];
                                                
                                                self.tbv_ArchiveList.contentSize = CGSizeMake(self.tbv_ArchiveList.contentSize.width, self.tbv_ArchiveList.contentSize.height);
                                                
                                                [self.refreshControl2 performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
                                            }
                                        }
                                        
                                        self.isUpdating = NO;
                                        
                                    }];
}

- (void)showFeedEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FeedEmpty" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snFeedEmptyTag;
    view.center = self.tbv_FeedList.center;
    [self.tbv_FeedList addSubview:view];
}

- (void)showArchiveEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ArchiveEmpty" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snArchiveEmptyTag;
    view.center = self.tbv_FeedList.center;
    [self.tbv_ArchiveList addSubview:view];
}


#pragma mark - UIGesture
- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    
    [self.view endEditing:YES];
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if( self.viewMode == kFeed )
        {
            [self goMenuToggle:self.btn_Archive];
        }
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if( self.viewMode == kArchive )
        {
            [self goMenuToggle:self.btn_Feed];
        }
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%f : %f", scrollView.contentOffset.y + self.tbv_FeedList.frame.size.height, self.tbv_FeedList.contentSize.height);
    
    if( self.viewMode == kFeed )
    {
        if( scrollView.contentOffset.y + self.tbv_FeedList.frame.size.height > self.tbv_FeedList.contentSize.height - kLodingHeight )
        {
            if( self.isUpdating == NO )
            {
                if( self.isFeedMoreLoading== NO )
                {
                    return;
                }
                
                self.isUpdating = YES;
                [self updateList];
            }
        }
    }
    else
    {
        if( scrollView.contentOffset.y + self.tbv_ArchiveList.frame.size.height > self.tbv_ArchiveList.contentSize.height - kLodingHeight )
        {
            if( self.isUpdating == NO )
            {
                if( self.isArchiveMoreLoading == NO )
                {
                    return;
                }
                
                self.isUpdating = YES;
                [self updateList];
            }
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.awesomeView.alpha = NO;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if( scrollView.contentOffset.y > scrollView.contentSize.height - self.tbv_FeedList.frame.size.height - 20 )
//    {
//        if( self.isUpdating == NO )
//        {
//            self.isUpdating = YES;
//            [self updateList];
//        }
//    }


    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.awesomeView.alpha = YES;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( self.viewMode == kFeed )
    {
        return self.arM_FeedList.count;
    }
    else
    {
        return self.arM_ArchiveList.count;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     CateCodeIdx = 1000;
     CateName = "\Uacf5\Uac10\Uc218\Ub2e4";
     ComNM = "\Ud14c\Uc2a4\Ud2b8 \Ub9e4\Uc7a51";
     ContentType = "<null>";
     DeletableYN = N;
     DeptName = "<null>";
     DiffTime = 0;
     DutiesPositionParentIdx = 200;
     EditDate = "<null>";
     EditableYN = N;
     FullImgURL = "";
     ImgURL = "<null>";
     NameKR = testmember5;
     PollExistYN = N;
     PollParticipantCNT = 0;
     PolledYN = N;
     RegDate = 20150507092854;
     RegUserIDX = 1008;
     ResultViewYN = 504;
     SNSArchivingYN = N;
     SNSAttachList =             (
     );
     SNSCommentCNT = 0;
     SNSContent = "\Ud14c\Uc2a4\Ud2b8\Uc785\Ub2c8\Ub2f9";
     SNSFavoriteCNT = 0;
     SNSFavoriteYN = N;
     SNSFeedIdx = 15;
     SNSPollList =             (
     );
     SNSReportedYN = N;
     SNSTagList =             (
     );
     SNSViewCNT = "<null>";
     Title = "<null>";
     */
    
    
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[indexPath.section];
    }
    else
    {
        dic = self.arM_ArchiveList[indexPath.section];
    }
    
    
    NSInteger nContentType = [[dic objectForKey_YM:@"ContentType"] integerValue];
    switch (nContentType)
    {
        case 1002:
            //이미지
        {
            static NSString *CellIdentifier = @"FeedImageCell";
            FeedImageCell *cell = (FeedImageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            if (cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            cell.tag = indexPath.section;
            [self setCellDefaultData:cell withData:dic];
            
            for( id subView in cell.sv_Thumbs.subviews )
            {
                if( [subView isKindOfClass:[UIImageView class]] )
                {
                    UIImageView *iv = (UIImageView *)subView;
                    if( iv.tag > 0 )
                    {
                        [iv removeFromSuperview];
                    }
                }
            }
            
            NSArray *ar_ImageList = [dic objectForKey:@"SNSAttachList"];
            for( NSInteger i = 0; i < ar_ImageList.count; i++ )
            {
                NSDictionary *dic_Image = ar_ImageList[i];
                NSInteger nType = [[dic_Image objectForKey_YM:@"AttachType"] integerValue];
                if( nType == 1002 )
                {
                    SubTagUIImageView *iv = [[SubTagUIImageView alloc]initWithFrame:CGRectMake(i * (cell.sv_Thumbs.frame.size.width), 0,
                                                                                               cell.sv_Thumbs.frame.size.width - 4, cell.sv_Thumbs.frame.size.height)];
                    iv.tag = i + 1;
                    iv.userInteractionEnabled = YES;
                    iv.nSubTag = indexPath.section;
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    
                    NSString *str_ImageUrl = [dic_Image objectForKey_YM:@"AttachFileFullURL_I"];
//                    [iv setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
                    
//                    iv.backgroundColor = [UIColor whiteColor];
                    iv.image = BundleImage(@"loading.png");
//                    [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] placeholderImage:BundleImage(@"no_thumbnail.png")];

                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    [manager downloadImageWithURL:[NSURL URLWithString:str_ImageUrl]
                                          options:0
                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                             
                                         } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                             
                                             iv.image = image;
                                         }];
                    
                    

                    
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
                    [singleTap setNumberOfTapsRequired:1];
                    [iv addGestureRecognizer:singleTap];
                    
                    [cell.sv_Thumbs addSubview:iv];
                }
            }
            
            cell.sv_Thumbs.contentSize = CGSizeMake(cell.sv_Thumbs.frame.size.width * ar_ImageList.count, 0);
            
            
//            CGRect frame = cell.lb_Contents.frame;
//            frame.size.height = [Util getTextSize:cell.lb_Contents].height;
//            cell.lb_Contents.frame = frame;
//            
//            frame = cell.v_Contents.frame;
//            frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
//            cell.v_Contents.frame = frame;
//            
//            frame = cell.v_BottomMenu.frame;
//            frame.origin.y = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 8;
//            cell.v_BottomMenu.frame = frame;
            
            return cell;
        }
            
        case 1003:
            //동영상
        {
            static NSString *CellIdentifier = @"FeedMovieCell";
            FeedMovieCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            if (cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            cell.tag = indexPath.section;
            [self setCellDefaultData:cell withData:dic];
            //VODThumnailURL
            NSArray *ar_ImageList = [dic objectForKey:@"SNSAttachList"];
            if( ar_ImageList.count > 0 )
            {
                NSDictionary *dic_MovieInfo = [ar_ImageList firstObject];
                NSInteger nType = [[dic_MovieInfo objectForKey_YM:@"AttachType"] integerValue];
                if( nType == 1003 )
                {
                    cell.btn_Movie.tag = indexPath.section;
                    
                    NSString *str_ImageUrl = [dic_MovieInfo objectForKey_YM:@"VODThumnailURL"];
//                    [cell.iv_MovieThumb setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
                    
                    
                    [cell.iv_MovieThumb sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] placeholderImage:BundleImage(@"no_thumbnail.png")];

                    
                    
                    
                    [cell.btn_Movie addTarget:self action:@selector(onMovie:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            
            
//            CGRect frame = cell.lb_Contents.frame;
//            frame.size.height = [Util getTextSize:cell.lb_Contents].height;
//            cell.lb_Contents.frame = frame;
//            
//            frame = cell.v_Contents.frame;
//            frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
//            cell.v_Contents.frame = frame;
//            
//            frame = cell.v_BottomMenu.frame;
//            frame.origin.y = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 8;
//            cell.v_BottomMenu.frame = frame;
            
            return cell;
        }
            
        case 1004:
            //투표
        {
            static NSString *CellIdentifier = @"FeedVoteCell";
            FeedVoteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            if (cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            cell.tag = indexPath.section;
            [self setCellDefaultData:cell withData:dic];
            
            NSArray *ar_VoteList = [dic objectForKey_YM:@"SNSPollList"];
            if( ar_VoteList.count > 0 )
            {
                CGRect frame = cell.lb_Contents.frame;
                frame.size.height = [Util getTextSize:cell.lb_Contents].height;
                cell.lb_Contents.frame = frame;
                
                
                cell.lb_Qeustion.text = [dic objectForKey_YM:@"Title"];
                cell.lb_QeustionInPeople.text = [NSString stringWithFormat:@"총 %ld명 참여중", [[dic objectForKey_YM:@"PollParticipantCNT"] integerValue]];
                
                
                CGFloat fQeustionHeight = [Util getTextSize:cell.lb_Qeustion].height;
                CGFloat fQeustionInPeopleHeight = [Util getTextSize:cell.lb_QeustionInPeople].height;
                
                frame = cell.lb_Qeustion.frame;
                frame.size.height = fQeustionHeight;
                cell.lb_Qeustion.frame = frame;
                
                frame = cell.lb_QeustionInPeople.frame;
                frame.origin.y = cell.lb_Qeustion.frame.origin.y + cell.lb_Qeustion.frame.size.height + 8;
                frame.size.height = fQeustionInPeopleHeight;
                cell.lb_QeustionInPeople.frame = frame;
                
                frame = cell.iv_Line.frame;
                frame.size.height = (cell.lb_QeustionInPeople.frame.origin.y + cell.lb_QeustionInPeople.frame.size.height) - cell.lb_Qeustion.frame.origin.y;
                cell.iv_Line.frame = frame;
                
                frame = cell.v_QeustionBg.frame;
                frame.size.height = cell.lb_QeustionInPeople.frame.origin.y + cell.lb_QeustionInPeople.frame.size.height + 20;
                cell.v_QeustionBg.frame = frame;
                
                frame = cell.v_Contents.frame;
                frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
                frame.size.height = cell.v_QeustionBg.frame.size.height;
                cell.v_Contents.frame = frame;
                
                frame = cell.v_BottomMenu.frame;
                frame.origin.y = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 8;
                cell.v_BottomMenu.frame = frame;
            }
            
            return cell;
        }
            
        default:
        {
            //디폴트는 텍스트로 했다 (타입이 널로 넘어오는게 있음....흠...)
            static NSString *CellIdentifier = @"FeedTextCell";
            FeedTextCell *cell = (FeedTextCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            if (cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            cell.tag = indexPath.section;
            [self setCellDefaultData:cell withData:dic];
            
//            CGRect frame = cell.lb_Contents.frame;
//            frame.size.height = [Util getTextSize:cell.lb_Contents].height;
//            cell.lb_Contents.frame = frame;
//            
//            frame = cell.v_BottomMenu.frame;
//            frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
//            cell.v_BottomMenu.frame = frame;
            
            return cell;
        }
    }
    
    
    return nil;
}

- (void)profileTap:(UIGestureRecognizer *)gesture
{
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[gesture.view.tag];
    }
    else
    {
        dic = self.arM_ArchiveList[gesture.view.tag];
    }
    
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ShowUserInfo" owner:self options:nil];
    ShowUserInfo *view = [topLevelObjects objectAtIndex:0];
    view.str_Idx = [dic objectForKey_YM:@"RegUserIDX"];
    [view updateList];
    
    view.alpha = NO;
    
    view.v_Container.center = self.navigationController.view.center;
    
    [self.navigationController.view addSubview:view];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         view.alpha = YES;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)setCellDefaultData:(FeedTextCell *)cell withData:(NSDictionary *)dic
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 5.0f;
    
    cell.btn_Menu.tag = cell.btn_CmtCnt.tag = cell.btn_LikeCnt.tag = cell.btn_KakaoShare.tag = cell.tag;
    
    
    //작성자 이미지
    NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
//    [cell.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_middle2.png") usingCache:NO];
    
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] placeholderImage:BundleImage(@"thumbnail_middle2.png")];

    
    cell.iv_User.userInteractionEnabled = YES;
    cell.iv_User.tag = cell.tag;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTap:)];
    [tap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:tap];
    
    
    //작성자 이름
    cell.lb_Writer.text = [dic objectForKey_YM:@"NameKR"];
    
    
    //매장명
    NSString *str_StoreName = @"";
    
    NSInteger nDutiesPositionParentIdx = [[dic objectForKey_YM:@"DutiesPositionParentIdx"] integerValue];
    if( nDutiesPositionParentIdx == 1000 )
    {
        NSString *str_Dept = [dic objectForKey_YM:@"DeptName"];
        if( str_Dept == nil )
        {
            str_StoreName = [dic objectForKey_YM:@"DeptNM"];
        }
        
        if( str_Dept.length > 0 )
        {
            str_StoreName = str_Dept;
        }
        else
        {
            str_StoreName = @"본사";
        }
    }
    else
    {
        str_StoreName = [dic objectForKey_YM:@"ComNM"];
    }

//    NSString *str_StoreName = [dic objectForKey_YM:@"ComNM"];
    
    NSInteger nWriteTime = [[dic objectForKey_YM:@"DiffTime"] integerValue];
    NSString *str_WriteTime = @"";
    
    
    if( nWriteTime > (60 * 60 * 24) )
    {
        //하루 보다 클 경우엔 날짜 풀로 표시
        NSString *str_Time = [dic objectForKey_YM:@"RegDate"];
        if( str_Time.length > 8 )
        {
            str_Time = [str_Time substringWithRange:NSMakeRange(0, 8)];
        }
        
        str_WriteTime = [Util makeDate:str_Time]; //[dic objectForKey_YM:@"RegDate"];
    }
    else
    {
        if( nWriteTime <= 0 )
        {
            str_WriteTime = @"1초전";
        }
        else if( nWriteTime < 60 )
        {
            //1분보다 작을 경우
            str_WriteTime = [NSString stringWithFormat:@"%ld초전", nWriteTime];
        }
        else if( nWriteTime < (60 * 60) )
        {
            //1시간보다 작을 경우
            str_WriteTime = [NSString stringWithFormat:@"%ld분전", nWriteTime / 60];
        }
        else
        {
            str_WriteTime = [NSString stringWithFormat:@"%ld시간전", ((nWriteTime / 60) / 60)];
        }
    }
    
    cell.lb_WriterDesc.text = [NSString stringWithFormat:@"%@ | %@", str_StoreName, str_WriteTime];
    
    
    [cell.btn_Menu addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    //카테고리
    //    NSInteger nCateIdx = [[dic objectForKey_YM:@"CateCodeIdx"] integerValue];
    //    NSInteger nColorIdx = nCateIdx * 0.001;
    //    NSString *str_CateRgb = @"";
    //    if( nColorIdx >= 1 && nColorIdx <= 4 )
    //    {
    //        str_CateRgb = self.ar_ColorList[nColorIdx - 1];
    //    }
    //    else
    //    {
    //        str_CateRgb = @"68AB59";
    //
    //    }
    //    cell.lb_Category.backgroundColor = [UIColor colorWithHexString:str_CateRgb];
    NSInteger nCateIdx = [[dic objectForKey_YM:@"CateCodeIdx"] integerValue];
    switch (nCateIdx)
    {
        case 1000:
            cell.iv_Type.image = BundleImage(@"ribon_greentube_001.png");
            break;
            
        case 2000:
            cell.iv_Type.image = BundleImage(@"ribon_greentube_003.png");
            break;
            
        case 3000:
            cell.iv_Type.image = BundleImage(@"ribon_greentube_002.png");
            break;
            
        case 4000:
            cell.iv_Type.image = BundleImage(@"ribon_greentube_004.png");
            break;
            
        default:
            if( nCateIdx >= 4000 && nCateIdx < 5000 )
            {
                cell.iv_Type.image = BundleImage(@"ribon_greentube_004.png");
            }
            break;
    }
    
    cell.lb_Category.text = [dic objectForKey_YM:@"CateName"];
    
    
    //보라(공감) 78588C
    //파랑(이니뉴스)  58869B
    //녹색    589079
    //진한보라  615D71
    
    
    //내용
    //    cell.lb_Contents.text = [dic objectForKey_YM:@"SNSContent"];
    
    
    NSString *str_Contents = [dic objectForKey_YM:@"SNSContent"];
    NSString *br = @"\n";
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
    cell.lb_Contents.text = [str_Contents gtm_stringByUnescapingFromHTML];
    
    cell.lb_Contents.systemURLStyle = YES;
    //    cell.lb_Contents.linkDetectionTypes = KILinkTypeOptionURL;
    cell.lb_Contents.linkDetectionTypes = KILinkTypeOptionNone;
    
    //    cell.lb_Contents.urlLinkTapHandler = nil;
    cell.lb_Contents.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        // Open URLs
        [self attemptOpenURL:[NSURL URLWithString:string]];
    };
    
    //조회수
    [cell.btn_ViewCnt setTitle:[NSString stringWithFormat:@" %ld", [[dic objectForKey_YM:@"SNSViewCNT"] integerValue]] forState:UIControlStateNormal];
    
    
    //댓글수
    [cell.btn_CmtCnt setTitle:[NSString stringWithFormat:@" %ld", [[dic objectForKey_YM:@"SNSCommentCNT"] integerValue]] forState:UIControlStateNormal];
    //    [cell.btn_CmtCnt addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];
    cell.btn_CmtCnt.userInteractionEnabled = NO;
    
    //좋아요수
    [cell.btn_LikeCnt setTitle:[NSString stringWithFormat:@" %ld", [[dic objectForKey_YM:@"SNSFavoriteCNT"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_LikeCnt addTarget:self action:@selector(onLike:) forControlEvents:UIControlEventTouchUpInside];
    NSString *str_LikeYn = [dic objectForKey_YM:@"SNSFavoriteYN"];
    if( [str_LikeYn isEqualToString:@"Y"] )
    {
        [cell.btn_LikeCnt setImage:BundleImage(@"icon_conbottom_heart_s.png") forState:UIControlStateNormal];
    }
    else
    {
        [cell.btn_LikeCnt setImage:BundleImage(@"icon_conbottom_heart.png") forState:UIControlStateNormal];
    }
    
    //카톡 함수포인터 설정
    [cell.btn_KakaoShare addTarget:self action:@selector(onKakao:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //태그
    NSMutableString *strM_Tag = [NSMutableString string];
    NSArray *ar_Tag = [dic objectForKey:@"SNSTagList"];
    for( NSInteger i = 0; i < ar_Tag.count; i++ )
    {
        NSDictionary *dic_Tag = ar_Tag[i];
        [strM_Tag appendFormat:@"#"];
        [strM_Tag appendString:[dic_Tag objectForKey_YM:@"TagKeyword"]];
        [strM_Tag appendString:@" "];
    }
    
    if( [strM_Tag hasSuffix:@" "] )
    {
        [strM_Tag deleteCharactersInRange:NSMakeRange([strM_Tag length]-1, 1)];
    }
    
    cell.lb_Tag.text = strM_Tag;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[indexPath.section];
    }
    else
    {
        dic = self.arM_ArchiveList[indexPath.section];
    }
    
    GreenTubeDetailViewController *vc = [[GreenTubeDetailViewController alloc]initWithNibName:@"GreenTubeDetailViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    vc.str_Row = [NSString stringWithFormat:@"%ld", indexPath.section];
    vc.nIntoMode = self.viewMode == kFeed ? 1 : 2;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[indexPath.section];
    }
    else
    {
        dic = self.arM_ArchiveList[indexPath.section];
    }
    
    
    NSInteger nContentType = [[dic objectForKey_YM:@"ContentType"] integerValue];
    switch (nContentType)
    {
        case 1002:
            //이미지
        {
            return 342.0f;
        }
            
        case 1003:
            //동영상
        {
            return 365.0f;
        }
            
        case 1004:
            //투표
        {
            static NSString *CellIdentifier = @"FeedVoteCell";
            FeedVoteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            NSArray *ar_VoteList = [dic objectForKey_YM:@"SNSPollList"];
            if( ar_VoteList.count > 0 )
            {
                CGRect frame = cell.lb_Contents.frame;
                frame.size.height = [Util getTextSize:cell.lb_Contents].height;
                cell.lb_Contents.frame = frame;
                
                
                cell.lb_Qeustion.text = [dic objectForKey_YM:@"Title"];
                cell.lb_QeustionInPeople.text = [NSString stringWithFormat:@"총 %ld명 참여중", [[dic objectForKey_YM:@"PollParticipantCNT"] integerValue]];
                
                
                CGFloat fQeustionHeight = [Util getTextSize:cell.lb_Qeustion].height;
                CGFloat fQeustionInPeopleHeight = [Util getTextSize:cell.lb_QeustionInPeople].height;
                
                frame = cell.lb_Qeustion.frame;
                frame.size.height = fQeustionHeight;
                cell.lb_Qeustion.frame = frame;
                
                frame = cell.lb_QeustionInPeople.frame;
                frame.origin.y = cell.lb_Qeustion.frame.origin.y + cell.lb_Qeustion.frame.size.height + 8;
                frame.size.height = fQeustionInPeopleHeight;
                cell.lb_QeustionInPeople.frame = frame;
                
                frame = cell.iv_Line.frame;
                frame.size.height = (cell.lb_QeustionInPeople.frame.origin.y + cell.lb_QeustionInPeople.frame.size.height) - cell.lb_Qeustion.frame.origin.y;
                cell.iv_Line.frame = frame;
                
                frame = cell.v_QeustionBg.frame;
                frame.size.height = cell.lb_QeustionInPeople.frame.origin.y + cell.lb_QeustionInPeople.frame.size.height + 20;
                cell.v_QeustionBg.frame = frame;
                
                frame = cell.v_Contents.frame;
                frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
                frame.size.height = cell.v_QeustionBg.frame.size.height;
                cell.v_Contents.frame = frame;
                
                frame = cell.v_BottomMenu.frame;
                frame.origin.y = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 8;
                cell.v_BottomMenu.frame = frame;
                
                return cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
            }
            
            return 0;
        }
            
        default:
        {
            return 203.0f;
        }
    }

    
    
//    NSDictionary *dic = nil;
//    if( self.viewMode == kFeed )
//    {
//        dic = self.arM_FeedList[indexPath.section];
//    }
//    else
//    {
//        dic = self.arM_ArchiveList[indexPath.section];
//    }
//    
//    
//    NSInteger nContentType = [[dic objectForKey_YM:@"ContentType"] integerValue];
//    switch (nContentType)
//    {
//            //        case 1001:
//            //        {
//            //            //텍스트
//            //        }
//            //            break;
//            
//        case 1002:
//            //이미지
//        {
//            //            NSLog(@"SSSS");
//            //            FeedImageCell *cell = (FeedImageCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//            static NSString *CellIdentifier = @"FeedImageCell";
//            FeedImageCell *cell = (FeedImageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            
//            if (cell == nil)
//            {
//                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
//                cell = [topLevelObjects objectAtIndex:0];
//            }
//            //            NSLog(@"EEEE");
//            //            cell.lb_Contents.text = [dic objectForKey_YM:@"SNSContent"];
//            
//            NSString *str_Contents = [dic objectForKey_YM:@"SNSContent"];
//            NSString *br = @"\n";
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
//            cell.lb_Contents.text = [str_Contents gtm_stringByUnescapingFromHTML];
//            
//            
//            CGRect frame = cell.lb_Contents.frame;
//            frame.size.height = [Util getTextSize:cell.lb_Contents].height;
//            cell.lb_Contents.frame = frame;
//            
//            frame = cell.v_Contents.frame;
//            frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
//            cell.v_Contents.frame = frame;
//            
//            frame = cell.v_BottomMenu.frame;
//            frame.origin.y = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 8;
//            cell.v_BottomMenu.frame = frame;
//            
//            return cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
//        }
//            
//        case 1003:
//            //동영상
//        {
//            //            NSLog(@"SSSS");
//            //            FeedMovieCell *cell = (FeedMovieCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//            static NSString *CellIdentifier = @"FeedMovieCell";
//            FeedMovieCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            
//            if (cell == nil)
//            {
//                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
//                cell = [topLevelObjects objectAtIndex:0];
//            }
//            //            NSLog(@"EEEE");
//            
//            //            cell.lb_Contents.text = [dic objectForKey_YM:@"SNSContent"];
//            
//            NSString *str_Contents = [dic objectForKey_YM:@"SNSContent"];
//            NSString *br = @"\n";
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
//            cell.lb_Contents.text = [str_Contents gtm_stringByUnescapingFromHTML];
//            
//            
//            CGRect frame = cell.lb_Contents.frame;
//            frame.size.height = [Util getTextSize:cell.lb_Contents].height;
//            cell.lb_Contents.frame = frame;
//            
//            frame = cell.v_Contents.frame;
//            frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
//            cell.v_Contents.frame = frame;
//            
//            frame = cell.v_BottomMenu.frame;
//            frame.origin.y = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 8;
//            cell.v_BottomMenu.frame = frame;
//            
//            return cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
//        }
//            
//        case 1004:
//            //투표
//        {
//            //            FeedVoteCell *cell = (FeedVoteCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//            static NSString *CellIdentifier = @"FeedVoteCell";
//            FeedVoteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            
//            if (cell == nil)
//            {
//                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
//                cell = [topLevelObjects objectAtIndex:0];
//            }
//            
//            NSArray *ar_VoteList = [dic objectForKey_YM:@"SNSPollList"];
//            if( ar_VoteList.count > 0 )
//            {
//                CGRect frame = cell.lb_Contents.frame;
//                frame.size.height = [Util getTextSize:cell.lb_Contents].height;
//                cell.lb_Contents.frame = frame;
//                
//                
//                cell.lb_Qeustion.text = [dic objectForKey_YM:@"Title"];
//                cell.lb_QeustionInPeople.text = [NSString stringWithFormat:@"총 %ld명 참여중", [[dic objectForKey_YM:@"PollParticipantCNT"] integerValue]];
//                
//                
//                CGFloat fQeustionHeight = [Util getTextSize:cell.lb_Qeustion].height;
//                CGFloat fQeustionInPeopleHeight = [Util getTextSize:cell.lb_QeustionInPeople].height;
//                
//                frame = cell.lb_Qeustion.frame;
//                frame.size.height = fQeustionHeight;
//                cell.lb_Qeustion.frame = frame;
//                
//                frame = cell.lb_QeustionInPeople.frame;
//                frame.origin.y = cell.lb_Qeustion.frame.origin.y + cell.lb_Qeustion.frame.size.height + 8;
//                frame.size.height = fQeustionInPeopleHeight;
//                cell.lb_QeustionInPeople.frame = frame;
//                
//                frame = cell.iv_Line.frame;
//                frame.size.height = (cell.lb_QeustionInPeople.frame.origin.y + cell.lb_QeustionInPeople.frame.size.height) - cell.lb_Qeustion.frame.origin.y;
//                cell.iv_Line.frame = frame;
//                
//                frame = cell.v_QeustionBg.frame;
//                frame.size.height = cell.lb_QeustionInPeople.frame.origin.y + cell.lb_QeustionInPeople.frame.size.height + 20;
//                cell.v_QeustionBg.frame = frame;
//                
//                frame = cell.v_Contents.frame;
//                frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
//                frame.size.height = cell.v_QeustionBg.frame.size.height;
//                cell.v_Contents.frame = frame;
//                
//                frame = cell.v_BottomMenu.frame;
//                frame.origin.y = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 8;
//                cell.v_BottomMenu.frame = frame;
//                
//                return cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
//            }
//            
//            return 0;
//        }
//            
//        default:
//        {
//            //디폴트는 텍스트로 했다 (타입이 널로 넘어오는게 있음....흠...)
//            
//            //            NSLog(@"SSSS");
//            //            FeedTextCell *cell = (FeedTextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//            static NSString *CellIdentifier = @"FeedTextCell";
//            FeedTextCell *cell = (FeedTextCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            
//            if (cell == nil)
//            {
//                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
//                cell = [topLevelObjects objectAtIndex:0];
//            }
//            //            NSLog(@"EEEE");
//            
//            
//            
//            
//            //            cell.lb_Contents.text = [dic objectForKey_YM:@"SNSContent"];
//            
//            NSString *str_Contents = [dic objectForKey_YM:@"SNSContent"];
//            NSString *br = @"\n";
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
//            cell.lb_Contents.text = [str_Contents gtm_stringByUnescapingFromHTML];
//            
//            
//            CGRect frame = cell.lb_Contents.frame;
//            frame.size.height = [Util getTextSize:cell.lb_Contents].height;
//            cell.lb_Contents.frame = frame;
//            
//            frame = cell.v_BottomMenu.frame;
//            frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
//            cell.v_BottomMenu.frame = frame;
//            
//            return cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
//        }
//    }
    
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (void)attemptOpenURL:(NSURL *)url
{
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        ALERT_ONE(@"링크를 열 수 없습니다");
    }
}


#pragma mark - UIGesture
- (void)imageTap:(UIGestureRecognizer *)gestureRecognizer
{
    SubTagUIImageView *iv = (SubTagUIImageView *)gestureRecognizer.view;
    
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[iv.nSubTag];
    }
    else
    {
        dic = self.arM_ArchiveList[iv.nSubTag];
    }
    
    GreenTubeDetailViewController *vc = [[GreenTubeDetailViewController alloc]initWithNibName:@"GreenTubeDetailViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    vc.str_Row = [NSString stringWithFormat:@"%ld", iv.nSubTag];
    [self.navigationController pushViewController:vc animated:YES];
    
    
    
    //    //nSubTag는 index.section값
    //    //tag는 이미지 순서값
    //    SubTagUIImageView *iv = (SubTagUIImageView *)gestureRecognizer.view;
    //
    //    self.ar_Photo = [NSMutableArray array];
    //    self.thumbs = [NSMutableArray array];
    //
    //    NSDictionary *dic = nil;
    //    if( self.viewMode == kFeed )
    //    {
    //        dic = self.arM_FeedList[iv.nSubTag];
    //    }
    //    else
    //    {
    //        dic = self.arM_ArchiveList[iv.nSubTag];
    //    }
    //
    //    NSArray *ar_Thumbs = [dic objectForKey:@"SNSAttachList"];
    //
    //
    //    NSMutableArray *arM_Url = [NSMutableArray array];
    //    for( NSInteger i = 0; i < ar_Thumbs.count; i++ )
    //    {
    //        NSDictionary *dic = ar_Thumbs[i];
    //        NSString *str_Url = [dic objectForKey_YM:@"AttachFileFullURL_I"];
    //        if( [str_Url hasSuffix:@"api"] == NO )
    //        {
    //            [arM_Url addObject:dic];
    //        }
    //    }
    //
    //    NSInteger nImageCnt = arM_Url.count;
    //    for( NSInteger i = 0; i < nImageCnt; i++ )
    //    {
    //        NSDictionary *dic_ImageInfo = arM_Url[i];
    //        [self.thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dic_ImageInfo valueForKey:@"AttachFileFullURL_I"]]]];
    //        [self.ar_Photo addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dic_ImageInfo valueForKey:@"AttachFileFullURL_I"]]]];
    //    }
    //
    //    BOOL displayActionButton = NO;
    //    BOOL displaySelectionButtons = NO;
    //    BOOL displayNavArrows = YES;
    //    BOOL enableGrid = YES;
    //    BOOL startOnGrid = NO;
    //
    //    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    //    browser.displayActionButton = displayActionButton;
    //    browser.displayNavArrows = displayNavArrows;
    //    browser.displaySelectionButtons = displaySelectionButtons;
    //    browser.alwaysShowControls = displaySelectionButtons;
    //    browser.zoomPhotosToFill = YES;
    //#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    //    browser.wantsFullScreenLayout = YES;
    //#endif
    //    browser.enableGrid = enableGrid;
    //    browser.startOnGrid = startOnGrid;
    //    browser.enableSwipeToDismiss = YES;
    //    [browser setCurrentPhotoIndex:iv.tag - 1];
    //
    //
    //    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    //    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    [self presentViewController:nc animated:YES completion:nil];
    //
    //    // Release
    //
    //    // Test reloading of data after delay
    //    double delayInSeconds = 3;
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //
    //    });
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


#pragma mark - IBAction
- (IBAction)goMenuToggle:(id)sender
{
    if( sender == self.btn_Feed )
    {
        if( self.btn_Feed.selected == NO )
        {
            self.btn_Feed.selected = YES;
            self.btn_Archive.selected = NO;
            self.viewMode = kFeed;
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_Feed.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointZero;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self feedRefresh:nil];//삭제 이슈 때문에 리프레쉬 함 피드에도 있고 아카이브에도 있을시 꼬임 (시간 들여서 잘풀면 되긴 하지만 시간이 없음)
                                 
                             }];
        }
    }
    else
    {
        if( self.btn_Archive.selected == NO )
        {
            self.btn_Archive.selected = YES;
            self.btn_Feed.selected = NO;
            self.viewMode = kArchive;
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 
                                 self.iv_Bar.center = CGPointMake(self.btn_Archive.center.x, self.iv_Bar.center.y);
                                 self.sv_Main.contentOffset = CGPointMake(self.sv_Main.frame.size.width, 0);
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self archiveRefresh:nil];
                                 
                             }];
        }
    }
}

- (void)onMenu:(UIButton *)btn
{
    //내 글일때
    //수정, 삭제, 아카이빙/아카이빙취소
    
    //남의 글일때
    //신고, 아카이빙/아카이빙취소
    
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[btn.tag];
    }
    else
    {
        dic = self.arM_ArchiveList[btn.tag];
    }
    
    NSMutableArray *arM_Menus = [NSMutableArray array];
    
    NSInteger nWriterIdx = [[dic objectForKey_YM:@"RegUserIDX"] integerValue];
    NSInteger nMyIdx = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] integerValue];
    __block BOOL isMyContents = NO;
    if( nWriterIdx == nMyIdx )
    {
        //내 글
        isMyContents = YES;
        
        [arM_Menus addObject:@"수정"];
        [arM_Menus addObject:@"삭제"];
    }
    else
    {
        //남의 글
        [arM_Menus addObject:@"신고"];
    }
    
    
    NSString *str_IsArcive = [dic objectForKey_YM:@"SNSArchivingYN"];
    __block BOOL isArcive = NO;
    if( [str_IsArcive isEqualToString:@"Y"] )
    {
        //아카이브 한거
        isArcive = YES;
        
        [arM_Menus addObject:@"보관함에서 삭제"];
    }
    else
    {
        //아카이브 안한건
        [arM_Menus addObject:@"보관하기"];
    }
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM_Menus
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( isMyContents )
         {
             if( buttonIndex == 0 )
             {
                 //수정 로직
                 GreenTubeModifyViewController *vc = [[GreenTubeModifyViewController alloc]initWithNibName:@"GreenTubeModifyViewController" bundle:nil];
                 UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
                 vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]];
                 vc.str_Row = [NSString stringWithFormat:@"%ld", btn.tag];
                 
                 [self presentViewController:navi animated:YES completion:^{
                     
                 }];
             }
             else if( buttonIndex == 1 )
             {
                 //삭제 로직
                 UIAlertView *alert = CREATE_ALERT(nil, @"삭제하시겠습니까?", @"예", @"아니요");
                 [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                     
                     if( buttonIndex == 0 )
                     {
                         //http://127.0.0.1:7080/api/sns/deleteSnsPost.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1
                         //
                         NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                         [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
                         [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
                         [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
                         
                         [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/deleteSnsPost.do"
                                                             param:dicM_Params
                                                         withBlock:^(id resulte, NSError *error) {
                                                             
                                                             [GMDCircleLoader hide];
                                                             
                                                             if( resulte )
                                                             {
                                                                 NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                                 switch (nCode)
                                                                 {
                                                                     case 1:
                                                                         [self.navigationController.view makeToast:@"삭제 되었습니다"];
                                                                         break;
                                                                         
                                                                     default:
                                                                         [self.navigationController.view makeToast:@"오류"];
                                                                         break;
                                                                 }
                                                                 
                                                                 if( self.viewMode == kFeed )
                                                                 {
                                                                     [self.arM_FeedList removeObjectAtIndex:btn.tag];
                                                                     [self.tbv_FeedList reloadData];
                                                                 }
                                                                 else
                                                                 {
                                                                     [self.arM_ArchiveList removeObjectAtIndex:btn.tag];
                                                                     [self.tbv_ArchiveList reloadData];
                                                                 }
                                                             }
                                                         }];
                     }
                 }];
             }
             else if( buttonIndex == 2 )
             {
                 //아카이빙 등록 / 취소
                 [self archiving:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]] withIdx:btn.tag];
             }
         }
         else
         {
             if( buttonIndex == 0 )
             {
                 //신고 로직
                 UIAlertView *alert = CREATE_ALERT(nil, @"신고하시겠습니까?", @"예", @"아니요");
                 [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                     
                     if( buttonIndex == 0 )
                     {
                         //http://127.0.0.1:7080/api/sns/insertSnsReport.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1
                         NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
                         [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
                         [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
                         [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
                         
                         [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsReport.do"
                                                             param:dicM_Params
                                                         withBlock:^(id resulte, NSError *error) {
                                                             
                                                             [GMDCircleLoader hide];
                                                             
                                                             if( resulte )
                                                             {
                                                                 NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                                                 switch (nCode)
                                                                 {
                                                                     case 1:
                                                                         [self.navigationController.view makeToast:@"신고 되었습니다"];
                                                                         break;
                                                                         
                                                                     case 2:
                                                                         [self.navigationController.view makeToast:@"이미 신고한 컨텐츠 입니다"];
                                                                         break;
                                                                         
                                                                     default:
                                                                         [self.navigationController.view makeToast:@"오류"];
                                                                         break;
                                                                 }
                                                                 
                                                                 //                                                                 [self updateList];
                                                             }
                                                         }];
                     }
                 }];
             }
             else if( buttonIndex == 1 )
             {
                 //아카이빙 등록 / 취소
                 [self archiving:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]] withIdx:btn.tag];
             }
         }
     }];
}

- (void)archiving:(NSString *)aFeedIdx withIdx:(NSInteger )idx
{
    //http://127.0.0.1:7080/api/sns/insertSnsArchiving.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:aFeedIdx forKey:@"snsFeedIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsArchiving.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [GMDCircleLoader hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode)
                                            {
                                                case 1:
                                                    [self.navigationController.view makeToast:@"보관함에 추가 되었습니다"];
                                                    break;
                                                    
                                                case 3:
                                                    [self.navigationController.view makeToast:@"보관함에서 삭제 되었습니다"];
                                                    break;
                                                    
                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                            
                                            [self updateListOneItem:idx];
                                        }
                                    }];
}

- (void)onMovie:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[btn.tag];
    }
    else
    {
        dic = self.arM_ArchiveList[btn.tag];
    }
    
    GreenTubeDetailViewController *vc = [[GreenTubeDetailViewController alloc]initWithNibName:@"GreenTubeDetailViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    //    vc.isMoviePlay = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onComment:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[btn.tag];
    }
    else
    {
        dic = self.arM_ArchiveList[btn.tag];
    }
    
}

- (void)onLike:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[btn.tag];
    }
    else
    {
        dic = self.arM_ArchiveList[btn.tag];
    }
    
    //http://127.0.0.1:7080/api/sns/insertSnsFavorite.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsFavorite.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            /*
                                             0 : 좋아요 실패
                                             1 : 좋아요 성공
                                             2 : 좋아요 취소 실패
                                             3 : 좋아요 취소 성공처리결과
                                             */
                                            NSInteger nCode = [[resulte objectForKey_YM:@"ResultCode"] integerValue];
                                            switch (nCode)
                                            {
                                                case 1:
                                                    [self.navigationController.view makeToast:@"좋아요"];
                                                    break;
                                                    
                                                case 3:
                                                    [self.navigationController.view makeToast:@"좋아요 취소"];
                                                    break;
                                                    
                                                default:
                                                    [self.navigationController.view makeToast:@"오류"];
                                                    break;
                                            }
                                            
                                            [self updateListOneItem:btn.tag];
                                        }
                                    }];
}

- (void)updateListOneItem:(NSInteger)idx
{
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[idx];
    }
    else
    {
        dic = self.arM_ArchiveList[idx];
    }
    
    NSString *str_FeedIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:str_FeedIdx forKey:@"snsFeedIdx"];
    
    if( self.viewMode == kFeed )
    {
        [dicM_Params setObject:@"1" forKey:@"searchType"];
    }
    else
    {
        [dicM_Params setObject:@"2" forKey:@"searchType"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSArray *ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"SNSList"]];
                                            if( ar.count > 0 )
                                            {
                                                NSDictionary *dic_Item = [ar firstObject];
                                                if( self.viewMode == kFeed )
                                                {
                                                    [self.arM_FeedList replaceObjectAtIndex:idx withObject:dic_Item];
                                                    [self.tbv_FeedList reloadData];
                                                }
                                                else
                                                {
                                                    [self.arM_ArchiveList replaceObjectAtIndex:idx withObject:dic_Item];
                                                    [self.tbv_ArchiveList reloadData];
                                                }
                                            }
                                        }
                                    }];
}

- (void)onKakao:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.viewMode == kFeed )
    {
        dic = self.arM_FeedList[btn.tag];
    }
    else
    {
        dic = self.arM_ArchiveList[btn.tag];
    }
    
    
    NSInteger nSnsFeedIdx = [[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"SNSFeedIdx"]] integerValue];
    
    KakaoTalkLinkAction *androidAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid
                                                                      devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                       execparam:@{@"greentube" : [NSString stringWithFormat:@"%ld", nSnsFeedIdx]}];
    
    KakaoTalkLinkAction *iphoneAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS
                                                                     devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                      execparam:@{@"greentube" : [NSString stringWithFormat:@"%ld", nSnsFeedIdx]}];
    
    
    NSString *str_StoreName = @"";
    
    NSInteger nDutiesPositionParentIdx = [[dic objectForKey_YM:@"DutiesPositionParentIdx"] integerValue];
    if( nDutiesPositionParentIdx == 1000 )
    {
        NSString *str_Dept = [dic objectForKey_YM:@"DeptName"];
        if( str_Dept == nil )
        {
            str_StoreName = [dic objectForKey_YM:@"DeptNM"];
        }
        
        if( str_Dept.length > 0 )
        {
            str_StoreName = str_Dept;
        }
        else
        {
            str_StoreName = @"본사";
        }
    }
    else
    {
        str_StoreName = [dic objectForKey_YM:@"ComNM"];
    }

    NSString *str_Title = [NSString stringWithFormat:@"%@(%@)님의 그린튜브", [dic objectForKey_YM:@"NameKR"], str_StoreName];
    KakaoTalkLinkObject *label = [KakaoTalkLinkObject createLabel:str_Title];
    [_kakaoTalkLinkObjects setObject:label forKey:@"label"];
    
    KakaoTalkLinkObject *link = [KakaoTalkLinkObject createAppLink:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                                           actions:@[androidAppAction, iphoneAppAction]];
    [_kakaoTalkLinkObjects setObject:link forKey:@"link"];
    
    KakaoTalkLinkObject *buttonObj = [KakaoTalkLinkObject createAppButton:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                                                  actions:@[androidAppAction, iphoneAppAction]];
    
    [_kakaoTalkLinkObjects setObject:buttonObj forKey:@"button"];
    
    
    
    
    if ([KOAppCall canOpenKakaoTalkAppLink])
    {
        [KOAppCall openKakaoTalkAppLink:[_kakaoTalkLinkObjects allValues]];
    }
    else
    {
        ALERT_ONE(@"카카오톡이 설치되어 있지 않습니다.");
    }
}

@end
