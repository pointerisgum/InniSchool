//
//  MainWikiCell.h
//  InniSchool
//
//  Created by KimYoung-Min on 2015. 5. 20..
//  Copyright (c) 2015년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainWikiCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_Comment;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Gubun;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@end
