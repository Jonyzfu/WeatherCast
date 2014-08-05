//
//  WCManager.h
//  WeatherCast
//
//  Created by Jonyzfu on 8/3/14.
//  Copyright (c) 2014 Jonyzfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"
#import "ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h"
#import "WCCondition.h"

@interface WCManager : NSObject<CLLocationManagerDelegate>

// Use instancetype instead of WXManager so subclasses will return the appropriate type.
+ (instancetype) sharedManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WCCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// This method starts or refreshes the entire location and weather finding process.
- (void)findCurrentLocation;

@end
