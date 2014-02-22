//
//  AppSettings.h
//  SolarTracker
//
//  Created by Dave Sieh on 2/22/14.
//  Copyright (c) 2014 Dave Sieh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

+ (void)setDefaults;

+ (NSString *)stringForKey:(NSString *) key;

+ (NSUInteger)getMaximumDelay;
+ (void)setMaximumDelay:(NSUInteger) delay;

+ (NSUInteger)getFocus;
+ (void)setFocus:(NSUInteger) focus;

+ (NSUInteger)getMultiplier;
+ (void)setMultiplier:(NSUInteger) multiplier;

@end
