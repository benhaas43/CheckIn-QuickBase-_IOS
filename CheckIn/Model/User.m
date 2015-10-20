//
//  User.m
//  CheckIn
//
//  Created by heliumsoft on 9/4/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "User.h"

static User * instance;

@implementation User

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self.userId = [aDecoder decodeObjectForKey:@"userId"];
    self.email = [aDecoder decodeObjectForKey:@"email"];
    self.password = [aDecoder decodeObjectForKey:@"password"];
    self.ticket = [aDecoder decodeObjectForKey:@"ticket"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.ticket forKey:@"ticket"];
}


+(User *)sharedUser{
    
    if (instance ==nil) {
        instance = [[User alloc] init];
    }
    
    return instance;
}

@end
