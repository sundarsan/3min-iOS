//
//  TMEProductsManager.m
//  PhotoButton
//
//  Created by Triệu Khang on 23/9/13.
//
//

#import "TMEProductsManager.h"

@implementation TMEProductsManager

// get user own products
+ (void)getAllProductsWihPage:(NSInteger)page
               onSuccessBlock:(void (^) (NSArray *))successBlock
                 failureBlock:(TMENetworkManagerFailureBlock)failureBlock
{
    NSDictionary *params = @{@"page" : @(page)};

    [[TMENetworkManager sharedManager] getModels:[TMEProduct class]
                                            path:API_PRODUCTS
                                          params:params
                                         success:successBlock
                                         failure:failureBlock];
}

+ (void)getProductsFromUserID:(NSNumber *)userID
               onSuccessBlock:(void (^)(NSArray *))successBlock
                 failureBlock:(TMENetworkManagerFailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/products", API_USER, userID];
    [[TMENetworkManager sharedManager] getModels:[TMEProduct class]
                                            path:path
                                          params:nil
                                         success:successBlock
                                         failure:failureBlock];
}

+ (void)getOwnProductsWihPage:(NSInteger)page
               onSuccessBlock:(void (^) (NSArray *))successBlock
                 failureBlock:(TMENetworkManagerFailureBlock)failureBlock
{
    NSDictionary *params = @{@"page" : @(page)};

    [[TMENetworkManager sharedManager] getModels:[TMEProduct class]
                                            path:API_OWN_PRODUCTS
                                          params:params
                                         success:successBlock
                                         failure:failureBlock];
}

+ (void)getProductsOfCategory:(TMECategory *)category
                     withPage:(NSInteger)page
               onSuccessBlock:(void (^) (NSArray *))successBlock
                 failureBlock:(TMENetworkManagerFailureBlock)failureBlock
{
    NSDictionary *params = @{@"page" : @(page),
                             @"category_id" : category.categoryId};

    [[TMENetworkManager sharedManager] getModels:[TMEProduct class]
                                            path:API_PRODUCTS
                                          params:params
                                         success:successBlock
                                         failure:failureBlock];
}

+ (void)getPopularProductsWithPage:(NSInteger)page
                    onSuccessBlock:(void (^) (NSArray *))successBlock
                      failureBlock:(TMENetworkManagerFailureBlock)failureBlock
{
    NSDictionary *params = @{@"page" : @(page)};
    NSString *path = [NSString stringWithFormat:@"%@%@", API_PRODUCTS, API_POPULAR];

    [[TMENetworkManager sharedManager] getModels:[TMEProduct class]
                                            path:path
                                          params:params
                                         success:successBlock
                                         failure:failureBlock];
}

+ (void)getSellingProductsOfCurrentUserOnPage:(NSInteger)page
                                 successBlock:(void (^) (NSArray *))successBlock
                                 failureBlock:(TMENetworkManagerFailureBlock)failureBlock
{
    NSDictionary *params = @{@"page" : @(page)};
    NSString *path = [NSString stringWithFormat:@"%@%@", API_PRODUCTS, API_ME];

    [[TMENetworkManager sharedManager] getModels:[TMEProduct class]
                                            path:path
                                          params:params
                                         success:successBlock
                                         failure:failureBlock];
}

+ (void)putSoldOutWithProductID:(NSNumber *)productID
                 onSuccessBlock:(void (^) (NSArray *))successBlock
                   failureBlock:(TMENetworkManagerFailureBlock)failureBlock{
    NSDictionary *params = @{@"sold_out" : @YES};
    NSString *path = [NSString stringWithFormat:@"%@/%@", API_PRODUCTS, productID];

    [[TMENetworkManager sharedManager] put:path params:params success:^(id responseObject) {
        if (successBlock) {
            NSArray *products = [TMEProduct tme_modelsFromJSONResponse:responseObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(products);
            });
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    }];
}

