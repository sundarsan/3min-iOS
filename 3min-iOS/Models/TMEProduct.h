//
//  TMEProduct.h
//  ThreeMin
//
//  Created by Triệu Khang on 15/7/14.
//
//

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>
#import "TMECategory.h"
#import "TMEUser.h"

@interface TMEProduct : TMEBaseModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *productID;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *productDescription;
@property (nonatomic, copy) NSString *details;

@property (nonatomic, copy) NSString *comments;

@property (nonatomic, strong) NSDate *createAt;
@property (nonatomic, strong) NSDate *updateAt;

@property (nonatomic, strong) NSNumber *dislikes;
@property (nonatomic, strong) NSNumber *likes;
@property (nonatomic, assign) BOOL liked;

@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, assign) BOOL soldOut;

@property (nonatomic, copy) NSString *venueID;
@property (nonatomic, strong) NSNumber *venueLong;
@property (nonatomic, strong) NSNumber *venueLat;

@property (nonatomic, weak) TMECategory *category;

@property (nonatomic, strong) NSSet *conversation;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, weak) TMEUser *user;

@end