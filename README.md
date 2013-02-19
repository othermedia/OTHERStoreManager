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
