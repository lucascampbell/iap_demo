/* Iap.i */
%module Iap
%{
#include "ruby/ext/rho/rhoruby.h"

extern void requestProductData(void);
extern void loadStore(void);
extern int canMakePurchases(void);
extern void purchaseUpgrade(void);
extern int has_purchased(void);

extern VALUE returnTitle(void);
extern VALUE returnPid(void);
extern VALUE returnDescription(void);
extern VALUE returnStatus(void);
extern VALUE returnPrice(void);

extern int returnStarted(void);
%}
extern void requestProductData(void);
extern void loadStore(void);
extern int canMakePurchases(void);
extern void purchaseUpgrade(void);
extern int has_purchased(void);

extern VALUE returnTitle(void);
extern VALUE returnPid(void);
extern VALUE returnDescription(void);
extern VALUE returnStatus(void);
extern VALUE returnPrice(void);

extern int returnStarted(void);