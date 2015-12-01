//
//  WorkerProfileVC.m
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "WorkerProfileVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "EditTimeVC.h"

@interface WorkerProfileVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    
    IBOutlet UILabel * checkStatusLabel;
    
    IBOutlet UIView * containerView1;
    IBOutlet UILabel * nameLabel;
    IBOutlet UILabel * dateLabel;
    IBOutlet UILabel * startLabel;
    IBOutlet UILabel * endLabel;
    
    IBOutlet UIView * containerView2;
    IBOutlet UILabel * totalLabel;

    
    IBOutlet UIButton * profileImageButton;
    
    // Photos
    
    IBOutlet UIView * checkInView;
    IBOutlet UIImageView * checkInImageView;
    IBOutlet UILabel * checkInTimeLabel;
    
    IBOutlet UIView * checkOutView;
    IBOutlet UIImageView * checkOutImageView;
    IBOutlet UILabel * checkOutTimeLabel;
    
    IBOutlet UIButton * editButton;
    
    NSMutableArray * profileImages;
    
    UIPopoverController *imagePopover;
}
@end

@implementation WorkerProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.worker = APP.currentWorker;
    
    [self initProfileView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateDateView];
}

-(void)initProfileView{
    
    containerView1.layer.cornerRadius = 5 ;
    containerView1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    containerView1.layer.borderWidth = 1.2f;
    
    containerView2.layer.cornerRadius = 5 ;
    containerView2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    containerView2.layer.borderWidth = 1.2f;
    
    profileImageButton.imageView.layer.cornerRadius  =10 ;
    profileImageButton.imageView.clipsToBounds = YES;
    profileImageButton.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    profileImageButton.imageView.layer.borderWidth = 1.2f;
    
    checkInImageView.layer.cornerRadius  = 10;
    checkOutImageView.layer.cornerRadius  = 10;
    
    
    editButton.layer.cornerRadius = 5;

    [editButton setUserInteractionEnabled:YES];
    [editButton setBackgroundColor:[UIColor colorWithRed:72/255.0f green:119/255.0f blue:192/255.0f alpha:1.0f]];

    
    if (self.worker.checkIn_Flag && !self.worker.checkOut_Flag) {
        [profileImageButton setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal]; // Check In Photo Setting
        [checkStatusLabel setText:@"Touch Camera To Check This Worker Out"];
        
    }else if(self.worker.checkIn_Flag && self.worker.checkOut_Flag){
        [checkStatusLabel setText:@"Checked This Worker Out"];
        [profileImageButton setUserInteractionEnabled:NO];
    }else{
        [checkStatusLabel setText:@"Touch Camera To Check This Worker In"];
        [profileImageButton setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal]; // Camera Setting
        [editButton setBackgroundColor:[UIColor grayColor]];
        [editButton setUserInteractionEnabled:NO];
    }
    
    // Quick base image DownLoad  : https://mycompany.quickbase.com/up/DBID/a/rRID/eFID/vVID
    
    
    ///// CheckIn Picture loading and display
    if (self.worker.checkIn_Flag && self.worker.startPic == nil && self.worker.idString != nil) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * checkInImageUrlStr = [NSString stringWithFormat:@"%@/%@/a/r%@/e%@/v0",APP_BASE_URL, TABLE_TIMESHEET_DB_ID, self.worker.idString, FIELD_CHECK_IN_PIC_FID];
            NSData * tempData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:checkInImageUrlStr]];
            if (tempData != nil) {
                UIImage * checkInImage = [[UIImage alloc] initWithData:tempData];
                self.worker.startPic = checkInImage;
                [checkInImageView setImage:self.worker.startPic];
                
            }
        });
    }
    
    if (self.worker.startPic != nil) {
        [checkInImageView setImage:self.worker.startPic];
    }
    
    ///// CheckOut Picture loading and display
    if (self.worker.checkOut_Flag && self.worker.endPic == nil && self.worker.idString != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * checkOutImageUrlStr = [NSString stringWithFormat:@"%@/%@/a/r%@/e%@/v0",APP_BASE_URL, TABLE_TIMESHEET_DB_ID, self.worker.idString, FIELD_CHECK_OUT_PIC_FID];
            NSData * tempData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:checkOutImageUrlStr]];
            if (tempData != nil) {
                UIImage * checkOutImage = [[UIImage alloc] initWithData:tempData];
                self.worker.endPic = checkOutImage;
                [checkOutImageView setImage:self.worker.endPic];
                
            }
        });
        
    }
    if (self.worker.endPic != nil) {
        [checkOutImageView setImage:self.worker.endPic];
    }

    
    nameLabel.text = self.worker.name;
    
}

