//
//  WorkerDetailCell.h
//  CheckIn
//
//  Created by heliumsoft on 8/27/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WorkerDetailCellDelegate <NSObject>

-(void)editTime:(NSIndexPath *)indexpath;
-(void)editCostCode:(NSIndexPath *)indexpath;

@end
@interface WorkerDetailCell : UITableViewCell
{
    IBOutlet UIView * containerView;
    IBOutlet UIButton *editTimeButton;
    
     IBOutlet UIView * selectView;
    
}
@property (nonatomic, weak) IBOutlet UILabel * nameLabel;
@property (nonatomic, weak) IBOutlet UILabel * dateLabel;
@property (nonatomic, weak) IBOutlet UILabel * startLabel;
@property (nonatomic, weak) IBOutlet UILabel * endLabel;
@property (nonatomic, weak) IBOutlet UILabel * totalLabel;
@property (nonatomic, weak) IBOutlet UILabel * codeLabel;
@property (nonatomic, weak) IBOutlet AsyncImageView * profileImageView;

@property (nonatomic, strong) NSIndexPath * indexPath;

@property (nonatomic, strong) id<WorkerDetailCellDelegate> delegate;

-(IBAction)onEditTime:(id)sender;
-(IBAction)onEditCostCode:(id)sender;
-(void)renderCellWithWorker:(Worker *)worker;
@end
