//
//  OTHERStoreManagerValidationEngine.h
//
//  Created by Edwin Bosire on 17/12/2012.
//  Copyright (c) 2012 othermedia.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define IS_IOS6_AWARE (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1)

#define KNOWN_TRANSACTIONS_KEY              @"knownIAPTransactions"

#define kHTTPMETHOD_POST @"POST"


typedef void (^OTHERStoreManagerVerifyBlock) (BOOL isValid);



@interface OTHERStoreManagerValidationEngine : NSObject
	

@property (nonatomic, strong) NSURL *verificationURL;

+ (id)sharedEngine;

	//block based
- (void)verifyPurchaseWithTransaction:(SKPaymentTransaction *)transaction
						 onCompletion:(OTHERStoreManagerVerifyBlock)completionBlock;

	
@end



/**
 
 To verify the receipt, perform the following steps:
 
 1) Retrieve the receipt data. On iOS, this is the value of the transaction's transactionReceipt property. On OS X, this is the entire contents of the receipt file inside the application bundle. Encode the receipt data using base64 encoding.
 
 2) Create a JSON object with a single key named receipt-data and the string you created in step 1. Your JSON code should look like this:
 {
 "receipt-data" : "(receipt bytes here)"
 }
 
 3)	Post the JSON object to the App Store using an HTTP POST request. The URL for the store is https://buy.itunes.apple.com/verifyReceipt.
 
 4) The response received from the App Store is a JSON object with two keys, status and receipt. It should look something like this:
 {
 "status" : 0,
 "receipt" : { (receipt here) }
 }
 
 If the value of the status key is 0, this is a valid receipt. If the value is anything other than 0, this receipt is invalid.
 */