//
//  WCClient.h
//  WeatherCast
//
//  Created by Jonyzfu on 8/3/14.
//  Copyright (c) 2014 Jonyzfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface WCClient : NSObject

@property(nonatomic, strong) NSURLSession *session;


- (RACSignal *)fetchJSONFromURL: (NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation: (CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchHourlyForecastForLocation: (CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation: (CLLocationCoordinate2D)coordinate;


@end
