//
//  GreenTubeDetailViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 10..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
// 

#import "GreenTubeDetailViewController.h"
#import "FeedTextCell.h"
#import "FeedImageCell.h"
#import "FeedMovieCell.h"
#import "FeedVoteCell.h"
#import "FeedVoteExtendCell.h"
#import "CommentListCell.h"
#import "MWPhotoBrowser.h"
#import "HPGrowingTextView.h"
#import "MoviePlayerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BSImagePickerController.h"
#import "GreenTubeCommentCell.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "CommentModifyViewController.h"
#import "GreenTubeSearchViewController.h"
#import "GreenTubeModifyViewController.h"
#import "KILabel.h"
#import <SDWebImage/UIImageView+WebCache.h>

static const NSInteger snCommentEmptyTag = 99;
static const NSInteger kMaxImageCnt = 1;
static const CGFloat kCommentImageHeight = 100;

@interface GreenTubeDetailViewController () <UISearchBarDelegate, MWPhotoBrowserDelegate, HPGrowingTextViewDelegate>
{
    UIView *containerView;
}
@property (nonatomic, strong) NSArray *ar_CommentList;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *v_Contents;
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) UIImage *i_Comment;
@property (nonatomic, strong) BSImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *arM_ImageData;
@property (nonatomic, strong) NSMutableDictionary *kakaoTalkLinkObjects;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UITableView *tbv_CommentList;
@property (nonatomic, weak) IBOutlet UIView *v_TextInput;
@property (nonatomic, weak) IBOutlet UIView *v_Comment;
@property (nonatomic, weak) IBOutlet UITextField *tf_Comment;
@property (nonatomic, weak) IBOutlet UIImageView *iv_CommentFile;
@property (nonatomic, weak) IBOutlet UIView *v_CommentFile;
@end

@implementation GreenTubeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.screenName = @"그린튜브 상세";
    
    self.kakaoTalkLinkObjects = [[NSMutableDictionary alloc] init];
    
    self.v_CommentFile.hidden = YES;
    
    self.arM_ImageData = [NSMutableArray arrayWithCapacity:kMaxImageCnt];

    [Common greenTubeViewCountUp:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]]];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(svTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [self.sv_Main addGestureRecognizer:singleTap];

//    [self performSelector:@selector(addHpGrowinView) withObject:nil afterDelay:1.0f];
    [self addHpGrowinView];
    
    if( self.isMoviePlay )
    {
        //동영상 재생 버튼을 누르고 왔을시 바로 재생 시켜준다 (기획내용)
        [self onMovie:nil];
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateList)
//                                                 name:@"ReloadDetailSnsFeed"
//                                               object:nil];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addHpGrowinView
{
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(self.v_TextInput.frame.origin.x - 3, self.v_TextInput.frame.origin.y - 6,
                                                                        self.v_TextInput.frame.size.width + 3, self.v_TextInput.frame.size.height + 6)];

    self.textView.isScrollable = NO;
//    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    self.textView.minNumberOfLines = 1;
    self.textView.maxNumberOfLines = 0;
    // you can also set the maximum height in points with maxHeight
//    self.textView.maxHeight = 150.0f;
    self.textView.returnKeyType = UIReturnKeyNext; //just as an example
    self.textView.font = [UIFont systemFontOfSize:14.0f];
    self.textView.delegate = self;
//    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor clearColor];
    //    self.textView.placeholder = @"댓글을 입력해 주세요^^";
    

    [self.v_Comment addSubview:self.textView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNavi];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self updateList];
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

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    }
    else
    {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.sv_Main.contentInset = contentInsets;
        self.sv_Main.scrollIndicatorInsets = contentInsets;
        
        static CGFloat fY = 0.0f;
        
        self.v_Comment.frame = CGRectMake(self.v_Comment.frame.origin.x, fY > 0 ? fY : self.v_Comment.frame.origin.y - keyboardSize.height,
                                          self.v_Comment.frame.size.width, self.v_Comment.frame.size.height);
        
        if( fY == 0.0f )
        {
            fY = self.v_Comment.frame.origin.y;
        }

        self.v_CommentFile.frame = CGRectMake(self.v_CommentFile.frame.origin.x, self.v_Comment.frame.origin.y - (self.v_CommentFile.frame.size.height + 5),
                                              self.v_CommentFile.frame.size.width, self.v_CommentFile.frame.size.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.sv_Main.contentInset = UIEdgeInsetsZero;
        self.sv_Main.scrollIndicatorInsets = UIEdgeInsetsZero;
        
        self.v_Comment.frame = CGRectMake(self.v_Comment.frame.origin.x, self.view.frame.size.height - self.v_Comment.frame.size.height,
                                          self.v_Comment.frame.size.width, self.v_Comment.frame.size.height);
        
        self.v_CommentFile.frame = CGRectMake(self.v_CommentFile.frame.origin.x, self.v_Comment.frame.origin.y - (self.v_CommentFile.frame.size.height + 5),
                                          self.v_CommentFile.frame.size.width, self.v_CommentFile.frame.size.height);
    }];
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
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
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
    NSLog(@"통신 시작");
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
//    [dicM_Params setObject:self.str_Row forKey:@"startRowNum"];
//    [dicM_Params setObject:@"1" forKey:@"endRowNum"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.nIntoMode] forKey:@"searchType"];
    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] forKey:@"snsFeedIdx"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {

                                        NSLog(@"통신 종료");

                                        if( resulte )
                                        {
                                            NSArray *ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"SNSList"]];
                                            if( ar.count > 0 )
                                            {
                                                self.dic_Info = [ar firstObject];
                                                [self updateContents];
                                                [self updateCommentList];
                                            }
                                        }
                                    }];
}

