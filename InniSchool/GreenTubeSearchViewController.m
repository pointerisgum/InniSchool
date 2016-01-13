//
//  GreenTubeSearchViewController.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 14..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "GreenTubeSearchViewController.h"
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
#import <SDWebImage/UIImageView+WebCache.h>

static NSInteger snEmptyViewTag = 99;

@interface GreenTubeSearchViewController () <MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *ar_List;
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableDictionary *kakaoTalkLinkObjects;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation GreenTubeSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.screenName = @"그린튜브 검색";
    
    self.kakaoTalkLinkObjects = [[NSMutableDictionary alloc] init];

    [self initNavi];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateList];
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
    lb_Title.text = @"검색 결과";
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    [self.navigationItem.titleView addSubview:lb_Title];
    
    //네비 애니 관련 코드
    UIColor *naviTintColor = [UIColor colorWithHexString:@"004e0b"];
    [self.navigationController.navigationBar setBarTintColor:naviTintColor];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = [self whiteNaviBackButton];
}


- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:@"0" forKey:@"searchType"];
    [dicM_Params setObject:self.str_Keyword forKey:@"searchKeyword"];
    [dicM_Params setObject:@"1" forKey:@"startRowNum"];
    [dicM_Params setObject:@"100" forKey:@"endRowNum"];

    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        UIView *view = (UIView *)[self.tbv_List viewWithTag:snEmptyViewTag];
                                        [view removeFromSuperview];
                                        
                                        [self.ar_List removeAllObjects];
                                        self.ar_List = nil;
                                        
                                        if( resulte )
                                        {
                                            self.ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"SNSList"]];
                                        }
                                        
                                        if( self.ar_List == nil || self.ar_List.count <= 0 )
                                        {
                                            [self showEmpyView];
                                        }
                                        
                                        [self.tbv_List reloadData];
                                    }];
}

