//
//  WCDailyForecast.m
//  WeatherCast
//
//  Created by Jonyzfu on 8/3/14.
//  Copyright (c) 2014 Jonyzfu. All rights reserved.
//

#import "WCDailyForecast.h"

@implementation WCDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // Get WCCondition‘s map and create a mutable copy of it.
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    
    // Change the max and min key maps to what you’ll need for the daily forecast.
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    
    // Return the new mapping.
    return paths;
    
}

@end