- (void)updateCommentList
{
    //http://127.0.0.1:7080/api/sns/selectSnsCommentList.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] forKey:@"snsFeedIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.nIntoMode] forKey:@"searchType"];

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsCommentList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            UIView *view = (UIView *)[self.tbv_CommentList viewWithTag:snCommentEmptyTag];
                                            [view removeFromSuperview];

                                            self.ar_CommentList = [resulte objectForKey:@"SNSCommentList"];
                                            [self.tbv_CommentList reloadData];
                                            
                                            CGRect frame = self.tbv_CommentList.frame;
                                            frame.size.height = self.tbv_CommentList.contentSize.height;
                                            self.tbv_CommentList.frame = frame;
                                            
                                            if( self.ar_CommentList == nil || self.ar_CommentList.count <= 0 )
                                            {
                                                CGRect frame = self.tbv_CommentList.frame;
                                                frame.size.height = 100;
                                                self.tbv_CommentList.frame = frame;

                                                [self showCommentEmptyView];
                                            }
                                            
                                            self.sv_Main.contentSize = CGSizeMake(0, self.v_Contents.frame.size.height + self.tbv_CommentList.frame.size.height);
                                        }
                                    }];
}

- (void)showCommentEmptyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FeedCommentEmpty" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snCommentEmptyTag;
    view.frame = CGRectMake(0, 0, self.tbv_CommentList.frame.size.width, view.frame.size.height);
    [self.tbv_CommentList addSubview:view];
}

