
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
//#import "SKProduct+LocalizedPrice.h"
#include "ruby/ext/rho/rhoruby.h"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@interface Iap : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>{
	SKProduct *upgradeProduct;
	SKProductsRequest *productsRequest;
	SKPaymentQueue *_myQueue;
}

- (void)requestProductData;
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseUpgrade;

@end