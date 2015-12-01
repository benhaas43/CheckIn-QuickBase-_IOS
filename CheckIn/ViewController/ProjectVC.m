//
//  ProjectVC.m
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "ProjectVC.h"
#import "Project.h"
#import "WorkerVC.h"


@interface ProjectVC ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    IBOutlet UISearchBar *projectSearchBar;
    IBOutlet UITableView * projectTableView;

    NSMutableArray * projectArray;
    
    NSArray * searchArray;
    
    BOOL isSearchMode;
}

@end

@implementation ProjectVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initProjectView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


-(void)initProjectView{
    
    [self.navigationItem setHidesBackButton:YES];
    
    projectSearchBar.delegate = self;
    
    projectTableView.delegate = self;
    projectTableView.dataSource = self;
    
    [projectTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self loadData];
}

-(void)loadData{
    projectArray = [[NSMutableArray alloc] init];
    searchArray = [NSArray array];
     NSString *query = @"";

//    if ([[User sharedUser].role isEqualToString:ROLE_TYPE_PROJECT_MANAGER]) {
//        
//        query = [NSString stringWithFormat:@"'773'.HAS.'%@'",[User sharedUser].userId];
//    }else if([[User sharedUser].role isEqualToString:ROLE_TYPE_Super]){
//       
//        query = [NSString stringWithFormat:@"'774'.HAS.'%@'",[User sharedUser].userId];
//    }
   
    NSString * clist = @"3.298"; // Record ID, Project ID, Project Title,
   
    
  //  query = @"'207'.IR.'today'";
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    
    [QuickBase QB_DoQueryForDBID:TABLE_PROJECTS_DB_ID clist:clist query:query callbackBlock:^(NSData *xml, NSError *error) {
        
        if (!error && xml != nil) {
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];

            if (tempDic != nil) {
                
                
                NSDictionary * records = [[tempDic objectForKey:@"table"] objectForKey:@"records"];
                
                if (records != nil) {
                    NSArray * tempArray = [records objectForKey:@"record"];
                    
                    if ([tempArray isKindOfClass:[NSDictionary class]]) {
                        NSDictionary * tempProjectDic = (NSDictionary *)tempArray;
                        Project *tempProject = [Project initWithDictionary:tempProjectDic];
                        
                        [projectArray addObject:tempProject];
                        
                    }else{
                    
                        if (tempArray != nil) {
                            for (NSDictionary * recordDic in tempArray) {
                                Project *tempProject = [Project initWithDictionary:recordDic];
                                
                                [projectArray addObject:tempProject];
                            }
                        }
                    }
                    
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [projectTableView reloadData];
                
                return ;
            }
            
            
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
            return ;
        }
        
                [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];

        return;
        
        
    }];
        
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"projectCell"];
//    
    Project *tempObj;
    
    if (isSearchMode) {
        tempObj = [searchArray objectAtIndex:indexPath.row];
    }else{
        tempObj = [projectArray objectAtIndex:indexPath.row];
    }
    
    
    UILabel *  titleLabel = (UILabel *)[cell viewWithTag:112];
    titleLabel.text = tempObj.title;
    
    return  cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (isSearchMode) {
        if (searchArray != nil) {
            return  [searchArray count];
        }
    }else{
       
        if (projectArray != nil) {
            return  [projectArray count];
        }
    }
    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (isSearchMode) {
         APP.currentProject = [searchArray objectAtIndex:indexPath.row];
     }else{
        APP.currentProject = [projectArray objectAtIndex:indexPath.row];
     }
}

#pragma mark UISearchBar Delegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES];
    isSearchMode = YES;
    searchArray = projectArray;
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    isSearchMode = NO;
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO];
    
    [searchBar resignFirstResponder];
    
    [projectTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    isSearchMode = YES;
    
    [self fetchSearchArray:searchText];
    
    [projectTableView reloadData];
}

-(void)fetchSearchArray:(NSString *)searchKey{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[c] %@", searchKey];
    
    searchArray = [projectArray filteredArrayUsingPredicate:predicate];
    
}


-(IBAction)onLogout:(id)sender{
    
    [QuickBase QB_SignOut:^(NSData *data, NSError *error) {
        
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:USER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
