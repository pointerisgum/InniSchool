//
//  WikiCommentCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 15..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WikiCommentCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Seper;
@property (nonatomic, weak) IBOutlet UILabel *lb_Writer;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UIButton *btn_Delete;
@property (nonatomic, weak) IBOutlet UIButton *btn_Report;
@property (nonatomic, weak) IBOutlet UIButton *btn_Modify;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Thumb;
@property (nonatomic, weak) IBOutlet UIButton *btn_Heart;
@end