+ (void)getLikedProductOnPage:(NSInteger)page
                 successBlock:(void (^) (NSArray *))successBlock
                 failureBlock:(TMENetworkManagerFailureBlock)failureBlock{
    NSDictionary *params = @{@"page" : @(page)};
    NSString *path = [NSString stringWithFormat:@"%@%@", API_PRODUCTS, @"likes"];

    [[TMENetworkManager sharedManager] getModels:[TMEProduct class]
                                            path:path
                                          params:params
                                         success:successBlock
                                         failure:failureBlock];
}


+ (void)likeProductWithProductID:(NSNumber *)productID
                  onSuccessBlock:(void (^) (NSString *))successBlock
                    failureBlock:(TMENetworkManagerFailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", API_PRODUCTS, productID, @"likes"];

    [[TMENetworkManager sharedManager] post:path params:nil success:^(id responseObject) {
        if (successBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(responseObject[@"status"]);
            });
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    }];
}

+ (void)unlikeProductWithProductID:(NSNumber *)productID
                    onSuccessBlock:(void (^) (NSString *))successBlock
                      failureBlock:(TMENetworkManagerFailureBlock)failureBlock
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", API_PRODUCTS, productID, @"likes"];

    [[TMENetworkManager sharedManager] delete:path params:nil success:^(id responseObject) {
        if (successBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(responseObject[@"status"]);
            });
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    }];
}

+ (void)createProduct:(TMEProduct *)product
               images:(NSArray *)images
              success:(void (^)(TMEProduct *responsedProduct))success
              failure:(TMENetworkManagerFailureBlock)failure
{
    NSDictionary *params = [self paramsForProductCreationOrUpdateFromProduct:product];

    NSString *path = [NSString stringWithFormat:@"%@", API_PRODUCTS];

    [[TMENetworkManager sharedManager] post:path params:params success:^(id responseObject) {
        TMEProduct *responsedProduct = [TMEProduct tme_modelFromJSONResponse:responseObject[@"product"]];

        // Upload images
        NSString *imageUploadPath = [NSString stringWithFormat:@"%@/%@/images", API_PRODUCTS, responsedProduct.productID];

        [TMEImageClient uploadImages:images path:imageUploadPath success:^{
            if (success) {
                success(responsedProduct);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];

    } failure:^(NSError *error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

+ (void)updateProduct:(TMEProduct *)product
                images:(NSArray *)images
                success:(void (^)(TMEProduct *responsedProduct))success
                failure:(TMENetworkManagerFailureBlock)failure
{
    NSDictionary *params = [self paramsForProductCreationOrUpdateFromProduct:product];

    NSString *path = [NSString stringWithFormat:@"%@/%@", API_PRODUCTS, product.productID];

    [[TMENetworkManager sharedManager] put:path params:params success:^(id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSError *error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

+ (void)deleteProductListing:(NSNumber *)productID success:(TMESuccessBlock)success failure:(TMEFailureBlock)failure
{
    //TODO: Delete the product for now
    NSString *path = [NSString stringWithFormat:@"%@/%@", API_PRODUCTS, productID];

    [[TMENetworkManager sharedManager] delete:path params:nil success:^(id responseObject) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"success"]) {
            if (success) {
                success();
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

#pragma mark - Helpers
+ (NSDictionary *)paramsForProductCreationOrUpdateFromProduct:(TMEProduct *)product
{
    NSDictionary *params = @{@"name": product.name,
                             @"description": product.productDescription ?: @"",
                             @"price": product.price,
                             @"sold_out": @(NO),
                             @"buyer_id": @"",
                             @"tag_list": @"",
                             @"category_id": product.category.categoryId,
                             @"venueID": @"",
                             @"venue_name": product.venueName ?: @"",
                             @"venue_lat": product.venueLat ?: @"",
                             @"venue_long": product.venueLong ?: @"",
                             };

    return params;
}

@end
