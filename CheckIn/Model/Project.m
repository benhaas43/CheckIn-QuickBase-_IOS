//
//  Project.m
//  CheckIn
//
//  Created by heliumsoft on 8/28/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "Project.h"

@implementation Project

+(Project *)initWithDictionary:(NSDictionary *)projectDic{
    
    NSArray * fields = [projectDic objectForKey:@"f"];
    
    Project * project = [[Project alloc] init];
    
    project.idString = [[fields objectAtIndex:0] objectForKey:@"__text"];
    project.projectID = [[fields objectAtIndex:0] objectForKey:@"__text"];
    project.title = [[fields objectAtIndex:1] objectForKey:@"__text"];
    
    
    return project;
}

@end
