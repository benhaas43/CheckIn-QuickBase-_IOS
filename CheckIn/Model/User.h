//
//  User.h
//  CheckIn
//
//  Created by heliumsoft on 9/4/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>

@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * ticket;

@property (nonatomic, strong) NSString * role;



+(User *)sharedUser;

@end
