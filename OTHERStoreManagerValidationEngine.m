	//
	//  OTHERStoreManagerValidationEngine.m
	//
	//  Created by Edwin Bosire on 17/12/2012.
	//  Copyright (c) 2012 othermedia.com. All rights reserved.
	//

#import "OTHERStoreManagerValidationEngine.h"
#import "NSData+Base64.h"



typedef void (^OTHERStoreManagerNSURLConnectionSuccessBlock) (void);
typedef void (^OTHERStoreManagerNSURLConnectionFailureBlock) (void);

@interface OTHERStoreManagerValidationEngine () <NSURLConnectionDelegate>{
	
	NSMutableDictionary *transactionsReceiptStorageDictionary;
	NSMutableData *receivedData;
	
}


@property (nonatomic, strong) OTHERStoreManagerNSURLConnectionSuccessBlock successBlock;
@property (nonatomic, strong) OTHERStoreManagerNSURLConnectionFailureBlock failureBlock;
@end


@implementation OTHERStoreManagerValidationEngine


@synthesize successBlock;
@synthesize failureBlock;
@synthesize verificationURL;

+ (id)sharedEngine{
	static dispatch_once_t pred = 0;
	__strong static id _sharedObject = nil;
	dispatch_once(&pred, ^{
		_sharedObject = [self new];
	});
	return _sharedObject;
}

- (void)setVerificationURL:(NSURL *)_verificationURL{
	
	if (_verificationURL == verificationURL) return;
	
	verificationURL = _verificationURL;
	
}
- (void)verifyPurchaseWithTransaction:(SKPaymentTransaction *)transaction
						 onCompletion:(OTHERStoreManagerVerifyBlock)completionBlock{
	transactionsReceiptStorageDictionary = [[NSMutableDictionary alloc] init];
	
	
		//Encode the transactionReceipt to base64
    NSString *jsonObjectString = [transaction.transactionReceipt base64EncodedString];
	
		// Create the POST request payload.
    NSString *payload = [NSString stringWithFormat:@"receipt=%@", jsonObjectString];
    
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
	
	NSAssert(self.verificationURL, @"Verification URL MUST be supplied in order for verification to work, alternatively you can disable verification by calling [[OTHERStoreManager sharedManager] setShouldVerify:No]");
	
		// Create the POST request to the server.
    [self startConnectionWithURL:self.verificationURL
					  HTTPMethod:kHTTPMETHOD_POST
					 payloadData:payloadData
					   onSuccess:^{
						   
						   completionBlock(YES);
						   
					   }onFailure:^{
						   completionBlock(NO);
						   
					   }];
	
}


#pragma -mark NSURLConnection Block Method
- (void)startConnectionWithURL:(NSURL *)url
					HTTPMethod:httpMethod
				   payloadData:(NSData *)payload
					 onSuccess:(OTHERStoreManagerNSURLConnectionSuccessBlock)success
					 onFailure:(OTHERStoreManagerNSURLConnectionFailureBlock)failure{
	
	NSAssert(url, @"The URL must be provided when calling startConnectionWithURL:HTTPMethod:payloadData:onSuccess:onFailure");
	
	[self initConnectionWithURL:url
					 HTTPMethod:httpMethod
					payloadData:payload];
	
	self.successBlock = success;
	self.failureBlock = failure;
	
}


- (void)initConnectionWithURL:(NSURL *)url
				   HTTPMethod:(NSString *)httpMethod
				  payloadData:(NSData *)payload {
	
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:httpMethod];
    [request setHTTPBody:payload];
	if ([httpMethod isEqualToString:@"POST"]) {
		[request setValue:[NSString stringWithFormat:@"%ud", payload.length] forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
    if (conn) {
			// Create the NSMutableData to hold the received data.
		receivedData = [NSMutableData data];
	} else {
		NSLog(@"Failed to create an NSURLRequest in OTHERStoreManagerValidationEngine");
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
		// This method is called when the server has determined that it
		// has enough information to create the NSURLResponse.
	
		// It can be called multiple times, for example in the case of a
		// redirect, so each time we reset the data.
	
		// receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	
		// Append the new data to receivedData.
		// receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
    
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSString *responseString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	NSDictionary *verifiedReceiptDictionary = [self dictionaryFromJSONData:[responseString dataUsingEncoding:NSUTF8StringEncoding]];
    
		// Check the status of the verifyReceipt call
    id status = [verifiedReceiptDictionary objectForKey:@"status"];
	
	if ([status integerValue] == 0) {
		
		self.successBlock();
		
	}else{
		
		self.failureBlock();
		
	}
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	self.failureBlock();
}


#pragma mark - Parsing JSON Data

- (NSDictionary *)dictionaryFromJSONData:(NSData *)data
{
    NSError *error;
    NSDictionary *dictionaryParsed = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:&error];
    if (!dictionaryParsed)
    {
		NSLog(@"Failed parsing JSON response from receipt validation web service.");
        if (error)
        {
			NSLog(@"Error parsing JSON response: %@", error);
        }
        return nil;
    }
    return dictionaryParsed;
}


#pragma mark - Experimental Stuff Goes Here

@end


