//
//  LoginVC.m
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()<UITextFieldDelegate>
{
    IBOutlet UIView * loginSubView;
    IBOutlet UITextField * emailTextField;
    IBOutlet UITextField * passTextField;
    
    IBOutlet UIButton * loginButton;
}

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLoginView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initLoginView{
   
    emailTextField.delegate = self;
    passTextField.delegate = self;
    
    loginButton.layer.cornerRadius = 5;

    loginSubView.layer.cornerRadius = 5;
    loginSubView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    loginSubView.layer.borderWidth = 1.2f;
    
   
 
    NSString * savedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:USER_EMAIL];
    if (savedEmail != nil) {
        emailTextField.text = savedEmail;
    }
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    passTextField.text = @"";
    
    NSString * savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PASSWORD];
    if (savedPassword != nil && ![savedPassword isEqualToString:@""]) {
        passTextField.text = savedPassword;
        
        [self onLogin:nil];
    }
}

-(IBAction)onLogin:(id)sender{
    
    
    NSString * alertStr = nil;
    if ([emailTextField.text isEqualToString:@""]) {
        alertStr = @"Email Field is Empty. Please enter Email";
    //}else if(![self isValidMailAddress:emailTextField.text]){
   //     alertStr = @"Email is Invalid Format!";
    }else if([passTextField.text isEqualToString:@""]){
        alertStr = @"Password Field is Empty!";
    }
    
    if (alertStr != nil) {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:alertStr delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return ;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:emailTextField.text forKey:USER_EMAIL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Log in...";
    
    [QuickBase QB_AuthenticateUsername:emailTextField.text withPassword:passTextField.text appToken:APP_TOKEN callbackBlock:^(NSData *xml, NSError *error) {
        NSLog(@"Error: %@", error);
        if (!error) {
            [User sharedUser].email = emailTextField.text;
            [User sharedUser].password = passTextField.text;
            
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
            
            if (tempDic != nil) {
                if ([[tempDic objectForKey:NO_ERROR_KEY] isEqualToString:NO_ERROR]) {
                    [User sharedUser].ticket = [tempDic objectForKey:TICKET_KEY];
                    [User sharedUser].userId = [tempDic objectForKey:USERID_KEY];
                    
                    
                    [self hasValidRole];
                    
                    return ;   
                }
            }
           
            
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
            return ;
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
    }];
    
    
}

-(void)hasValidRole{
    [QuickBase QB_GetUserRole:^(NSData * xml, NSError *error) {
        if (!error && xml != nil) {
            NSDictionary * tempDic = [NSDictionary dictionaryWithXMLData:xml];
           
            if (tempDic != nil) {
                if ([[tempDic objectForKey:NO_ERROR_KEY] isEqualToString:NO_ERROR]) {
                   NSDictionary * tempUserDic = [tempDic objectForKey:@"user"];
                    if (tempUserDic != nil) {
                        NSDictionary * roles = [tempUserDic objectForKey:@"roles"];
                        if (roles != nil) {
                            NSDictionary * tempRole = [roles objectForKey:@"role"];
                            if (tempRole != nil) {
                                NSString *roleName = [tempRole objectForKey:@"name"];
                                
                                if(roleName != nil && ([roleName isEqualToString:ROLE_TYPE_ADMIN] || [roleName isEqualToString:ROLE_TYPE_PROJECT_MANAGER] || [roleName isEqualToString:ROLE_TYPE_Super] || [roleName isEqualToString:ROLE_TYPE_MANAGEMENT]|| [roleName isEqualToString:ROLE_TYPE_SERVICE_MANAGER]|| [roleName isEqualToString:ROLE_TYPE_PRODUCTION_MANAGER]))
                                {
                                    [User sharedUser].role = roleName;
                                    
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                     [self gotoProject];
                                    return ;
                                }
                            }
                        }
                    }
                    
                   
                }

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

-(void)gotoProject{
    
    [[NSUserDefaults standardUserDefaults] setObject:passTextField.text forKey:USER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
     [self performSegueWithIdentifier:@"gotoProject" sender:nil];
}

#pragma  - Helper
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == emailTextField) {
        [passTextField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
        
        [self onLogin:nil];
    }
    return true;
}


-(void)alertViewWithTitle:(NSString*)title
{
    UIAlertView*alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
}

-(BOOL)isValidMailAddress:(NSString *)strMailAddr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strMailAddr];
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
