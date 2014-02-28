#import "TMEUser.h"


@interface TMEUser ()

// Private interface goes here.

@end


@implementation TMEUser

// Custom logic goes here.

+ (TMEUser *)userWithData:(id)data{
    TMEUser *user = [[TMEUser MR_findByAttribute:@"id" withValue:data[@"id"]] lastObject];
    if (!user) {
        user = [TMEUser MR_createEntity];
        user.id = data[@"id"];
        user.facebook_id = data[@"facebook_id"];
        user.udid = data[@"udid"];
    }
    
    if (data[@"facebook_avatar"] && ![data[@"facebook_avatar"] isEqual:[NSNull null]]){
        user.photo_url = data[@"facebook_avatar"];
    }
    user.username = data[@"username"];
    user.email = data[@"email"];
    user.fullname = data[@"full_name"];
    user.name = data[@"full_name"];
    
    return user;
}

@end
