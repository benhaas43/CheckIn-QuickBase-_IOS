//
//  WorkerVC.m
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "WorkerVC.h"
#import "Worker.h"
#import "WorkerProfileVC.h"
#import "AddWorkerVC.h"

@interface WorkerVC ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    IBOutlet UILabel * projectTitleLabel;
    IBOutlet UILabel * countLabel;
    
    IBOutlet UISearchBar *workersSearchBar;
    IBOutlet UITableView * workersTableView;
    
    IBOutlet UIButton * addButton;
    
    NSMutableArray * workerArray;
    
    NSArray * searchArray;
    
    BOOL isSearchMode;
    BOOL selectAddFlag;
}
@end

@implementation WorkerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.project = APP.currentProject;
    [self initWorkersView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_ADD_WORKER object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [workersTableView reloadData];
}

-(void)initWorkersView{
    workersSearchBar.delegate = self;
    
    workersTableView.delegate = self;
    workersTableView.dataSource = self;
    
    [workersTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    addButton.layer.cornerRadius = 5;
    
    projectTitleLabel.text = self.project.title;
    
    countLabel.text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addWorker:) name:NOTI_ADD_WORKER object:nil];
    
    [self loadData];

}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)loadData{
    workerArray = [[NSMutableArray alloc] init];
    searchArray = [NSArray array];
 
    
    NSString * query = [NSString stringWithFormat:@"{'48'.EX.'%@'}", self.project.projectID]; // Current Project ID 96
    NSString * clist = @"3.11"; // Record ID (Worker ID),  Full Name
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    
    [QuickBase QB_DoQueryForDBID:TABLE_WORKERS_DB_ID clist:clist query:query callbackBlock:^(NSData *xml, NSError *error) {
        
        if (!error && xml != nil) {
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if (tempDic != nil) {
                
                
                NSDictionary * records = [[tempDic objectForKey:@"table"] objectForKey:@"records"];
                
                if (records != nil) {
                    NSArray * tempArray = [records objectForKey:@"record"];
                    
                    if (tempArray != nil) {
                        
                        if ([tempArray isKindOfClass:[NSDictionary class]]) {
                            Worker *tempWorker = [[Worker alloc] init];
                            [tempWorker initWithEmployeeDictionary:(NSDictionary *)tempArray];
                            
                            [workerArray addObject:tempWorker];
                            
                        }else{
                            
                            for (NSDictionary * recordDic in tempArray) {
                                Worker *tempWorker = [[Worker alloc] init];
                                [tempWorker initWithEmployeeDictionary:recordDic];
                                
                                [workerArray addObject:tempWorker];
                            }
                        }
                    }
                }
                
                if (workerArray != nil) {
                    [self performSelectorOnMainThread:@selector(getWorkersFromClockIn) withObject:nil waitUntilDone:NO];
                    return ;
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [workersTableView reloadData];
                }
                
                
                return ;
            }
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            
            return ;
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
        return;
        
    }];

    
  //  [self getWorkersFromClockIn];
    

}

-(Worker *)fetchWorkerWithID:(NSString *)workerID{
    if (workerArray == nil) {
        return nil;
    }
    
    for (Worker * tempworker in workerArray) {
        if ([tempworker.workerID isEqualToString:workerID]) {
            return tempworker;
        }
    }
    
    return nil;
}

-(void)getWorkersFromClockIn{
    
    NSString * query = [NSString stringWithFormat:@"{'%@'.EX.'%@'}AND{'%@'.IR.'today'}",FIELD_CHECK_IN_PROJECT_FID, self.project.projectID, FIELD_CHECK_IN_DATE_FID]; // Current Project ID
   
    // ci , Project ID = 446, Project Name = 458  Worker ID = 447, Start time = 450 End time = 449 Pic start =455  Pict End time = 456, ciHourWorked = 451, Checkout Flag = 448, cost code = 454 , employee name 129
    
    NSString * clist = [NSString stringWithFormat:@"3.%@.%@.%@.%@.%@.%@.%@.%@",FIELD_CHECK_IN_WORKER_FID,FIELD_CHECK_IN_EMPLOYEE_NAME_FID, FIELD_CHECK_IN_START_TIME_FID, FIELD_CHECK_IN_END_TIME_FID, FIELD_CHECK_IN_PIC_START_FID, FIELD_CHECK_IN_PIC_END_FID, FIELD_CHECK_OUT_FLAG_FID, FIELD_CHECK_IN_COST_CODE_FID]; // Record ID , worker ID, Date, Start Time , End Time , Pic Start time , Pic End time ,Checkout Flag, Cost Code
    
    [QuickBase QB_DoQueryForDBID:TABLE_TIMESHEET_DB_ID clist:clist query:query callbackBlock:^(NSData *xml, NSError *error) {
        
        if (!error && xml != nil) {
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            Worker * tempWorker;
            NSArray * fields;
            NSString * workerId;
            
            if (tempDic != nil) {
                
                NSDictionary * records = [[tempDic objectForKey:@"table"] objectForKey:@"records"];
                
                if (records != nil) {
                    NSArray * tempArray = [records objectForKey:@"record"];
                    
                    if (tempArray != nil) {
                        
                        if ([tempArray isKindOfClass:[NSDictionary class]]) {
                            NSDictionary * tempClockInDic = (NSDictionary *)tempArray;
                            
                            fields = [tempClockInDic objectForKey:@"f"];
                            
                            workerId = [[fields objectAtIndex:1] objectForKey:@"__text"];
                            
                            tempWorker  = [self fetchWorkerWithID:workerId];
                            if(tempWorker != nil){
                                [tempWorker updateWithClockInDictionary:tempClockInDic];
                            }

            
                        }else{
                            
                            for (NSDictionary * recordDic in tempArray) {
                                fields = [recordDic objectForKey:@"f"];
                                
                                workerId = [[fields objectAtIndex:1] objectForKey:@"__text"];
                                
                                tempWorker  = [self fetchWorkerWithID:workerId];
                                if(tempWorker != nil){
                                    [tempWorker updateWithClockInDictionary:recordDic];
                                }

                            }
                        }
                    }
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [workersTableView reloadData];
                
                return ;
            }
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            
            return ;
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }];
}

-(void)addWorker:(NSNotification *)notification{
    Worker * newWorker = (Worker *)notification.object;
    
    if (newWorker != nil) {
        [workerArray addObject:newWorker];
        [workersTableView reloadData];
    }
}
     
#pragma  mark UITableView DataSource And Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workerCell"];
    
    Worker * tempObj;
    if (isSearchMode) {
        tempObj = [searchArray objectAtIndex:indexPath.row];
    }else{
        tempObj = [workerArray objectAtIndex:indexPath.row];
    }
    
    
    UILabel *  lightLabel = (UILabel *)[cell viewWithTag:111];
    lightLabel.layer.cornerRadius = lightLabel.frame.size.width/2;
    
    if (tempObj.checkIn_Flag ) { //&& !tempObj.checkOut_Flag
        lightLabel.backgroundColor = [UIColor greenColor];
    }else{
        lightLabel.backgroundColor = [UIColor redColor];
    }
    
    UILabel *  titleLabel = (UILabel *)[cell viewWithTag:112];
    titleLabel.text = tempObj.name;
    
    return  cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (isSearchMode) {
        if (searchArray != nil) {
            return  [searchArray count];
        }
    }else{
       
        if (workerArray != nil) {
            return  [workerArray count];
        }
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isSearchMode) {
        APP.currentWorker = [searchArray objectAtIndex:indexPath.row];
    }else{
        APP.currentWorker = [workerArray objectAtIndex:indexPath.row];
    }
}

#pragma mark UISearchBar Delegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    isSearchMode = YES;
    searchArray = workerArray;
    
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    isSearchMode = NO;
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO];
    
    [searchBar resignFirstResponder];
    
    [workersTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearchMode = YES;
    
    [self fetchSearchArray:searchText];
    
    [workersTableView reloadData];
}

-(void)fetchSearchArray:(NSString *)searchKey{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", searchKey];
    
    searchArray = [workerArray filteredArrayUsingPredicate:predicate];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoAdd"]) {
        AddWorkerVC * vc = (AddWorkerVC *)segue.destinationViewController;
        vc.projectWorkers = workerArray;
        
    }
}
@end
