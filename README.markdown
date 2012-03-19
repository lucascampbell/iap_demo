In App Purchase Rhodes Extension
==================
##Introduction

The IAP extension is a rhodes native extension for the iphone.  It is based off a great tutorial by Troy Brant.  [In App Purchase a Full Walk through](http://troybrant.net/blog/2010/01/in-app-purchases-a-full-walkthrough/).  You should understand this tutorial before using this extension for it outlines everything you will need to know.

This short tutorial assumes you are familiar with [Rhodes Native Extensions](http://docs.rhomobile.com/rhodes/extensions#native-extensions) and have a general understanding of [SWIG](http://www.swig.org/Doc1.3/Ruby.html)

My app [Fit](http://itunes.apple.com/us/app/fit/id472791337?ls=1&mt=8) by progressivefitness with this In App Purchase extension working is available on the app store now.

[<img src="https://s3.amazonaws.com/fit_random/appstore.png" alt="appsotre" height='60' width='200' />](http://itunes.apple.com/us/app/fit/id472791337?ls=1&mt=8) 
##Getting Started

If you don't already have an extensions directory in your Rhodes project, you can just copy the entire extensions directory to your project.

Next you will need to add the Iap extension to your project.  You can do this in the build.yml file
	
  	extensions: ["json", "another-extension", "iap"]

You will need to add the StoreKit framework to your Xcode project for the Iap extension to link successfully. You can do this by selecting your project target -> build phases -> link binary with libraries(expand this menu).  There is a plus icon that allows you to add frameworks.  Add the StoreKit.framework file.

You should now be able to build your project successfully.

I've created a class Iapr(app/Iapr/iapr.rb) where I require the Iap extension and then map most of the calls.

For this sample app to work you will need to replace three things:

	* Your In App Purchase Product ID in Iap.m
	* Your BundleIdentifier in build.yml
	* The names and urls of the callbacks below.

#Rho Callbacks

Because StoreKit makes async calls to the app store you will need to register callback functions.  In objective C the NSNotificationCenter class is used.  I've replaced this with rho_net_request(rho_http_normalizeurl("/app/Iapr/products_callback")).  This will send a request to the products_callback function in your rhodes app.  

You can replace these callback urls with your own links.

###Iap.m
	
	line 91 	rho_net_request(rho_http_normalizeurl("/app/Iapr/products_callback"));  # This is the callback after your product info is retrieved

	line 191    rho_net_request(rho_http_normalizeurl("/app/Iapr/transaction_callback?status=success")); # This is the callback after transaction passing success

	line 197   	rho_net_request(rho_http_normalizeurl("/app/Iapr/transaction_callback?status=failed")); # This is the callback after transaction passing failure




##References

[Webinar on Native Extensions](http://player.vimeo.com/video/13400529?byline=0&portrait=0&color=de0909)

[StoreKit Overview](http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/StoreKitGuide/APIOverview/OverviewoftheStoreKitAPI.html)

##Meta
Created and maintained by [lucas campbell](https://github.com/lucascampbell) 