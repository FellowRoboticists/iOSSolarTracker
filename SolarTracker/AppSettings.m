//
//  AppSettings.m
//  SolarTracker
//
//  Created by Dave Sieh on 2/22/14.
//  Copyright (c) 2014 Dave Sieh. All rights reserved.
//

#import "AppSettings.h"

static NSUInteger const kDefaultMaximumDelay = 10;
static NSUInteger const kDefaultFocus = 2;
static NSUInteger const kDefaultMultiplier = 10;

// The keys

static NSString * const kMaximumDelay = @"MaximumDelay";
static NSString * const kFocus = @"Focus";
static NSString * const kMultiplier = @"Multiplier";

@interface AppSettings ()

+ (NSUserDefaults *)userDefaults;

@end

@implementation AppSettings

+ (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

+ (void)setDefaults {
    NSDictionary *initialDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:kDefaultMaximumDelay], kMaximumDelay,
                                     [NSNumber numberWithInt:kDefaultFocus], kFocus,
                                     [NSNumber numberWithInt:kDefaultMultiplier], kMultiplier,
                                     nil];
    
    [self.userDefaults registerDefaults:initialDefaults];
}

+ (NSString *)stringForKey:(NSString *) key {
    return [self.userDefaults stringForKey:key];
}

+ (NSUInteger)getMaximumDelay {
    return [self.userDefaults integerForKey:kMaximumDelay];
}

+ (void)setMaximumDelay:(NSUInteger) delay {
    [self.userDefaults setInteger:delay forKey:kMaximumDelay];
}

+ (NSUInteger)getFocus {
    return [self.userDefaults integerForKey:kFocus];
}

+ (void)setFocus:(NSUInteger) focus {
    [self.userDefaults setInteger:focus forKey:kFocus];
}

+ (NSUInteger)getMultiplier {
    return [self.userDefaults integerForKey:kMultiplier];
}

+ (void)setMultiplier:(NSUInteger) multiplier {
    [self.userDefaults setInteger:multiplier forKey:kMultiplier];
}


@end
