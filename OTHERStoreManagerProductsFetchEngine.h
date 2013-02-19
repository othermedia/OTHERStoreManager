//
//  OTHERStoreManagerProductsFetchEngine.h
//
//  Created by Edwin Bosire on 05/12/2012.
//  Copyright (c) 2012 The OTHER Media. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>


@class OTHERStoreManagerProductsFetchEngine;


@protocol OTHERStoreManagerProductsFetchEngineDelegate <NSObject>


@optional
- (void)productFetchHandlerDidFinish:(OTHERStoreManagerProductsFetchEngine *)handler;
- (void)productFetchHandler:(OTHERStoreManagerProductsFetchEngine *)handler didReceiveProducts:(NSSet *)products;


@end


typedef void (^OTHERStoreManagerProductsCompletionBlock)(NSArray *products, NSArray *invalidIdentifiers, NSError *error);


@class OTHERStoreManager;


@interface OTHERStoreManagerProductsFetchEngine : NSObject


@property (nonatomic, weak) id <OTHERStoreManagerProductsFetchEngineDelegate> delegate;
@property (nonatomic, strong) NSSet *productIDs;
@property (nonatomic, copy) OTHERStoreManagerProductsCompletionBlock completionBlock;


- (void)fetchProducts;


@end
