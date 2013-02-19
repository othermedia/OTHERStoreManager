//
//  OTHERStoreManagerProductsFetchEngine.m
//
//  Created by Edwin Bosire on 05/12/2012.
//  Copyright (c) 2012 The OTHER Media. All rights reserved.
//

#import "OTHERStoreManagerProductsFetchEngine.h"

#import "OTHERStoreManager.h"


@interface OTHERStoreManagerProductsFetchEngine () <SKProductsRequestDelegate> {
	
}


@end


@implementation OTHERStoreManagerProductsFetchEngine


- (void)fetchProducts {

	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIDs];
	request.delegate = self;
	[request start];
}


#pragma -mark SKProductsRequestDelegate Protocol Methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	
	NSSet *fetchedProducts = [NSSet setWithArray:response.products];
	if ([self.delegate respondsToSelector:@selector(productFetchHandler:didReceiveProducts:)]) {
		[self.delegate productFetchHandler:self didReceiveProducts:fetchedProducts];
	}

	if (self.completionBlock){
		self.completionBlock(response.products, response.invalidProductIdentifiers, nil);
	}
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	
	if (self.completionBlock) {
		self.completionBlock(nil, nil, error);
	}
	
	if ([self.delegate respondsToSelector:@selector(productFetchHandlerDidFinish:)]) {
		[self.delegate productFetchHandlerDidFinish:self];
	}
}


- (void)requestDidFinish:(SKRequest *)request {
	
	if ([self.delegate respondsToSelector:@selector(productFetchHandlerDidFinish:)]) {
		[self.delegate productFetchHandlerDidFinish:self];
	}
}


@end
