//
//  Worker.m
//  CheckIn
//
//  Created by heliumsoft on 8/28/15.
//  Copyright (c) 2015 Glenn. All rights reserved.
//

#import "Worker.h"

@implementation Worker

-(void)initWithEmployeeDictionary:(NSDictionary *)workerDic{
    
    NSArray * fields = [workerDic objectForKey:@"f"];
    
    self.workerID = [[fields objectAtIndex:0] objectForKey:@"__text"];
    self.name = [[fields objectAtIndex:1] objectForKey:@"__text"];
}

+(NSString *)fetchDateTimeStrWithEDT:(NSDate *)date{
    if (date == nil) {
        return @"";
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * formatDateStr = @"MM-dd-yyyy hh:mm a";
    NSTimeZone * timezone_EDT = [NSTimeZone timeZoneWithName:@"US/Eastern"];
    [formatter setTimeZone:timezone_EDT];
    
    [formatter setDateFormat:formatDateStr];
    
    return [formatter stringFromDate:date];
}

+(NSString *)fetchTimeStrWithEDT:(NSDate *)time{
    if (time == nil) {
        return @"";
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * formatDateStr = @"hh:mm a";
    NSTimeZone * timezone_EDT = [NSTimeZone timeZoneWithName:@"US/Eastern"];
    [formatter setTimeZone:timezone_EDT];
    [formatter setDateFormat:formatDateStr];
    NSString * timeStr = [formatter stringFromDate:time];
    return timeStr;
}

+(NSString *)fetchDateStr:(NSDate *)date{
    if (date == nil) {
        return @"";
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * formatDateStr = @"MM-dd-yyyy";
   
    [formatter setDateFormat:formatDateStr];
    
    return [formatter stringFromDate:date];
}

+(NSString *)fetchTimeStr:(NSDate *)time{
    if (time == nil) {
        return @"";
    }
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSString * formatDateStr = @"hh:mm a";

    [formatter setDateFormat:formatDateStr];
    
    return [formatter stringFromDate:time];
}


// Timeinteval for date : return = "2015-09-12 00:04:00 UTC"

-(NSDate *)getEDT_DateWithTimeInterval:(NSInteger)timeInterval{
    NSDate * tempUTCDate = [NSDate dateWithTimeIntervalSince1970:timeInterval]; // for example tempUTCDate = "2015-09-12 00:00:00 UTC"
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSTimeZone * timezone_UTC = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timezone_UTC];
    [formatter setDateFormat:@"yyyy-MM-ddd"];
    NSString * utcDateStr = [formatter stringFromDate:tempUTCDate];
    
    // Convert to EDT
    
    NSTimeZone * timezone_EDT = [NSTimeZone timeZoneWithName:@"US/Eastern"];
    [formatter setTimeZone:timezone_EDT];
    
    NSDate * tempEDTDate = [formatter dateFromString:utcDateStr]; // tempEDTDate = "2015-09-12 00:00:00 EDT"

    return tempEDTDate;
    
}


-(void)updateWithClockInDictionary:(NSDictionary *)clockInDic;
{
    NSArray * fields = [clockInDic objectForKey:@"f"];
    
    self.idString = [[fields objectAtIndex:0] objectForKey:@"__text"];
    self.workerID = [[fields objectAtIndex:1] objectForKey:@"__text"];
    self.name = [[fields objectAtIndex:2] objectForKey:@"__text"];
    
    NSString * startTimeStr = [[fields objectAtIndex:3] objectForKey:@"__text"];
    NSString * endTimeStr = [[fields objectAtIndex:4] objectForKey:@"__text"];
    
    NSString * picStartTimeStr = [[fields objectAtIndex:5] objectForKey:@"__text"];
    NSString * picEndTimeStr = [[fields objectAtIndex:6] objectForKey:@"__text"];
    
    if (startTimeStr != nil) {
        
        self.checkIn_Flag = YES;
        
        if (startTimeStr != nil) {
            self.startTime = [NSDate dateWithTimeIntervalSince1970:[startTimeStr integerValue]/1000];
        }
        
        if (endTimeStr != nil) {
            self.endTime = [NSDate dateWithTimeIntervalSince1970:[endTimeStr integerValue]/1000];
            
        }
        
        if (picStartTimeStr != nil) {
            self.picStartTime = [NSDate dateWithTimeIntervalSince1970:[picStartTimeStr integerValue]/1000];
            
        }
        
        if (picEndTimeStr != nil) {
            self.picEndTime = [NSDate dateWithTimeIntervalSince1970:[picEndTimeStr integerValue]/1000];
            
        }
    }
    
    self.checkOut_Flag = [[[fields objectAtIndex:7] objectForKey:@"__text"] boolValue];
    self.cost_code = [[fields objectAtIndex:8] objectForKey:@"__text"];
}
@end
