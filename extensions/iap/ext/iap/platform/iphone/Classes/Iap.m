#import "iap.h"
// rhodes/platform/shared/common/RhodesApp.h
#import "RhodesApp.h"
//void rho_net_request(const char *url);
//char* rho_http_normalizeurl(const char* szUrl);
#include "ruby/ext/rho/rhoruby.h"
#define kInAppPurchaseProUpgradeProductId @"1000000001"

Iap *iap;
NSString *title;
NSString *description;
NSString *price;
NSString *pid;
NSString *status;
BOOL hasAddObserver = false;
static bool started = false;
BOOL current_transaction = NO;


// InAppPurchase.m
@implementation Iap

//on intialization we will register observers for all three notifications for (product fetching, successfull transaction, failed transaction)
- (id)init{
	self = [super init];
	if(self){
		 return self;
	}
}

- (void)requestProductData
{   
		status = @"request for product id started";
	    NSSet *productIdentifiers = [NSSet setWithObject:@"1000000001" ];
	    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	    productsRequest.delegate = self;
	    [productsRequest start];
    
	    // we will release the request object in the delegate callback
}


#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	@try{
    	NSArray *products = response.products;
	    upgradeProduct = [products count] == 1 ? [[products firstObject] retain] : nil;
	    if (upgradeProduct)
	    {
			status = @"success";
			title = upgradeProduct.localizedTitle;
			description = upgradeProduct.localizedDescription;
			pid = upgradeProduct.productIdentifier;
			
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		    [numberFormatter setLocale:upgradeProduct.priceLocale];
		    NSString *formattedString = [numberFormatter stringFromNumber:upgradeProduct.price];
		    [numberFormatter release];
		    price = formattedString;
		
	        NSLog(@"Product title: %@", upgradeProduct.localizedTitle);
	        NSLog(@"Product description: %@", upgradeProduct.localizedDescription);
	        NSLog(@"Product price: %@", price);
	        NSLog(@"Product id: %@", upgradeProduct.productIdentifier);
	    }
	    else {
		    status = @"did not return a product";
		}
    
	    for (NSString *invalidProductId in response.invalidProductIdentifiers)
	    {
	        NSLog(@"Invalid product id: %@" , invalidProductId);
			status = [NSString stringWithFormat:@"invalid product id: %@", invalidProductId];
	    }
	}
	@catch (NSException *e){
		status = @"exception encountered";
		NSLog(@"Exception: %@", e);
		[productsRequest release];
	}
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [productsRequest release];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
	rho_net_request(rho_http_normalizeurl("/app/Exercise/products_callback"));
}

/************************** start of transaction functions ************************************/
#pragma -
#pragma Public methods

//
// call this method once on startup
//
- (void)loadStore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	
    // get the product description (defined in early sections)
    [self requestProductData];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseUpgrade
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseProUpgradeProductId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
	current_transaction = YES;
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// retrieves record of transaction from disk if it exists returns 0 false 1 true
- (int)getRecordedTransaction
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	int res = 0;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:@"proUpgradeTransactionReceipt"];
    if (val != nil)
		res = 1;
		
	return res;
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
	status = [NSString stringWithFormat:@"provide content product id: %@", productId];
    if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // enable the pro features
		status = [NSString stringWithFormat:@"provide content enable features start"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
		status = [NSString stringWithFormat:@"provide content enable features end"];
    }
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
	//  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	//});
    
    //status = [NSString stringWithFormat:@"finish transaction wasSuccessful is: %@", wasSuccessful];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
		rho_net_request(rho_http_normalizeurl("/app/Exercise/transaction_callback?status=success"));
        //[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
		rho_net_request(rho_http_normalizeurl("/app/Exercise/transaction_callback?status=failed"));
        //[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	//NSLog(@"tran array: %@", transactions);
    for (SKPaymentTransaction *transaction in transactions)
    {
	    //NSLog(@"tran state: %@", transaction.transactionState);
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end



int returnStarted(void){
	return started;
}

void loadStore(void){
	if(!started) {
		iap = [[Iap alloc] init];
		started = true;
	}
	[iap loadStore];
}

int canMakePurchases(void){
	if(!started) {
		iap = [[Iap alloc] init];
		started = true;
	}
	BOOL res = [iap canMakePurchases];
	if(res == true)
		return 1;
	else
		return 0;
}

void purchaseUpgrade(void){
	if(!started) {
		iap = [[Iap alloc] init];
		started = true;
	}
	[iap purchaseUpgrade];
}

int has_purchased(void){
	if(!started) {
		iap = [[Iap alloc] init];
		started = true;
	}
	return [iap getRecordedTransaction];	
}

//
// functions to test IAP product setup
// first call requestProdcutData and then use return functions to check that correct product values are returned
void requestProductData(void){
	if(!started) {
		iap = [[Iap alloc] init];
		started = true;
	}
    [iap requestProductData];
}

VALUE returnTitle(void){
	return rho_ruby_create_string([title UTF8String]);
}

VALUE returnPid(void){
	return rho_ruby_create_string([pid UTF8String]);
}

VALUE returnDescription(void){
	return rho_ruby_create_string([description UTF8String]);
}

VALUE returnStatus(void){
	return rho_ruby_create_string([status UTF8String]);
}

VALUE returnPrice(void){
	return rho_ruby_create_string([price UTF8String]);
}

