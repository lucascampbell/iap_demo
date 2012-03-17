require 'iap'

class Iapr
  include Rhom::PropertyBag
  
  class << self
    attr_accessor :purchase_flag
  end
  
  def self.upgrade
    Iap.loadStore
  end
  
  def self.get_product
    Iap.requestProductData
  end
  
  def self.product_price
    Iap.returnPrice
  end
  
  def self.product_descr
    Iap.returnDescription
  end
  
  def self.product_title
    Iap.returnTitle
  end
  
  def self.get_status
     Iap.returnStatus
  end
  
  def self.start_transaction
     Iap.purchaseUpgrade
   end

   def self.has_purchased
     Iap.has_purchased > 0 ? true : false
   end

   def self.can_purchase
     Iap.canMakePurchases > 0 ? true : false
   end
  
end