- (void)showEmpyView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"StudySearchEmpty" owner:self options:nil];
    UIView *view = [topLevelObjects objectAtIndex:0];
    view.tag = snEmptyViewTag;
    view.center = self.tbv_List.center;
    [self.tbv_List addSubview:view];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.ar_List.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_List[indexPath.section];

    NSInteger nContentType = [[dic objectForKey_YM:@"ContentType"] integerValue];
    switch (nContentType)
    {
        case 1002:
            //이미지
        {
//            static NSString *CellIdentifier = @"FeedImageCell";
//            FeedImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            if (cell == nil)
//            {
//                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
//                cell = [topLevelObjects objectAtIndex:0];
//            }
//            
//            cell.tag = indexPath.section;
//            [self setCellDefaultData:cell withData:dic];
//            
//            for( id subView in cell.sv_Thumbs.subviews )
//            {
//                if( [subView isKindOfClass:[UIImageView class]] )
//                {
//                    UIImageView *iv = (UIImageView *)subView;
//                    if( iv.tag > 0 )
//                    {
//                        [iv removeFromSuperview];
//                    }
//                }
//            }
//            
//            NSArray *ar_ImageList = [dic objectForKey:@"SNSAttachList"];
//            for( NSInteger i = 0; i < ar_ImageList.count; i++ )
//            {
//                NSDictionary *dic_Image = ar_ImageList[i];
//                NSInteger nType = [[dic_Image objectForKey_YM:@"AttachType"] integerValue];
//                if( nType == 1002 )
//                {
//                    SubTagUIImageView *iv = [[SubTagUIImageView alloc]initWithFrame:CGRectMake(i * (cell.sv_Thumbs.frame.size.width), 0,
//                                                                                               cell.sv_Thumbs.frame.size.width - 4, cell.sv_Thumbs.frame.size.height)];
//                    iv.tag = i + 1;
//                    iv.userInteractionEnabled = YES;
//                    iv.nSubTag = indexPath.section;
//                    iv.contentMode = UIViewContentModeScaleAspectFill;
//                    iv.clipsToBounds = YES;
//                    
//                    NSString *str_ImageUrl = [dic_Image objectForKey_YM:@"AttachFileFullURL_I"];
//                    [iv setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
//                    
//                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
//                    [singleTap setNumberOfTapsRequired:1];
//                    [iv addGestureRecognizer:singleTap];
//                    
//                    [cell.sv_Thumbs addSubview:iv];
//                }
//            }
//            
//            cell.sv_Thumbs.contentSize = CGSizeMake(cell.sv_Thumbs.frame.size.width * ar_ImageList.count, 0);
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
//            return cell;
            
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
                                             
                                             if( image )
                                             {
                                                 iv.image = image;
                                             }
                                             else
                                             {
                                                 iv.image = BundleImage(@"no_thumbnail.png");
                                             }
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
            
            return cell;
        }
            
        case 1004:
            //투표
        {
            static NSString *CellIdentifier = @"FeedVoteCell";
            FeedVoteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
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
//            //디폴트는 텍스트로 했다 (타입이 널로 넘어오는게 있음....흠...)
//            static NSString *CellIdentifier = @"FeedTextCell";
//            FeedTextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            if (cell == nil)
//            {
//                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
//                cell = [topLevelObjects objectAtIndex:0];
//            }
//            
//            cell.tag = indexPath.section;
//            [self setCellDefaultData:cell withData:dic];
//            
//            CGRect frame = cell.lb_Contents.frame;
//            frame.size.height = [Util getTextSize:cell.lb_Contents].height;
//            cell.lb_Contents.frame = frame;
//            
//            frame = cell.v_BottomMenu.frame;
//            frame.origin.y = cell.lb_Contents.frame.origin.y + cell.lb_Contents.frame.size.height + 15;
//            cell.v_BottomMenu.frame = frame;
//            
//            return cell;
            
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

- (void)setCellDefaultData:(FeedTextCell *)cell withData:(NSDictionary *)dic
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.layer.cornerRadius = 5.0f;
    
    cell.btn_Menu.tag = cell.btn_CmtCnt.tag = cell.btn_LikeCnt.tag = cell.btn_KakaoShare.tag = cell.tag;
    
    
    //작성자 이미지
    NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
    [cell.iv_User setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"thumbnail_middle2.png") usingCache:NO];
    
    
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
    

    //내용
//    cell.lb_Contents.text = [dic objectForKey_YM:@"SNSContent"];
    NSString *str_Contents = [dic objectForKey_YM:@"SNSContent"];
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
    
    NSDictionary *dic = self.ar_List[indexPath.section];
    
    GreenTubeDetailViewController *vc = [[GreenTubeDetailViewController alloc]initWithNibName:@"GreenTubeDetailViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    vc.str_Row = [NSString stringWithFormat:@"%ld", indexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_List[indexPath.section];

    NSInteger nContentType = [[dic objectForKey_YM:@"ContentType"] integerValue];
    switch (nContentType)
    {
        case 1002:
            //이미지
        {
//            FeedImageCell *cell = (FeedImageCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//            
////            cell.lb_Contents.text = [dic objectForKey_YM:@"SNSContent"];
//            NSString *str_Contents = [dic objectForKey_YM:@"SNSContent"];
//            NSString *br = @"\n";
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
//            str_Contents = [str_Contents gtm_stringByUnescapingFromHTML];
//            cell.lb_Contents.text = str_Contents;
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
            return 342.0f;
        }
            
        case 1003:
            //동영상
        {
//            FeedMovieCell *cell = (FeedMovieCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//            
////            cell.lb_Contents.text = [dic objectForKey_YM:@"SNSContent"];
//            NSString *str_Contents = [dic objectForKey_YM:@"SNSContent"];
//            NSString *br = @"\n";
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
//            str_Contents = [str_Contents gtm_stringByUnescapingFromHTML];
//            cell.lb_Contents.text = str_Contents;
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
            return 365.0f;
        }
            
        case 1004:
            //투표
        {
            FeedVoteCell *cell = (FeedVoteCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            
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

//            //디폴트는 텍스트로 했다 (타입이 널로 넘어오는게 있음....흠...)
//            FeedTextCell *cell = (FeedTextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//            
////            cell.lb_Contents.text = [dic objectForKey_YM:@"SNSContent"];
//            NSString *str_Contents = [dic objectForKey_YM:@"SNSContent"];
//            NSString *br = @"\n";
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br/>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"<br>" withString:br];
//            str_Contents = [str_Contents stringByReplacingOccurrencesOfString:@"</br>" withString:br];
//            str_Contents = [str_Contents gtm_stringByUnescapingFromHTML];
//            cell.lb_Contents.text = str_Contents;
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
        }
    }
    
    
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
    //nSubTag는 index.section값
    //tag는 이미지 순서값
    SubTagUIImageView *iv = (SubTagUIImageView *)gestureRecognizer.view;
    
    self.ar_Photo = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    
    NSDictionary *dic = self.ar_List[iv.nSubTag];
    
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
- (void)onMovie:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    
    GreenTubeDetailViewController *vc = [[GreenTubeDetailViewController alloc]initWithNibName:@"GreenTubeDetailViewController" bundle:nil];
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    vc.isMoviePlay = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onComment:(UIButton *)btn
{
//    NSDictionary *dic = self.ar_List[btn.tag];
    
}

- (void)onLike:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    
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
    NSDictionary *dic = self.ar_List[idx];
    
    NSString *str_FeedIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"comBraRIdx"] forKey:@"comBraRIdx"];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userIdx"] forKey:@"userIdx"];
    [dicM_Params setObject:str_FeedIdx forKey:@"snsFeedIdx"];
    [dicM_Params setObject:@"0" forKey:@"searchType"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"sns/selectSnsList.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSArray *ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"SNSList"]];
                                            if( ar.count > 0 )
                                            {
                                                NSDictionary *dic_Item = [ar firstObject];
                                                [self.ar_List replaceObjectAtIndex:idx withObject:dic_Item];
                                                [self.tbv_List reloadData];
                                            }
                                        }
                                    }];
}

- (void)onKakao:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    
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

- (void)onMenu:(UIButton *)btn
{
    //내 글일때
    //수정, 삭제, 아카이빙/아카이빙취소
    
    //남의 글일때
    //신고, 아카이빙/아카이빙취소
    
    NSDictionary *dic = self.ar_List[btn.tag];
    
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
        
        [arM_Menus addObject:@"보관하기 취소"];
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
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"notiRemoveItemAtFeedIdx"
                                                                                                                             object:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]]
                                                                                                                           userInfo:nil];
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
             else if( buttonIndex == 2 )
             {
                 //아카이빙 등록 / 취소
                 [self archiving:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]]];
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
                 [self archiving:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"SNSFeedIdx"] integerValue]]];
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

@end
