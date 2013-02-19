//
//  OTHERStoreManager.m
//
//  Created by Edwin Bosire on 05/12/2012.
//  Copyright (c) 2012 The OTHER Media. All rights reserved.
//

#import "OTHERStoreManager.h"

#import <CommonCrypto/CommonDigest.h>

#import "OTHERStoreManagerProductsFetchEngine.h"
#import "OTHERStoreManagerTransactionEngine.h"
#import "OTHERStoreManagerValidationEngine.h"
#import "OpenUDID.h"


@interface OTHERStoreManager () <OTHERStoreManagerProductsFetchEngineDelegate, OTHERStoreManagerTransactionEngineDelegate> {
	
    NSMutableDictionary *cachedPurchasedProducts;
	OTHERStoreManagerTransactionEngine *transactionEngine;
	OTHERStoreManagerProductsFetchEngine *productFetchEngine;
	BOOL started;
}


@end


#define kUSERDEFAULTSKEY @"OSMIdentifier"


@implementation OTHERStoreManager


#pragma -mark Memory Management

- (void)dealloc {

	_cachedProducts = nil;
}


+ (instancetype)sharedManager {
	static dispatch_once_t pred = 0;
	__strong static id _sharedObject = nil;
	dispatch_once(&pred, ^{
		_sharedObject = [self new];
	});
	return _sharedObject;
}


- (id)init {
    self = [super init];
    if (self) {

		started = NO;
        _cachedProducts = [NSSet new];
		self.shouldVerify = YES;
		self.shouldCacheProducts = YES;
		cachedPurchasedProducts = [NSMutableDictionary dictionary];
		
		transactionEngine = [OTHERStoreManagerTransactionEngine new];
		transactionEngine.delegate = self;
		_isRestoring = NO;
    }
    return self;
}

#pragma mark - Set Transaction Delegate

- (void)startObservingTransactions {
	
	if (started == NO) {

		[[SKPaymentQueue defaultQueue] addTransactionObserver:transactionEngine];
		started = YES;
	}
}


- (void)stopObservingTransactions {

	if (started) {

		[[SKPaymentQueue defaultQueue] removeTransactionObserver:transactionEngine];
		started = NO;
	}
}


#pragma mark - Check if purchases are possible

+ (BOOL)canMakePurchases {
	
	return [SKPaymentQueue canMakePayments];
}


#pragma mark - Cache mechanism

- (void)productFetchHandler:(OTHERStoreManagerProductsFetchEngine *)handler didReceiveProducts:(NSSet *)products {

	if (self.shouldCacheProducts) {

		NSSet *newCache = [self.cachedProducts setByAddingObjectsFromSet:products];
		_cachedProducts = newCache;
	}
}


- (SKProduct *)cachedProductWithId:(NSString *)productId {

	__block SKProduct *returnProduct;
	
	[self.cachedProducts enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		SKProduct *product = (SKProduct *)obj;
		if ([product.productIdentifier isEqualToString:productId]) {
			returnProduct = product;
			*stop = YES;
		}
	}];
	
	return returnProduct;
}


- (void)removeProductsFromCache:(NSSet *)products {

	NSMutableSet *mCache = [NSMutableSet setWithSet:self.cachedProducts];
	[products enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
		[mCache removeObject:obj];
	}];
	
	NSSet *newCache = [NSSet setWithSet:mCache];
	_cachedProducts = newCache;
}


- (void)removeAllProductsFromCache {
	
	_cachedProducts = nil;
}


#pragma mark - Fetch Products

- (void)fetchProductsWithIDs:(NSSet *)productId completion:(OTHERStoreManagerFetchProductsCompletionBlock)completionBlock {
	
	if (productFetchEngine) {

		NSError *error = [NSError errorWithDomain:SKErrorDomain code:SKErrorClientInvalid userInfo:@{NSLocalizedDescriptionKey : @"Product fetch already on progress"}];
		completionBlock(nil, nil, error);
		return;
	}

	productFetchEngine = [OTHERStoreManagerProductsFetchEngine new];
	
	productFetchEngine.delegate = self;
	productFetchEngine.productIDs = productId;
	productFetchEngine.completionBlock = completionBlock;
	
	[productFetchEngine fetchProducts];
}


