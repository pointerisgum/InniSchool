//
//  StudyCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 7..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudyCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UIButton *btn_Filsu;
@property (nonatomic, weak) IBOutlet UIButton *btn_Sihum;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Depth;
@property (nonatomic, weak) IBOutlet UIView *v_Status;
@property (nonatomic, weak) IBOutlet UIView *v_Per;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UILabel *lb_Per;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Per;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UIButton *btn_ViewCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_CmtCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_FavCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_LikeCnt;
@end