- (void)updateContents
{
    if( self.v_Contents )
    {
        [self.v_Contents removeFromSuperview];
    }
    
    NSInteger nContentType = [[self.dic_Info objectForKey_YM:@"ContentType"] integerValue];
    switch (nContentType)
    {
        case 1002:
            //이미지
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FeedImageCell" owner:self options:nil];
            FeedImageCell *cell = [topLevelObjects objectAtIndex:0];
            cell.lb_Contents.numberOfLines = 0;
            self.v_Contents = cell;
            
            CGFloat fLastY = [self setCellDefaultData:cell withData:self.dic_Info];
            fLastY += 15.0f;
            
//            [cell.sv_Thumbs removeFromSuperview];
            
            NSArray *ar_ImageList = [self.dic_Info objectForKey:@"SNSAttachList"];
            for( NSInteger i = 0; i < ar_ImageList.count; i++ )
            {
                NSDictionary *dic_Image = ar_ImageList[i];
                NSInteger nType = [[dic_Image objectForKey_YM:@"AttachType"] integerValue];
                if( nType == 1002 )
                {
                    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(10, fLastY,
                                                                                   self.view.frame.size.width - 20, 200)];
                    iv.tag = i + 1;
                    iv.userInteractionEnabled = YES;
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.clipsToBounds = YES;
                    
                    NSString *str_ImageUrl = [dic_Image objectForKey_YM:@"AttachFileFullURL_I"];
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_ImageUrl]];
                    
                    UIImage *image = [UIImage imageWithData:imageData];

                    UIImage *newImage = nil;
                    
                    if( image == nil )
                    {
                        newImage = BundleImage(@"no_thumbnail.png");
                    }

                    
                    newImage = [Util imageWithImage:image convertToWidth:iv.frame.size.width];

                    
                    [iv setImage:newImage];
                    
                    CGRect frame = iv.frame;
                    frame.size.height = newImage.size.height;
                    iv.frame = frame;
                    
                    
                    
                    
                    
                    
//                    [iv setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
                    
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
                    [singleTap setNumberOfTapsRequired:1];
                    [iv addGestureRecognizer:singleTap];
                    
                    fLastY += newImage.size.height + 5;
                    
                    [cell addSubview:iv];
                }
            }
            
            CGRect frame = cell.v_BottomMenu.frame;
            frame.origin.x = 5.0f;
            frame.origin.y = fLastY + 3.0f;
            cell.v_BottomMenu.frame = frame;
            
            frame = cell.iv_TopLine.frame;
            frame.origin.x = -5;
            frame.size.width = self.view.frame.size.width;
            cell.iv_TopLine.frame = frame;
            
            UIImageView *iv_UnderLine = [[UIImageView alloc]initWithFrame:CGRectMake(cell.iv_TopLine.frame.origin.x, cell.v_BottomMenu.frame.size.height - 1,
                                                                                     cell.iv_TopLine.frame.size.width, 1)];
            iv_UnderLine.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1];
            [cell.v_BottomMenu addSubview:iv_UnderLine];
            
            frame = cell.frame;
            frame.size.height = cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
            frame.size.width = self.view.frame.size.width;
            cell.frame = frame;
            
            frame = self.tbv_CommentList.frame;
            frame.origin.y = cell.frame.origin.y + cell.frame.size.height;
            self.tbv_CommentList.frame = frame;
            
            [self.sv_Main addSubview:cell];
            return;
        }
            
        case 1003:
            //동영상
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FeedMovieCell" owner:self options:nil];
            FeedMovieCell *cell = [topLevelObjects objectAtIndex:0];
            cell.lb_Contents.numberOfLines = 0;
            self.v_Contents = cell;
            
            CGFloat fLastY = [self setCellDefaultData:cell withData:self.dic_Info];
            fLastY += 15.0f;

            NSArray *ar_ImageList = [self.dic_Info objectForKey:@"SNSAttachList"];
            if( ar_ImageList.count > 0 )
            {
                NSDictionary *dic_MovieInfo = [ar_ImageList firstObject];
                NSInteger nType = [[dic_MovieInfo objectForKey_YM:@"AttachType"] integerValue];
                if( nType == 1003 )
                {
                    NSString *str_ImageUrl = [dic_MovieInfo objectForKey_YM:@"VODThumnailURL"];
                    [cell.iv_MovieThumb setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"") usingCache:NO];
                    [cell.btn_Movie addTarget:self action:@selector(onMovie:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            
            CGRect frame = cell.v_Contents.frame;
            frame.origin.y = fLastY;
            frame.origin.x = 5.0f;
            cell.v_Contents.frame = frame;
            
            cell.iv_MovieThumb.frame = CGRectMake(0, 0, cell.v_Contents.frame.size.width, cell.v_Contents.frame.size.height);
            
            fLastY = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 5;
            
            frame = cell.v_BottomMenu.frame;
            frame.origin.x = 5.0f;
            frame.origin.y = fLastY + 3.0f;
            cell.v_BottomMenu.frame = frame;
            
            frame = cell.iv_TopLine.frame;
            frame.origin.x = -5;
            frame.size.width = self.view.frame.size.width;
            cell.iv_TopLine.frame = frame;
            
            UIImageView *iv_UnderLine = [[UIImageView alloc]initWithFrame:CGRectMake(cell.iv_TopLine.frame.origin.x, cell.v_BottomMenu.frame.size.height - 1,
                                                                                     cell.iv_TopLine.frame.size.width, 1)];
            iv_UnderLine.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1];
            [cell.v_BottomMenu addSubview:iv_UnderLine];
            
            frame = cell.frame;
            frame.size.height = cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
            frame.size.width = self.view.frame.size.width;
            cell.frame = frame;
            
            frame = self.tbv_CommentList.frame;
            frame.origin.y = cell.frame.origin.y + cell.frame.size.height;
            self.tbv_CommentList.frame = frame;
            
            [self.sv_Main addSubview:cell];
            return;
        }
            
        case 1004:
            //투표
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FeedVoteExtendCell" owner:self options:nil];
            FeedVoteExtendCell *cell = [topLevelObjects objectAtIndex:0];
            cell.lb_Contents.numberOfLines = 0;
            self.v_Contents = cell;
            
            CGFloat fLastY = [self setCellDefaultData:cell withData:self.dic_Info];
            fLastY += 15.0f;

            
            NSArray *ar_VoteList = [self.dic_Info objectForKey_YM:@"SNSPollList"];
            if( ar_VoteList.count > 0 )
            {
                CGRect frame = cell.lb_Contents.frame;
                frame.size.height = [Util getTextSize:cell.lb_Contents].height;
                cell.lb_Contents.frame = frame;
                
                
                cell.lb_Qeustion.text = [self.dic_Info objectForKey_YM:@"Title"];
                cell.lb_QeustionInPeople.text = [NSString stringWithFormat:@"총 %ld명 참여중", [[self.dic_Info objectForKey_YM:@"PollParticipantCNT"] integerValue]];
                
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
                
                
                
                
                
                
                //나의 투표여부
                BOOL isVote = NO;
                NSString *str_IsVote = [self.dic_Info objectForKey_YM:@"PolledYN"];
                if( [str_IsVote isEqualToString:@"Y"] )
                {
                    isVote = YES;
                    cell.btn_Vote.userInteractionEnabled = NO;
                    [cell.btn_Vote setTitle:@"참여완료" forState:UIControlStateNormal];
                    cell.btn_Vote.titleLabel.textColor = [UIColor colorWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1];
                    cell.btn_Vote.backgroundColor = [UIColor colorWithHexString:@"EDEEEF"];
                }
                else
                {
                    isVote = NO;
                    cell.btn_Vote.userInteractionEnabled = YES;
                    [cell.btn_Vote setTitle:@"투표하기" forState:UIControlStateNormal];
                    [cell.btn_Vote setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    cell.btn_Vote.backgroundColor = [UIColor colorWithHexString:@"68AB59"];
                    
                    [cell.btn_Vote addTarget:self action:@selector(onVote:) forControlEvents:UIControlEventTouchUpInside];
                }

                
                //비밀투표 여부
                BOOL isSecret = NO;
                NSInteger nSecretCode = [[self.dic_Info objectForKey_YM:@"ResultViewYN"] integerValue];
                if( nSecretCode == 505 )
                {
                    //나만 보기
                    isSecret = YES;
                }
                else
                {
                    //모두 보기
                    isSecret = NO;
                }
                
                cell.ar_List = [NSArray arrayWithArray:ar_VoteList];
                cell.isSecret = isSecret;
                cell.isVote = isVote;
                [cell.tbv_List reloadData];
                
                //테이블뷰 프레임 조정
                frame = cell.tbv_List.frame;
                frame.origin.y = cell.v_QeustionBg.frame.origin.y + cell.v_QeustionBg.frame.size.height;
                frame.size.height = cell.tbv_List.contentSize.height;
                cell.tbv_List.frame = frame;
                
                
                //투표 버튼 프레임 조정
                frame = cell.btn_Vote.frame;
                frame.origin.y = cell.tbv_List.frame.origin.y + cell.tbv_List.frame.size.height + 10;
                cell.btn_Vote.frame = frame;
                
                
                
                UIImageView *iv_Line = [[UIImageView alloc]initWithFrame:CGRectMake(cell.btn_Vote.frame.origin.x, cell.btn_Vote.frame.origin.y + cell.btn_Vote.frame.size.height + 10,
                                                                                    cell.btn_Vote.frame.size.width, 1)];
                iv_Line.backgroundColor = [UIColor lightGrayColor];
                [cell.v_Contents addSubview:iv_Line];
                
                
                
                
                frame = cell.v_Contents.frame;
                frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
                frame.size.height = cell.btn_Vote.frame.origin.y + cell.btn_Vote.frame.size.height + 11;
                cell.v_Contents.frame = frame;
                
                
                frame = cell.v_BottomMenu.frame;
                frame.origin.y = cell.v_Contents.frame.origin.y + cell.v_Contents.frame.size.height + 8;
                cell.v_BottomMenu.frame = frame;
                
                
                frame = cell.frame;
                frame.size.height = cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
                frame.size.width = self.view.frame.size.width;
                cell.frame = frame;

                
                frame = self.tbv_CommentList.frame;
                frame.origin.y = cell.frame.origin.y + cell.frame.size.height;
                self.tbv_CommentList.frame = frame;

                
                [self.sv_Main addSubview:cell];
                return;
            }
        }
            
        default:
        {
            //디폴트는 텍스트로 했다 (타입이 널로 넘어오는게 있음....흠...)
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"FeedTextCell" owner:self options:nil];
            FeedTextCell *cell = [topLevelObjects objectAtIndex:0];
            cell.lb_Contents.numberOfLines = 0;
            self.v_Contents = cell;
            
            CGFloat fLastY = [self setCellDefaultData:cell withData:self.dic_Info];
            fLastY += 15.0f;
            
            CGRect frame = cell.v_BottomMenu.frame;
            frame.origin.x = 5.0f;
            frame.origin.y = fLastY;
            cell.v_BottomMenu.frame = frame;
            
            frame = cell.iv_TopLine.frame;
            frame.origin.x = -5;
            frame.size.width = self.view.frame.size.width;
            cell.iv_TopLine.frame = frame;
            
            UIImageView *iv_UnderLine = [[UIImageView alloc]initWithFrame:CGRectMake(cell.iv_TopLine.frame.origin.x, cell.v_BottomMenu.frame.size.height - 1,
                                                                                     cell.iv_TopLine.frame.size.width, 1)];
            iv_UnderLine.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1];
            [cell.v_BottomMenu addSubview:iv_UnderLine];
            
            frame = cell.frame;
            frame.size.height = cell.v_BottomMenu.frame.origin.y + cell.v_BottomMenu.frame.size.height;
            frame.size.width = self.view.frame.size.width;
            cell.frame = frame;
            
            frame = self.tbv_CommentList.frame;
            frame.origin.y = cell.frame.origin.y + cell.frame.size.height;
            self.tbv_CommentList.frame = frame;
            
            [self.sv_Main addSubview:cell];
            return;
        }
    }
}

