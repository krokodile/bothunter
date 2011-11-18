class PagesController < ApplicationController
  respond_to :html
  
  def index
    @campaigns = current_user.campaigns.all
  end
  
  
end
