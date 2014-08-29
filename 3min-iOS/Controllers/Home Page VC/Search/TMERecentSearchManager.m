//
//  TMERecentSearchManager.m
//  ThreeMin
//
//  Created by Khoa Pham on 8/29/14.
//  Copyright (c) 2014 3min. All rights reserved.
//

#import "TMERecentSearchManager.h"

static NSString * const kRecentSearchTextsKey = @"kRecentSearchTextsKey";

@interface TMERecentSearchManager ()

@property (nonatomic, strong) NSMutableArray *mutableRecentSearchTexts;

@end

@implementation TMERecentSearchManager

OMNIA_SINGLETON_M(sharedManager)

#pragma mark - Public Interface
- (NSArray *)recentSearchTexts
{
    return [NSArray arrayWithObject:self.mutableRecentSearchTexts];
}

- (void)addSearchText:(NSString *)text
{
    if ([self.mutableRecentSearchTexts containsObject:text]) {
        [self.mutableRecentSearchTexts removeObject:text];
    }

    [self.mutableRecentSearchTexts insertObject:text atIndex:0];
}

#pragma mark - Persistence
- (void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:self.mutableRecentSearchTexts forKey:kRecentSearchTextsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)load
{
    self.mutableRecentSearchTexts = [[NSUserDefaults standardUserDefaults] objectForKey:kRecentSearchTextsKey];
    if (!self.mutableRecentSearchTexts) {
        self.mutableRecentSearchTexts = [NSMutableArray array];
    }
}

@end