-(void)updateDateView
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * dateFormatStr = @"EEE. MM/dd/yyyy";
    NSString * timeFormatStr = @"hh:mm a";
    
    [formatter setDateFormat:dateFormatStr];
    
    dateLabel.text = @"";
    startLabel.text = @"";
    endLabel.text = @"";
    totalLabel.text = @"";
    
    checkInTimeLabel.text = @"Checked In Pic";
    checkOutTimeLabel.text = @"Checked Out Pic";
    if (self.worker.startTime != nil) {
        
        dateLabel.text = [formatter stringFromDate:self.worker.startTime];
    }
    
    [formatter setDateFormat:timeFormatStr];
    
    if (self.worker.startTime != nil) {
        startLabel.text = [formatter stringFromDate:self.worker.startTime];
        
    }
    
    if (self.worker.picStartTime != nil) {
        checkInTimeLabel.text = [formatter stringFromDate:self.worker.picStartTime];
    }
    
    if (self.worker.endTime != nil) {
        
        endLabel.text = [formatter stringFromDate:self.worker.endTime];
        totalLabel.text = [NSString stringWithFormat:@"%@ hrs", [self fetchHourWorked]];
    }
    
    if (self.worker.picEndTime != nil) {
        checkOutTimeLabel.text = [formatter stringFromDate:self.worker.endTime];
       
    }

}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)onCheckIn:(id)sender{
    
    [self addImage];
    
}

-(NSString *)fetchHourWorked{
    int interval = (int)[self.worker.endTime timeIntervalSinceDate:self.worker.startTime];
    return [NSString stringWithFormat:@"%d:%d", interval/3600, (interval%3600)/60];
}

-(void)changeCheckStatus:(UIImage *)image{
    
    if (!self.worker.checkIn_Flag) {
        
        self.worker.startTime = [NSDate date];
        self.worker.picStartTime = [NSDate date];
        self.worker.startPic = [self resizeImage:image];
        
        [self saveCheckInToQB];
        
    }else{
        
        if (self.worker.endTime == nil) {
            self.worker.endTime = [NSDate date];
        }
        
        self.worker.picEndTime = [NSDate date];
        self.worker.endPic = [self resizeImage:image];
        
        [self saveCheckOutToQB];
        
    }
    
}

-(void)checkIn{
    self.worker.checkIn_Flag = YES;
    [checkStatusLabel setText:@"Touch Camera To Check This Worker Out"];
    
    [editButton setBackgroundColor:[UIColor colorWithRed:72/255.0f green:119/255.0f blue:192/255.0f alpha:1.0f]];
    [editButton setUserInteractionEnabled:YES];
    [checkInImageView setImage:self.worker.startPic];
}

-(void)checkOut{
    self.worker.checkOut_Flag = YES;
    [checkStatusLabel setText:@"Checked This Worker Out"];
    
    [profileImageButton setUserInteractionEnabled:NO];
    [checkOutImageView setImage:self.worker.endPic];

}

