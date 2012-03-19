class PromocodesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authenticate_manager!

  authorize_resource

  inherit_resources

  def new
    super do |format|
      format.html{ render :layout => !request.xhr? }
    end
  end

  def create
    super do |format|
      format.html{ redirect_to promocodes_path  }
    end
  end
end