- (CGFloat)setCellDefaultData:(FeedTextCell *)cell withData:(NSDictionary *)dic
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
//    cell.contentView.layer.cornerRadius = 5.0f;
    
    cell.btn_Menu.tag = cell.btn_CmtCnt.tag = cell.btn_LikeCnt.tag = cell.btn_KakaoShare.tag = cell.tag;
    
    
    //작성자 이미지
    NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
    [cell.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_middle2.png") usingCache:NO];
    cell.iv_User.userInteractionEnabled = YES;
    cell.iv_User.tag = cell.tag;
    
    cell.iv_User.layer.masksToBounds = YES;
    cell.iv_User.layer.cornerRadius = cell.iv_User.frame.size.width/2;
    cell.iv_User.contentMode = UIViewContentModeScaleAspectFill;

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
    
    NSString *str_Contents = [self.dic_Info objectForKey_YM:@"SNSContent"];
    NSString *br = @"\n";
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
    str_Contents = [str_Contents gtm_stringByUnescapingFromHTML];
    cell.lb_Contents.text = str_Contents;
    
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
    [cell.btn_CmtCnt addTarget:self action:@selector(onComment:) forControlEvents:UIControlEventTouchUpInside];
    
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

    
    CGFloat fHeight = [Util getTextSize:cell.lb_Contents].height + 15;

    CGRect frame = cell.lb_Contents.frame;
    frame.size.height = fHeight;
    cell.lb_Contents.frame = frame;


    return cell.lb_Contents.frame.origin.y + fHeight;
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.ar_CommentList.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"GreenTubeCommentCell";
    GreenTubeCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    if( indexPath.row % 2 )
    {
        //두번째꺼
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"FEFFFF"];
    }
    else
    {
        //첫번째꺼
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F4F5F6"];
    }
    
    /*
     AttachFileList =             (
     );
     AttachFileURL = "<null>";
     ComNM = "\Uc774\Ub2c8\Uc2a4\Ud504\Ub9ac \Ubcf8\Uc0ac";
     Contents = 1002;
     DeletableYN = Y;
     DeptName = "\Ubd80\Uc11c2";
     DutiesPositionParentIdx = 100;
     EditableYN = Y;
     FullImgURL = "http://52.68.160.225:80/api/UPLOAD/MEMBER/AAA.JPG";
     ImgURL = "/UPLOAD/MEMBER/AAA.JPG";
     NameKR = cast;
     RegDate = 20150506015321;
     RegUserIdx = 1004;
     ReportedYN = N;
     SNSCommentIdx = 22;
     SNSFeedIdx = 14;
     */
    

    NSDictionary *dic = self.ar_CommentList[indexPath.row];

    //작성자 이미지
    NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
