//
//  OTHERStoreManagerTransactionEngine.h
//
//  Created by Edwin Bosire on 05/12/2012.
//  Copyright (c) 2012 The OTHER Media. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>


@class OTHERStoreManagerTransactionEngine;


@protocol OTHERStoreManagerTransactionEngineDelegate <NSObject>


@optional
- (void)transactionEngine:(OTHERStoreManagerTransactionEngine *)engine didFinishTransaction:(SKPaymentTransaction *)transaction;
- (void)transactionEngineDidFinishRestoring:(OTHERStoreManagerTransactionEngine *)engine;


@end


typedef void (^OTHERStoreKitTransactionEngineRestoreBlock)(BOOL restoreFinished , NSError* error ,SKPaymentTransaction *transaction);
typedef void (^OTHERStoreKitTransactionEnginePurchaseBlock)(SKPaymentTransaction *transaction, BOOL validityError);


@class OTHERStoreManager;


@interface OTHERStoreManagerTransactionEngine : NSObject <SKPaymentTransactionObserver>


@property (nonatomic, weak) id <OTHERStoreManagerTransactionEngineDelegate> delegate;
@property (nonatomic) SKProduct *product;
@property (nonatomic) BOOL shouldVerify;
@property (nonatomic, copy) OTHERStoreKitTransactionEnginePurchaseBlock purchaseBlock;
@property (nonatomic, copy) OTHERStoreKitTransactionEngineRestoreBlock restoreBlock;


- (void)makePurchase;

- (void)restoreCompletedTransaction;


@end
