//
//  TMEFeedbackClient.h
//  ThreeMin
//
//  Created by Khoa Pham on 11/22/14.
//  Copyright (c) 2014 3min. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMEFeedbackClient : NSObject

+ (void)getFeedbacksForUser:(TMEUser *)user success:(TMEArrayBlock)success failure:(TMEFailureBlock)failure;

@end
