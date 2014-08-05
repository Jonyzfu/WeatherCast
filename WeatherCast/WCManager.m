//
//  WCManager.m
//  WeatherCast
//
//  Created by Jonyzfu on 8/3/14.
//  Copyright (c) 2014 Jonyzfu. All rights reserved.
//

#import "WCManager.h"
#import "WCClient.h"
#import <TSMessages/TSMessage.h>

@interface WCManager()

@property (nonatomic, strong, readwrite) WCCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

// Declare a few other private properties for location finding and data fetching.
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WCClient *client;

@end

@implementation WCManager

+ (instancetype)sharedManager
{
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (id)init
{
    if (self = [super init]) {
        // Creates a location manager and sets it’s delegate to self.
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        // Creates the WCClient object for the manager.
        _client = [[WCClient alloc] init];
        
        // The manager observes the currentLocation key on itself using a ReactiveCocoa macro which returns a signal.
        [[[[RACObserve(self, currentLocation)
            ignore:nil]
           
           // It flattens the values and returns one object containing all three signals.
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [RACSignal merge:@[
                                         [self updateCurrentConditions],
                                         [self updateDailyForecast],
                                         [self updateHourlyForecast]
                                         ]];
               
               // Deliver the signal to subscribers on the main thread.
           }] deliverOn:RACScheduler.mainThreadScheduler]
         
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the latest weather." type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

- (void)findCurrentLocation
{
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Always ignore the first location update because it is almost always cached.
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    // Once you have a location with the proper accuracy, stop further updates.
    if (location.horizontalAccuracy > 0) {
        // Setting the currentLocation key triggers the RACObservable you set earlier in the init implementation.
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (RACSignal *)updateCurrentConditions
{
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate]
            doNext:^(WCCondition *condition) {
                self.currentCondition = condition;
            }];
}

- (RACSignal *)updateHourlyForecast
{
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions) {
                self.hourlyForecast = conditions;
            }];
}

- (RACSignal *)updateDailyForecast
{
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate]
            doNext:^(NSArray *conditions) {
                self.dailyForecast = conditions;
            }];
}

@end