- (void)productFetchHandlerDidFinish:(OTHERStoreManagerProductsFetchEngine *)handler {

	productFetchEngine = nil;
}


#pragma mark - Purchase products

- (void)purchaseProduct:(SKProduct *)product completion:(OTHERStoreManagerTransactionCompletionBlock)completion {
	
	[self startObservingTransactions];
	
	if (self.verificationURL) {
		
		transactionEngine.shouldVerify = self.shouldVerify;
		[[OTHERStoreManagerValidationEngine sharedEngine] setVerificationURL:self.verificationURL];

	}else{
		//if we do not provide a verification url, we dissable verification
		transactionEngine.shouldVerify = NO;
	
	}
	transactionEngine.product = product;
	transactionEngine.purchaseBlock = completion;
	
	
	[transactionEngine makePurchase];
}


#pragma mark - Restore products

- (void)restorePurchasesWithCompletionHandler:(OTHERStoreManagerRestoreCompletionBlock)onCompletion {
	
	_isRestoring = YES;
	
	[self startObservingTransactions];
	
	
	if (self.verificationURL) {
		
		transactionEngine.shouldVerify = self.shouldVerify;
		[[OTHERStoreManagerValidationEngine sharedEngine] setVerificationURL:self.verificationURL];
		
	}else{
			//if we do not provide a verification url, we dissable verification
		transactionEngine.shouldVerify = NO;
		
	}
	
	transactionEngine.restoreBlock = onCompletion;
	
	[transactionEngine restoreCompletedTransaction];
}


- (void)transactionEngineDidFinishRestoring:(OTHERStoreManagerTransactionEngine *)engine {

	_isRestoring = NO;
}


#pragma -mark
#pragma -mark Record Transaction

- (void)transactionEngine:(OTHERStoreManagerTransactionEngine *)engine didFinishTransaction:(SKPaymentTransaction *)transaction {

	//Create a hash value
	NSString *hashValue = [self createDigest:transaction.payment.productIdentifier];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableSet *productIdentifiers = [NSMutableSet setWithArray:[defaults objectForKey:kUSERDEFAULTSKEY]];
	[productIdentifiers addObject:hashValue];
	[defaults setObject:productIdentifiers.allObjects forKey:kUSERDEFAULTSKEY];
	[defaults synchronize];
	
	[cachedPurchasedProducts removeAllObjects];
}


- (BOOL)productAlreadyPurchased:(NSString *)productID {
	
	NSAssert(productID, @"Error reading productID. Please provide a valid (NSString*)productID as param");
	
	NSNumber *cachedResult = [cachedPurchasedProducts objectForKey:productID];
	
	if (cachedResult) return [cachedResult boolValue];
	
	NSString *hashValue = [self createDigest:productID];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableSet *productIdentifiers = [NSMutableSet setWithArray:[defaults objectForKey:kUSERDEFAULTSKEY]];
	
	BOOL purchased = [productIdentifiers containsObject:hashValue];
	
	[cachedPurchasedProducts setObject:@(purchased) forKey:productID];
	
	return purchased;
}


- (NSString *)createDigest:(NSString *)productID {
	
	NSAssert(productID, @"Failure creating a valid digest. Please provide a valid (NSString*)productID as param");
	
	//create a hash digest
	NSString *salt = [NSString new];
	
	//check if the user has supplied their own unique salt, if not use a defult.
	if (!self.salt) {
		salt = @"$apr1$yWxLbWJ1$1oc.NqOUKUwWf680mHzYz/";
	}else{
		salt = self.salt;
	}
	NSString *UDID = [OpenUDID value];
	
	NSString *digest = [productID stringByAppendingFormat:@"%@%@", salt, UDID];
	
	NSString *hashValue = [self generateMD5HashFromString:digest];
	
	return hashValue;
	
}


- (NSString *)generateMD5HashFromString:(NSString*)raw {
	
	const char *cstr = [raw UTF8String];
	unsigned char result[16];
	CC_MD5(cstr, strlen(cstr), result);
	
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}


@end
