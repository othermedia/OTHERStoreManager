	//
	//  OTHERStoreManagerTransactionEngine.m
	//
	//  Created by Edwin Bosire on 05/12/2012.
	//  Copyright (c) 2012 The OTHER Media. All rights reserved.
	//

#import "OTHERStoreManagerTransactionEngine.h"
#import "OTHERStoreManager.h"
#import "OTHERStoreManagerValidationEngine.h"


@interface OTHERStoreManagerTransactionEngine () {
	
	SKPayment *payment;
}

@end


@implementation OTHERStoreManagerTransactionEngine


#pragma mark - Purchase

- (void)makePurchase {
	
    payment = [SKPayment paymentWithProduct:self.product];
	
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma -mark
#pragma -mark transactionVerification callback

- (void)finishTransaction :(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)successful{
	
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
	if (successful) {
	
		if ([self.delegate respondsToSelector:@selector(transactionEngine:didFinishTransaction:)]) [self.delegate transactionEngine:self didFinishTransaction:transaction];
		
		if (transaction.transactionState == SKPaymentTransactionStateRestored) {
			
			if (self.restoreBlock) {
				self.restoreBlock(NO, transaction.error, transaction);
			}
			
		}else {
			if (self.purchaseBlock) {
				self.purchaseBlock(transaction, NO);
			}
		}
	}else{ //if not successful 
		
		
		if (self.purchaseBlock) {
			self.purchaseBlock(nil, YES);
		}
		if (self.restoreBlock) {
			self.restoreBlock(NO, transaction.error, transaction);
		}
		
	}
	
	self.purchaseBlock = nil;
}


#pragma -mark
#pragma -mark SKPaymentTransactionObserver Protocol Methods

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	
	[transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		SKPaymentTransaction *transaction =  (SKPaymentTransaction *)obj;
		
		switch (transaction.transactionState) {
			case  SKPaymentTransactionStatePurchased:
			case SKPaymentTransactionStateRestored:{
				if (self.shouldVerify) {
					[self verifyTransaction:transaction];
				}else{
					[self finishTransaction:transaction wasSuccessful:YES];
				}
				break;
			}
			case SKPaymentTransactionStateFailed:
				[self finishTransaction:transaction wasSuccessful:NO];
				break;
			case SKPaymentTransactionStatePurchasing:
			default:
				break;
		}
		
		
	}];
}


#pragma -mark
#pragma -mark Transaction Restore Methods

- (void)restoreCompletedTransaction {
	
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {

	if ([self.delegate respondsToSelector:@selector(transactionEngineDidFinishRestoring:)]) [self.delegate transactionEngineDidFinishRestoring:self];

	if (self.restoreBlock) {
		self.restoreBlock(YES, error, nil);
	}
	
	self.restoreBlock = nil;
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {

	if ([self.delegate respondsToSelector:@selector(transactionEngineDidFinishRestoring:)]) [self.delegate transactionEngineDidFinishRestoring:self];

	if (self.restoreBlock) {
		self.restoreBlock(YES, nil, nil);
	}
	
	self.restoreBlock = nil;
}


#pragma -mark
#pragma -mark Reveipt Verification

- (void)verifyTransaction: (SKPaymentTransaction *)transaction {
	
	[[OTHERStoreManagerValidationEngine sharedEngine] verifyPurchaseWithTransaction:transaction
																	   onCompletion:^(BOOL isValid) {
																		   [self finishTransaction:transaction wasSuccessful:isValid];
																	   }];
}


#pragma -mark
#pragma -mark Memory Management

-(void)dealloc {
	
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];

	payment = nil;
	self.purchaseBlock = nil;
	self.restoreBlock = nil;
}

@end
