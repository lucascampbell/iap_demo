require 'rho/rhocontroller'
require 'helpers/browser_helper'

class IaprController < Rho::RhoController
  include BrowserHelper

  # GET /Iapr
  def index
    NavBar.create :title => 'IAP Test For Fit App'
  end
  
  def get_product
    Iapr.purchase_flag = false
    Iapr.get_product
    render :action => :index
  end

  def upgrade
    Iapr.purchase_flag = true
    Iapr.upgrade
    render :action => :index
  end
  
  def products_callback
     status = Iapr.get_status
     if(status == 'success')
         if !Iapr.can_purchase
            Alert.show_popup({
                :message => "You don't have permission", 
                :title => "No permission",
                :icon => 'question',
                :buttons => ['Ok'],
              })
         else
           if Iapr.purchase_flag
             Iapr.start_transaction
           else
             price = Iapr.product_price
             title = Iapr.product_title
             descr = Iapr.product_descr
             Alert.show_popup({
                 :message => "#{title}\n #{descr} \n #{price}", 
                 :title => "Your Product Information",
                 :icon => 'question',
                 :buttons => ['Ok'],
               })
            end
            render :action => :index
         end
     else
        Alert.show_popup({
           :message => "call to product returned #{status}", 
           :title => "could not make connection to app store",
           :icon => 'question',
           :buttons => ['Ok']
         })
     end
   end


   def transaction_callback
     status = @params["status"]
     if status == 'success'
       #here you can save product to your local db if you like to file system.  #inside Iap.m there is call to file sytem already to save license
       Alert.show_popup({
           :message => "You have purchased the Fit Pro Upgrade", 
           :title => "Congratulations!.  Upgrade is complete",
           :icon => 'question',
           :buttons => ['Ok'],
           :callback => "/app/Exercise/refresh_after_purchase"
         })
     end
   end
 
   #After a complete transaction I am unlocking features with db flags.  To make sure everything is reloaded I use WebView navigate to reload DOM
   def refresh_after_purchase
     WebView.navigate('/app/Iapr/index')  
   end
end
