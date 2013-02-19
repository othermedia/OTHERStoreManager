//
//  OTHERStoreManager.h
//
//  Created by Edwin Bosire on 05/12/2012.
//  Copyright (c) 2012 The OTHER Media. All rights reserved.
//

/**
 OTHERStoreManager coordinates all the functions needed to make a successful transaction with storekit.
 It provides a simple yet powerful interface to storekit.
 */


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


#pragma mark - Block definitions
/**
 A completion block for storekit transactions.
 
 @return transaction A transaction objection.
 @return validityError Yes if validation passed, No otherwise.If validityError = No, then transaction is Nil
 */
typedef void (^OTHERStoreManagerTransactionCompletionBlock)(SKPaymentTransaction *transaction, BOOL validityError);
typedef void (^OTHERStoreManagerFetchProductsCompletionBlock)(NSArray *products, NSArray *invalidIdentifiers, NSError *error);
typedef void (^OTHERStoreManagerRestoreCompletionBlock)(BOOL finished, NSError *error, SKPaymentTransaction *transaction);


@class OTHERStoreManagerProductsFetchEngine;
@class OTHERStoreManagerTransactionEngine;


@interface OTHERStoreManager : NSObject


@property (nonatomic, readonly) NSSet *cachedProducts;
@property (nonatomic) BOOL shouldVerify;
@property (nonatomic) BOOL shouldCacheProducts;
@property (nonatomic) NSString *salt;
@property (nonatomic, readonly) BOOL isRestoring;
@property (nonatomic, strong) NSURL *verificationURL;

#pragma mark - Singleton
/**
 sharedManager returns a single instance of the OTHERStoreManager class.
 */
+ (instancetype)sharedManager;



/**
 Checks to see if the user is allowed to make payments
 
 @return YES if the user is allowed to authorize payment. No if the user is not allowed to
 
 */

+ (BOOL)canMakePurchases;



#pragma mark - Transaction observing
/**
 startObservingTransactions should be called during application initialization (recommended).
 
 If there are no observers attached to the queue (accomplished by calling startObservingTransactions) the payment queue does not synchronize its list of pending transactions with the apple App store.
 */
- (void)startObservingTransactions;

/**
 Removes the transaction observer.
 */
- (void)stopObservingTransactions;


#pragma mark - Product fetches

/**
 Fetch products which corresponds to the IDs provided.
 
 @param productID An NSSet containing product identification strings.
 @param completionBlock Is a block that takes no parameters but returns and array of products, invalidIDentifiers and an Error. The Error is always nil unless an exception is thrown.
 */

- (void)fetchProductsWithIDs:(NSSet *)productId completion:(OTHERStoreManagerFetchProductsCompletionBlock)completionBlock;

/**
 Retrieve a product from cache
 
 @param productID the product Identification to be retrieved
 */

- (SKProduct *)cachedProductWithId:(NSString *)productId;

- (void)removeProductsFromCache:(NSSet *)products;

- (void)removeAllProductsFromCache;


#pragma mark - Purchases


/**
 Make a purchase of a product
 
 @param product The product to be purchased.
 */
- (void)purchaseProduct:(SKProduct *)product completion:(OTHERStoreManagerTransactionCompletionBlock)completion;

	/**
	 Checks to see if a product is already purchased.
	 
	 @param productID the product identification of the
	 */
- (BOOL)productAlreadyPurchased:(NSString *)productID;


#pragma mark - Restrore purchases

/**
 Restore all purchased
 */
- (void)restorePurchasesWithCompletionHandler:(OTHERStoreManagerRestoreCompletionBlock)onCompletion;


@end