//    [cell.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_middle2.png") usingCache:NO];
    
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] placeholderImage:BundleImage(@"thumbnail_middle2.png")];

    cell.iv_User.userInteractionEnabled = YES;
    cell.iv_User.tag = indexPath.row + 1;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTap:)];
    [tap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:tap];

    
    //글쓴이
    cell.lb_Writer.text = [dic objectForKey_YM:@"NameKR"];
    
    //매장명 | 등록날짜
    NSString *str_Time = [dic objectForKey_YM:@"RegDate"];
    if( str_Time.length > 8 )
    {
        str_Time = [str_Time substringWithRange:NSMakeRange(0, 8)];
    }

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

    cell.lb_SubTitle.text = [NSString stringWithFormat:@"%@ | %@", str_StoreName, [Util makeDate:str_Time]];
    
    //내용
    cell.lb_Contents.numberOfLines = 0;
    NSString *str_Contents = [dic objectForKey_YM:@"Contents"];
    NSString *br = @"\n";
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
    str_Contents = [str_Contents gtm_stringByUnescapingFromHTML];
    cell.lb_Contents.text = str_Contents;
    
    
    cell.lb_Contents.systemURLStyle = YES;
    //    cell.lb_Contents.linkDetectionTypes = KILinkTypeOptionURL;
    cell.lb_Contents.linkDetectionTypes = KILinkTypeOptionNone;
    
