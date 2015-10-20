//
//  AddWorkerVC.m
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "AddWorkerVC.h"
#import "Worker.h"


@interface AddWorkerVC ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>
{
    IBOutlet UISearchBar *workerSearchBar;
    IBOutlet UITableView * workersTableView;
    
    NSMutableArray * workerArray;
    
    NSArray * searchArray;
    
    BOOL isSearchMode;

    NSInteger selectedIndex;
}
@end

@implementation AddWorkerVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.project = APP.currentProject;
    
    [self initWorkersView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)initWorkersView{
    workerSearchBar.delegate = self;
    
    workersTableView.delegate = self;
    workersTableView.dataSource = self;
    
    [workersTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    if (APP.currentProject_ID != nil && [APP.currentProject_ID isEqualToString:self.project.projectID] && APP.workers != nil){
        workerArray = APP.workers;
    }else{
        [self loadData];
    }
}

-(IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadData{
    workerArray = [[NSMutableArray alloc] init];
    searchArray = [NSArray array];
    
    NSString * query = [NSString stringWithFormat:@"{'102'.XEX.'%@'}", self.project.projectID]; // 96
     NSString * clist = @"3.11"; // Record ID (Worker ID),  Full Name
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    
    [QuickBase QB_DoQueryForDBID:TABLE_WORKERS_DB_ID clist:clist query:query callbackBlock:^(NSData *xml, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error && xml != nil) {
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if (tempDic != nil) {
                
                Worker *tempWorker;
                NSDictionary * records = [[tempDic objectForKey:@"table"] objectForKey:@"records"];
                
                if (records != nil) {
                    NSArray * tempArray = [records objectForKey:@"record"];
                    
                    if (tempArray != nil) {
                        
                        if ([tempArray isKindOfClass:[NSDictionary class]]) {
                            tempWorker = [[Worker alloc] init];
                            [tempWorker initWithEmployeeDictionary:(NSDictionary *)tempArray];
                            
                            [workerArray addObject:tempWorker];
                            
                        }else{
                        
                            for (NSDictionary * recordDic in tempArray) {
                                
                                tempWorker = [[Worker alloc] init];
                                [tempWorker initWithEmployeeDictionary:recordDic];
                                
                                if (![self isExistWorker:tempWorker]) {
                                    [workerArray addObject:tempWorker];
                                }
                                
                            }
                        }
                    }
                }
                
                APP.currentProject_ID = self.project.projectID;
                APP.workers =workerArray;
                
                [workersTableView reloadData];
                
                return ;
            }
            
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            return ;
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
        return;
        
        
    }];
    
}

-(BOOL)isExistWorker:(Worker *)worker{
    if(workerArray == nil || [workerArray count] == 0) {
        return NO;
    }
    
    for (Worker * tempWorker in self.projectWorkers) {
        if ([tempWorker.name isEqualToString:worker.name]) {
            return YES;
        }
    }
    
    for (Worker * tempWorker in workerArray) {
        if ([tempWorker.name isEqualToString:worker.name]) {
            return YES;
        }
    }
    
    return NO;
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

    
    UILabel *  titleLabel = (UILabel *)[cell viewWithTag:112];
    titleLabel.text = tempObj.name;
    
    UIButton * addButton = (UIButton *)[cell viewWithTag:113];
    addButton.tag = indexPath.row;
    
    [addButton addTarget:self action:@selector(addWorker:) forControlEvents:UIControlEventTouchUpInside];
    
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

#pragma mark Button Delegate

-(void)addWorker:(UIButton *)sender{
    
    NSInteger tag = sender.tag;
    
    selectedIndex = tag;
    
    Worker * worker;
    
    if (isSearchMode) {
       worker = [searchArray objectAtIndex:tag];
    }else{
       worker = [workerArray objectAtIndex:tag];
    }
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:worker.name message:@"Are you sure you want to add this Worker to the project?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    alertView.tag = 1234;
    
    [alertView show];
    
}

#pragma mark AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1234) {
        if (buttonIndex == 1) {
            
            Worker *tempWorker = [workerArray objectAtIndex:selectedIndex];
           
            [self addWorkerToProject:tempWorker];
            
        }
    }
   
}

-(void)addWorkerToProject:(Worker *)worker{
    
    NSString * query = [NSString stringWithFormat:@"{'3'.EX.'%@'}", worker.workerID];
    NSString * clist = @"13.102.56.57.64.21.65.58.59.20.89.23.47.26.46.69.6.36.48.68.24.25"; // loading all field
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Adding...";
    
    [QuickBase QB_DoQueryForDBID:TABLE_WORKERS_DB_ID clist:clist query:query callbackBlock:^(NSData *xml, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error && xml != nil) {
           NSString * tempStr = [[NSString alloc] initWithData:xml encoding:NSUTF8StringEncoding];
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if (tempDic != nil) {
                NSDictionary * records = [[tempDic objectForKey:@"table"] objectForKey:@"records"];
                
                if (records != nil) {
                    NSDictionary * tempDic = [records objectForKey:@"record"];
                    
                    if (tempDic != nil) {
                        NSArray * fields = [tempDic objectForKey:@"f"];
                        if (fields != nil) {
                            NSMutableDictionary * newRecordDic = [[NSMutableDictionary alloc] init];
                            NSString * idString;
                            id value;
                            for (NSDictionary * fieldDic in fields) {
                                idString = [fieldDic objectForKey:@"_id"];
                                value = [fieldDic objectForKey:@"__text"] == nil ? @"":[fieldDic objectForKey:@"__text"];
                                
                                if ([idString isEqualToString:@"102"]) { // Project ID
                                    value = self.project.projectID;
                                }
                                
                                [newRecordDic setObject:value forKey:idString];
                            }
                            
                            [self addWorkerInQuickBase:newRecordDic withWorker:worker];
                            
                            return ;
                        }
                        
                    }
                }
                
                return ;
            }
            
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            return ;
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
        return;
        
        
    }];

}

-(void)addWorkerInQuickBase:(NSDictionary *)recordDic withWorker:(Worker *)worker{
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Adding...";
    
    [QuickBase QB_AddRecordToDBID:TABLE_WORKERS_DB_ID  values:recordDic callbackBlock:^(NSData *xml, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (!error) {
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if ([[tempDic objectForKey:NO_ERROR_KEY] isEqualToString:NO_ERROR]) {
                NSString * rid = [tempDic objectForKey:@"rid"];
                worker.workerID = rid;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_ADD_WORKER object:worker];
                [workerArray removeObjectAtIndex:selectedIndex];
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
                [workersTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Added to Project - '%@' Successfully!", self.project.title] message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            }
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
