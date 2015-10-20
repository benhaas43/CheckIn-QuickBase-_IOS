//
//  Worker.h
//  CheckIn
//
//  Created by heliumsoft on 8/28/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Worker : NSObject

@property (nonatomic, strong) NSString * idString;
@property (nonatomic, strong) NSString * workerID;
@property (nonatomic, strong) NSString * name;

//@property (nonatomic, strong) NSDate * workDate;

@property (nonatomic, strong) NSDate * startTime;
@property (nonatomic, strong) NSDate * endTime;

@property (nonatomic, strong) NSDate * picStartTime;
@property (nonatomic, strong) NSDate * picEndTime;

@property (nonatomic, strong) NSMutableArray * images;

@property (nonatomic, assign) BOOL checkIn_Flag;
@property (nonatomic, assign) BOOL checkOut_Flag;

@property (nonatomic, strong) UIImage * startPic;
@property (nonatomic, strong) UIImage * endPic;

@property (nonatomic, strong) NSString * cost_code;

-(void)initWithEmployeeDictionary:(NSDictionary *)workerDic;
-(void)updateWithClockInDictionary:(NSDictionary *)clockInDic;


+(NSString *)fetchDateStr:(NSDate *)date;
+(NSString *)fetchTimeStr:(NSDate *)time;

+(NSString *)fetchDateTimeStrWithEDT:(NSDate *)date;
+(NSString *)fetchTimeStrWithEDT:(NSDate *)time;


@end
