//
//  WCCondition.h
//  WeatherCast
//
//  Created by Jonyzfu on 8/3/14.
//  Copyright (c) 2014 Jonyzfu. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <MTLModel.h>

// The MTLJSONSerializing protocol tells the Mantle serializer that this object has instructions on how to map JSON to Objective-C properties.
@interface WCCondition : MTLModel <MTLJSONSerializing>

// These are all of your weather data properties.
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSArray *conditionDescription;
@property (nonatomic, strong) NSArray *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSArray *icon;

// This is simply a helper method to map weather conditions to image files.
- (NSString *)imageName;

@end
