require 'rho/rhocontroller'
require 'helpers/browser_helper'

class IapController < Rho::RhoController
  include BrowserHelper

  # GET /Iap
  def index
    NavBar.create :title => 'Fit'
  end

 
end
