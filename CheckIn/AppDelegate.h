//
//  AppDelegate.h
//  CheckIn
//
//  Created by heliumsoft on 8/25/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray * project_Workers;
@property (strong, nonatomic) NSMutableArray * workers;
@property (strong, nonatomic) NSString * currentProject_ID;

@property (strong, nonatomic) Project * currentProject;
@property (strong, nonatomic) Worker * currentWorker;

@end