//    cell.lb_Contents.urlLinkTapHandler = nil;
    cell.lb_Contents.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        // Open URLs
        [self attemptOpenURL:[NSURL URLWithString:string]];
    };

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //버튼들
    cell.btn_Delete.tag = cell.btn_Modify.tag = cell.btn_Report.tag = indexPath.row;
    cell.iv_Seper.hidden = cell.btn_Delete.hidden = cell.btn_Modify.hidden = cell.btn_Report.hidden = YES;
    
    NSString *str_IsMyContents = [dic objectForKey_YM:@"EditableYN"];
    if( [str_IsMyContents isEqualToString:@"Y"] )
    {
        //내가 쓴 댓글이면
        cell.btn_Delete.hidden = NO;
//        cell.iv_Seper.hidden = cell.btn_Delete.hidden = cell.btn_Modify.hidden = NO;
        [cell.btn_Delete addTarget:self action:@selector(onDeleteComment:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_Modify addTarget:self action:@selector(onModify:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        //다른사람이 쓴 댓글이면
        cell.btn_Report.hidden = NO;
        [cell.btn_Report addTarget:self action:@selector(onReport:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGRect frame = cell.lb_Contents.frame;
    frame.size.height = [Util getTextSize:cell.lb_Contents].height + 15;
    cell.lb_Contents.frame = frame;
    
    NSArray *ar = [dic objectForKey:@"AttachFileList"];
    if( ar.count > 0 )
    {
        NSDictionary *dic_ImageInfo = [ar firstObject];
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(cell.lb_Contents.frame.origin.x, cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height,
                                                                       240.0f, kCommentImageHeight)];
        iv.userInteractionEnabled = YES;
        iv.tag = indexPath.row + 9999;
        iv.userInteractionEnabled = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentImageTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [iv addGestureRecognizer:singleTap];

        NSString *str_ImageUrl = [dic_ImageInfo objectForKey_YM:@"AttachFileFullURL"];
//        [iv setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
        [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] placeholderImage:BundleImage(@"")];

        [cell.contentView addSubview:iv];
    }
    
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_CommentList[indexPath.row];
    GreenTubeCommentCell *cell = (GreenTubeCommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSString *str_Contents = [dic objectForKey_YM:@"Contents"];
    NSString *br = @"\n";
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
    str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
    str_Contents = [str_Contents gtm_stringByUnescapingFromHTML];
    cell.lb_Contents.text = str_Contents;

    CGRect frame = cell.lb_Contents.frame;
    frame.size.height = [Util getTextSize:cell.lb_Contents].height + 15;
    cell.lb_Contents.frame = frame;
    
    CGFloat fHeight = frame.origin.y + frame.size.height;
    
    NSArray *ar = [dic objectForKey:@"AttachFileList"];
    if( ar.count > 0 )
    {
        fHeight = kCommentImageHeight + fHeight + 10;
    }
    
    return fHeight;
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
    //nSubTag는 index.section값
    //tag는 이미지 순서값
    UIImageView *iv = (UIImageView *)gestureRecognizer.view;
    
    self.ar_Photo = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    
    NSDictionary *dic = self.dic_Info;
    
    NSArray *ar_Thumbs = [dic objectForKey:@"SNSAttachList"];
    
    
    NSMutableArray *arM_Url = [NSMutableArray array];
    for( NSInteger i = 0; i < ar_Thumbs.count; i++ )
    {
        NSDictionary *dic = ar_Thumbs[i];
        NSString *str_Url = [dic objectForKey_YM:@"AttachFileFullURL_I"];
        if( [str_Url hasSuffix:@"api"] == NO )
        {
            [arM_Url addObject:dic];
        }
    }
    
    NSInteger nImageCnt = arM_Url.count;
    for( NSInteger i = 0; i < nImageCnt; i++ )
    {
        NSDictionary *dic_ImageInfo = arM_Url[i];
        [self.thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dic_ImageInfo valueForKey:@"AttachFileFullURL_I"]]]];
        [self.ar_Photo addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dic_ImageInfo valueForKey:@"AttachFileFullURL_I"]]]];
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
    [browser setCurrentPhotoIndex:iv.tag - 1];
    
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
    // Release
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });
}

- (void)commentImageTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *iv = (UIImageView *)gestureRecognizer.view;
    
    self.ar_Photo = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    
    
    NSDictionary *dic_Super = self.ar_CommentList[iv.tag - 9999];
    NSArray *ar = [dic_Super objectForKey:@"AttachFileList"];
    NSDictionary *dic = [ar firstObject];
    
    [self.thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dic valueForKey:@"AttachFileFullURL"]]]];
    [self.ar_Photo addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dic valueForKey:@"AttachFileFullURL"]]]];
    
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
    [browser setCurrentPhotoIndex:iv.tag - 1];
    
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
    // Release
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });
}

- (void)profileTap:(UIGestureRecognizer *)gesture
{
    NSDictionary *dic = nil;
    NSString *str_Idx = @"";
    UIView *gestureView = gesture.view;
    if( gestureView.tag > 0 )
    {
        //태그가 0보다 크면 댓글 프로필
        //무슨 필드마다 대소문자가 다르냐 -_-
        dic = self.ar_CommentList[gestureView.tag - 1];
        str_Idx = [dic objectForKey_YM:@"RegUserIdx"];
    }
    else
    {
        //태그가 0이면 상단 컨텐츠 프로필
        dic = self.dic_Info;
        str_Idx = [dic objectForKey_YM:@"RegUserIDX"];
    }
    
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ShowUserInfo" owner:self options:nil];
    ShowUserInfo *view = [topLevelObjects objectAtIndex:0];
    view.str_Idx = str_Idx;
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

- (void)svTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}


#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.v_Comment.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.v_Comment.frame = r;
    
//    r = containerView.frame;
//    r.size.height -= diff;
//    r.origin.y += diff;
//    containerView.frame = r;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if( growingTextView.text.length > 0 )
    {
        self.tf_Comment.hidden = YES;
    }
    else
    {
        self.tf_Comment.hidden = NO;
    }
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
- (IBAction)goAddComment:(id)sender
{
    if( self.textView.text.length <= 0 )
    {
        return;
    }

//    http://127.0.0.1:7080/api/sns/insertSnsComment.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1&contents=댓글입력테스트_1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] forKey:@"snsFeedIdx"];
    [dicM_Params setObject:self.textView.text forKey:@"contents"];
    
    //

    NSMutableDictionary *dicM_Image = [NSMutableDictionary dictionaryWithCapacity:self.arM_ImageData.count];
    for( NSInteger i = 0; i < self.arM_ImageData.count; i++ )
    {
        NSData *imageData = self.arM_ImageData[i];
//        NSString *str_Key = [NSString stringWithFormat:@"ImgFile%d", i + 1];
        [dicM_Image setObject:imageData forKey:@"attachFiles"];
    }

    [[WebAPI sharedData] imageUpload:@"sns/insertSnsComment.do"
                               param:dicM_Params
                          withImages:dicM_Image
                           withBlock:^(id resulte, NSError *error) {
                               
                               if( resulte )
                               {
                                   NSDictionary *dic = [resulte objectForKey:@"ResultInfo"];
                                   NSInteger nCode = [[dic objectForKey_YM:@"ResultCode"] integerValue];
                                   switch (nCode)
                                   {
                                       case 1:
                                           self.textView.text = @"";
                                           [self goCommentImageFileDelete:nil];
                                           [self.view endEditing:YES];
                                           break;
                                           
                                       default:
                                           [self.navigationController.view makeToast:@"오류"];
                                           break;
                                   }
                                   
                                   [self updateList];
                               }
                               else
                               {
                                   [self.navigationController.view makeToast:@"오류"];
                               }
                           }];
}

