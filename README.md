OTHERStoreManager
=================

OTHERStoreManager is a wrapper around storekit that we use here at Other Media ltd. We wanted a simple yet effective way of

Using the OTHERStoreManager is quite easy, to fetch products just call the method below.

    NSSet *productIdentifiers = [NSSet setWithObject:@"com.othermedia.IAPTest.GeographicalMaps,com.othermedia.IAPTest.PoliticalMaps"];

		
	[[OTHERStoreManager sharedManager] fetchProductsWithIDs:productIdentifiers completion:^(NSArray *products, NSArray *invalidIdentifiers, NSError *error) {
		if (!error) {
			NSLog(@"Here are teh products %@", products);
			
		}else{
			NSLog(@"Retrieving products failed");
			
		}
	}];

You can use the Array of products to populate a table (for example), InvalidIDentifiers contain those IDs that you have supplied in productIdentifiers that don't match an actual product in you IAP configuration.
	
Making a purchase is equally easy, just call the following methods
	
	[[OTHERStoreManager sharedManager] purchaseProduct:product completion:^(SKPaymentTransaction *transaction, BOOL validityError) {
			if (validityError) {
			
				NSLog(@"There was an error verifying the  purchase.");
			
			}else{
			
				NSLog(@"Item purchased %@", transaction.payment.productIdentifier);
			}
		}];
		
		
Always check the value of validityError if its true, it means that validation failed. You can also disable validation by using :
		[[OTHERStoreManager sharedManager] setShouldVerify:NO]; 
		
In which case, validityError will always be false, please note that shouldVerify is set to YES by default and you have to supply the verification URL via
		
		[[OTHERStoreManager sharedManager] setVerificationURL:kVERIFICATION_URL_GOES_HERE];
		
By Default, if you do not supply the verification url, verification will be disabled automatically.

BSD License
=================
Copyright © 2012, nxtbgthng GmbH

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of nxtbgthng nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
