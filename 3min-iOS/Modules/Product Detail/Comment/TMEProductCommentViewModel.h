//
//  TMEProductCommentViewModel.h
//  ThreeMin
//
//  Created by Khoa Pham on 10/6/14.
//  Copyright (c) 2014 3min. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMEProduct;

@interface TMEProductCommentViewModel : NSObject

- (instancetype)initWithProduct:(TMEProduct *)product;

@property (nonatomic, assign) NSInteger productCommentsCount;
@property (nonatomic, strong) NSArray *productComments;

- (void)pullProductComments;

@end