- (IBAction)goCommentImage:(id)sender
{
    if( kMaxImageCnt == self.arM_ImageData.count)
    {
        NSString *str_Msg = [NSString stringWithFormat:@"최대 %ld장의\n이미지 등록이 가능합니다", kMaxImageCnt];
        ALERT_ONE(str_Msg);
        return;
    }
    
    
    self.imagePicker = [[BSImagePickerController alloc] init];
    self.imagePicker.maximumNumberOfImages = kMaxImageCnt - self.arM_ImageData.count;
    
    [self presentImagePickerController:self.imagePicker
                              animated:YES
                            completion:nil
                                toggle:^(ALAsset *asset, BOOL select) {
                                    if(select)
                                    {
                                        NSLog(@"Image selected");
                                    }
                                    else
                                    {
                                        NSLog(@"Image deselected");
                                    }
                                }
                                cancel:^(NSArray *assets) {
                                    NSLog(@"User canceled...!");
                                    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
                                }
                                finish:^(NSArray *assets) {
                                    NSLog(@"User finished :)!");
                                    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
                                    
                                    for( NSInteger i = 0; i < assets.count; i++ )
                                    {
                                        ALAsset *asset = assets[i];
                                        
                                        ALAssetRepresentation *rep = [asset defaultRepresentation];
                                        CGImageRef iref = [rep fullScreenImage];
                                        if (iref)
                                        {
                                            UIImage *image = [UIImage imageWithCGImage:iref];
                                            NSData *imageData = UIImageJPEGRepresentation(image, 1);
                                            [self.arM_ImageData addObject:imageData];
                                            self.iv_CommentFile.image = image;
                                            [self updateImageThumbnail];
                                        }
                                    }
                                }];
}

- (void)updateImageThumbnail
{
    self.v_CommentFile.hidden = NO;
}

- (IBAction)goCommentImageFileDelete:(id)sender
{
    self.v_CommentFile.hidden = YES;
    self.iv_CommentFile.image = nil;
    
    [self.arM_ImageData removeAllObjects];
}

- (void)onMovie:(UIButton *)btn
{
    NSArray *ar_ImageList = [self.dic_Info objectForKey:@"SNSAttachList"];
    if( ar_ImageList.count > 0 )
    {
        NSDictionary *dic_MovieInfo = [ar_ImageList firstObject];
        NSString *str_Url = [dic_MovieInfo objectForKey_YM:@"AttachFileFullURL_I"];
        NSURL *url = [NSURL URLWithString:str_Url];
        
        MoviePlayerViewController *vc = [[MoviePlayerViewController alloc]initWithContentURL:url];
        
        vc.isSave = NO;
        vc.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        vc.moviePlayer.repeatMode = MPMovieRepeatModeOne;
        vc.moviePlayer.fullscreen = NO;
        vc.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        vc.moviePlayer.shouldAutoplay = YES;
        vc.moviePlayer.repeatMode = NO;
        [vc.moviePlayer setFullscreen:YES animated:YES];
        [vc.moviePlayer prepareToPlay];
        
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             
                         }];
    }
}

- (void)onComment:(UIButton *)btn
{

}

- (void)onLike:(UIButton *)btn
{
    //http://127.0.0.1:7080/api/sns/insertSnsFavorite.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
    
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
                                            
                                            [self updateList];
                                        }
                                    }];
}

- (void)onMenu:(UIButton *)btn
{
    //내 글일때
    //수정, 삭제, 아카이빙/아카이빙취소
    
    //남의 글일때
    //신고, 아카이빙/아카이빙취소
    
    NSMutableArray *arM_Menus = [NSMutableArray array];
    
    NSInteger nWriterIdx = [[self.dic_Info objectForKey_YM:@"RegUserIDX"] integerValue];
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
    
    
    NSString *str_IsArcive = [self.dic_Info objectForKey_YM:@"SNSArchivingYN"];
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
                 vc.str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]];
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
                         [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
                         
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
                                                                     {
                                                                         UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                                         [window makeToast:@"삭제 되었습니다"];
                                                                         [self.navigationController popViewControllerAnimated:YES];
                                                                         //삭제 노티
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"notiRemoveItem" object:self.str_Row userInfo:nil];
                                                                     }
                                                                         break;
                                                                         
                                                                     default:
                                                                         [self.navigationController.view makeToast:@"오류"];
                                                                         break;
                                                                 }
                                                             }
                                                         }];
                     }
                 }];
             }
             else if( buttonIndex == 2 )
             {
                 //아카이빙 등록 / 취소
                 [self archiving:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]]];
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
                         [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
                         
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
                 [self archiving:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]]];
             }
         }
     }];
}