-(void)saveCheckInToQB{
    
    NSMutableDictionary * recordDic = [[NSMutableDictionary alloc] init];
    [recordDic setObject:APP.currentProject.projectID forKey:FIELD_CHECK_IN_PROJECT_FID];
    [recordDic setObject:self.worker.workerID forKey:FIELD_CHECK_IN_WORKER_FID];
    
    [recordDic setObject:[Worker fetchDateTimeStrWithEDT:self.worker.startTime] forKey:FIELD_CHECK_IN_START_TIME_FID];
    [recordDic setObject:[Worker fetchTimeStrWithEDT:self.worker.picStartTime] forKey:FIELD_CHECK_IN_PIC_START_FID];
    
//    [recordDic setObject:self.worker.workerID forKey:FIELD_EMPLOYEE_ID_FID];
//    [recordDic setObject:APP.currentProject.projectID forKey:FIELD_PROJECT_ID_FID];

    [recordDic setObject:self.worker.startPic forKey:FIELD_CHECK_IN_PIC_FID];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Check In...";

    [QuickBase QB_AddRecordToDBID:TABLE_TIMESHEET_DB_ID  values:recordDic callbackBlock:^(NSData *xml, NSError *error) {
       
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {

            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if ([[tempDic objectForKey:NO_ERROR_KEY] isEqualToString:NO_ERROR]) {
                NSString * rid = [tempDic objectForKey:@"rid"];
                self.worker.idString = rid;
                
            //    [self refreshRecord];
                [self updateDateView];
                
                [self checkIn];
                
            }else{
                [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            }
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
    }];

}

-(void)refreshRecord{
    
    NSMutableDictionary * recordDic = [[NSMutableDictionary alloc] init];
    [recordDic setObject:[Worker fetchDateTimeStrWithEDT:self.worker.startTime] forKey:FIELD_CHECK_IN_START_TIME_FID];
    
    [QuickBase QB_EditRecord:self.worker.idString toDBID:TABLE_TIMESHEET_DB_ID values:recordDic  callbackBlock:^(NSData *xml, NSError *error) {
        
        if (!error) {
             NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
        }
        
    }];
     
}
-(void)saveCheckOutToQB
{
    NSMutableDictionary * recordDic = [[NSMutableDictionary alloc] init];
   
    [recordDic setObject:[Worker fetchDateTimeStrWithEDT:self.worker.endTime] forKey:FIELD_CHECK_IN_END_TIME_FID]; // End Time
    [recordDic setObject:[Worker fetchTimeStrWithEDT:self.worker.picEndTime] forKey:FIELD_CHECK_IN_PIC_END_FID]; // Pic End Time
    [recordDic setObject:@"1" forKey:FIELD_CHECK_OUT_FLAG_FID];  // Check Out Flag
    [recordDic setObject:self.worker.endPic forKey:FIELD_CHECK_OUT_PIC_FID];   // Pic End Pic
 //   [recordDic setObject:[self fetchHourWorked] forKey:FIELD_CHECK_IN_HOURWORKED_FID]; // HourWorked
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Check Out...";
    
    [QuickBase QB_EditRecord:self.worker.idString toDBID:TABLE_TIMESHEET_DB_ID values:recordDic  callbackBlock:^(NSData *xml, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            NSString * tempStr = [[NSString alloc] initWithData:xml encoding:NSUTF8StringEncoding];
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if ([[tempDic objectForKey:NO_ERROR_KEY] isEqualToString:NO_ERROR]) {
                NSString * rid = [tempDic objectForKey:@"rid"];
                
                [self updateDateView];
                [self checkOut];
            
            }else{
                 [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            }
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
    }];

}

/// Edit iMage
- (void)addImage
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Take a Photo", @"Photo Library" ,nil];
   

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [actionSheet showFromRect:profileImageButton.frame inView:self.view animated:YES ];
        
    }else {
        [actionSheet showInView:self.view];
    }
    
}

// Actionsheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 0) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
             [self onAddImageFromCamera];
         });
    }else if (buttonIndex == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onAddImageFromLibrary];
        });
       
    }
}


- (void)onAddImageFromCamera
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:pickerController];
        [popover presentPopoverFromRect:profileImageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        imagePopover = popover;
    } else {
        [self presentViewController:pickerController animated:YES completion:nil];
    }

}

- (void)onAddImageFromLibrary
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:pickerController];
       
        [popover presentPopoverFromRect:profileImageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        imagePopover = popover;
    } else {
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    
}


//// Image Picker Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        UIImage *resultImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!resultImage) {
            resultImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        [self changeCheckStatus:resultImage];
        
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [imagePopover dismissPopoverAnimated:YES];
    }else{
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [imagePopover dismissPopoverAnimated:YES];
    }else{
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}


-(UIImage *)resizeImage:(UIImage *)image{
    
    CGFloat height = image.size.height *  IMAGE_WIDTH/image.size.width;
    CGFloat width = IMAGE_WIDTH;
    
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"gotoWorkerEdit"]) {
        EditTimeVC * vc = (EditTimeVC *)(segue.destinationViewController);
        vc.worker = self.worker;
    }
}


@end
