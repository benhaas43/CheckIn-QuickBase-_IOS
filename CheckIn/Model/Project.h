//
//  Project.h
//  CheckIn
//
//  Created by heliumsoft on 8/28/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject

@property (nonatomic, strong) NSString * idString;
@property (nonatomic, strong) NSString * projectID;
@property (nonatomic, strong) NSString * title;

+(Project *)initWithDictionary:(NSDictionary *)projectDic;
@end