- (void)archiving:(NSString *)aFeedIdx
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
                                            
                                            [self updateList];
                                        }
                                    }];
}

- (void)onDeleteComment:(UIButton *)btn
{
    NSDictionary *dic = self.ar_CommentList[btn.tag];
    
    //http://127.0.0.1:7080/api/sns/deleteSnsComment.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1&snsCommentIdx=21
    UIAlertView *alert = CREATE_ALERT(nil, @"삭제하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            //http://127.0.0.1:7080/api/sns/deleteSnsPost.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1
            //
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSCommentIdx"] integerValue]] forKey:@"snsCommentIdx"];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/deleteSnsComment.do"
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
                                                        {
                                                            CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.tbv_CommentList];
                                                            NSIndexPath *indexPath = [self.tbv_CommentList indexPathForRowAtPoint:buttonPosition];

                                                            GreenTubeCommentCell *cell = (GreenTubeCommentCell *)[self.tbv_CommentList cellForRowAtIndexPath:indexPath];
                                                            for( UIView *subView in cell.contentView.subviews )
                                                            {
                                                                if( subView.tag >= 9999 )
                                                                {
                                                                    [subView removeFromSuperview];
                                                                }
                                                            }
                                                        }
                                                            break;
                                                            
                                                        default:
                                                            [self.navigationController.view makeToast:@"오류"];
                                                            break;
                                                    }
                                                    
                                                    [self updateList];
                                                    
                                                }
                                            }];
        }
    }];
}

- (void)onModify:(UIButton *)btn
{
    NSDictionary *dic = self.ar_CommentList[btn.tag];
    
    CommentModifyViewController *vc = [[CommentModifyViewController alloc]initWithNibName:@"CommentModifyViewController" bundle:nil];
    vc.isGreenTube = YES;
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onReport:(UIButton *)btn
{
    NSDictionary *dic = self.ar_CommentList[btn.tag];

    UIAlertView *alert = CREATE_ALERT(nil, @"신고하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            //http://127.0.0.1:7080/api/sns/insertSnsCommentReport.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=1&snsCommentIdx=1
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
            [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSCommentIdx"] integerValue]] forKey:@"snsCommentIdx"];

            [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsCommentReport.do"
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
                                                }
                                            }];
        }
    }];
}

- (void)onVote:(UIButton *)btn
{
    FeedVoteExtendCell *view = (FeedVoteExtendCell *)self.v_Contents;
    
    //http://127.0.0.1:7080/api/sns/insertSnsPoll.do?userIdx=1004&comBraRIdx=10001&snsFeedIdx=13&snsPollIdx=5&pollNum=2
    NSArray *ar_VoteList = [self.dic_Info objectForKey_YM:@"SNSPollList"];
    NSDictionary *dic = ar_VoteList[view.nSelectRow];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"SNSFeedIdx"] integerValue]] forKey:@"snsFeedIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSPollIdx"] integerValue]] forKey:@"snsPollIdx"];
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"PollNum"] integerValue]] forKey:@"pollNum"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/insertSnsPoll.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            [self updateList];
                                        }
                                    }];

    
    
}

- (void)onKakao:(UIButton *)btn
{
    NSInteger nSnsFeedIdx = [[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey_YM:@"SNSFeedIdx"]] integerValue];
    
    KakaoTalkLinkAction *androidAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid
                                                                      devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                       execparam:@{@"greentube" : [NSString stringWithFormat:@"%ld", nSnsFeedIdx]}];
    
    KakaoTalkLinkAction *iphoneAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS
                                                                     devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                      execparam:@{@"greentube" : [NSString stringWithFormat:@"%ld", nSnsFeedIdx]}];
    
    
    NSString *str_StoreName = @"";
    
    NSInteger nDutiesPositionParentIdx = [[self.dic_Info objectForKey_YM:@"DutiesPositionParentIdx"] integerValue];
    if( nDutiesPositionParentIdx == 1000 )
    {
        NSString *str_Dept = [self.dic_Info objectForKey_YM:@"DeptName"];
        if( str_Dept == nil )
        {
            str_StoreName = [self.dic_Info objectForKey_YM:@"DeptNM"];
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
        str_StoreName = [self.dic_Info objectForKey_YM:@"ComNM"];
    }

    NSString *str_Title = [NSString stringWithFormat:@"%@(%@)님의 그린튜브", [self.dic_Info objectForKey_YM:@"NameKR"], str_StoreName];
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

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadOneSnsFeed" object:self.str_Row userInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
