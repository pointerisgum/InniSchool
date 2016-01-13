//
//  MainLibView.m
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 20..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import "MainLibView.h"
#import "MainLibCell.h"
#import "StudyDetailViewController.h"
#import "AppDelegate.h"

@implementation MainLibView

- (void)updateNotiView
{
    [self.tbv_List reloadData];
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MainLibCell";
    MainLibCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    /*
     ArchivingCnt = 1;
     CertiGetPoint = "<null>";
     CertificatedYN = N;
     ClickCnt = 58;
     ComBraRIdx = 10001;
     CommentCnt = 2;
     CompleteProgressRate = 9;
     ContentType = 829;
     EssentialRecommendYN = 743;
     ExamButtonState = E0;
     ExamCnt = 0;
     ExamGetPoint = "<null>";
     ExamMinusPoint = "<null>";
     FavoriteCnt = 0;
     FullImgURL = "http://52.68.160.225:80/api/file_upload/20150507205619.png";
     HighScore = "<null>";
     ImgURL = "/file_upload/20150507205619.png";
     InfoMultimediaURL = "<null>";
     IntegrationCourseCnt = "<null>";
     IntegrationCourseIdx = 34;
     IntegrationCourseNM = test;
     IntegrationCourseTagList =     (
     {
     IntegrationCourseIdx = 34;
     TagIdx = 52;
     TagKeyword = t1;
     }
     );
     LangIdx = 0;
     LearnCurriculum = test;
     LearnTarget = test;
     LearningButtonState = L0;
     LearningDTYN = N;
     LearningEndDT = 20150429;
     LearningStartDT = 20150429;
     LecturerNM = test;
     LowScore = "<null>";
     MinimumProgressRate = 11;
     ProcessCD = "100|$|101|$|112";
     ProcessCD1 = 100;
     ProcessCD2 = 101;
     ProcessCD3 = 112;
     ProcessCDIdx = 112;
     ProcessNM = "\Uc81c\Ud488>\Uc720\Ud615\Ubcc4 \Uc81c\Ud488>\Ud329/\Ub9c8\Uc2a4\Ud06c";
     RegDate = 20150507;
     RegularTestScore = 22;
     UnCertiMinusPoint = "<null>";
     UserArchivingYN = N;
     UserExamScore = "-1";
     UserFavoriteYN = N;
     */
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    NSString *str_ImageUrl = [dic objectForKey_YM:@"FullImgURL"];
    
    [cell.iv_Thumb setImageWithString:str_ImageUrl placeholderImage:BundleImage(@"no_thumbnail.png") usingCache:NO];
    
    cell.lb_Title.text = [dic objectForKey_YM:@"IntegrationCourseNM"];
    
    cell.lb_Date.text = [NSString stringWithFormat:@"%@ ~ %@", [Util makeDate:[dic objectForKey_YM:@"LearningStartDT"]], [Util makeDate:[dic objectForKey_YM:@"LearningEndDT"]]];
    
    cell.iv_Play.hidden = YES;

    if( [[dic objectForKey_YM:@"ContentType"] integerValue] == 831 )
    {
        cell.iv_Play.hidden = NO;
    }
    else
    {
        cell.iv_Play.hidden = YES;
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.ar_List[indexPath.row];

//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    StudyDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"StudyDetailViewController"];
    vc.isLibMode = YES;
    vc.dic_Info = [NSDictionary dictionaryWithDictionary:dic];
    [self.vc_Parent.navigationController pushViewController:vc animated:YES];
}


@end
