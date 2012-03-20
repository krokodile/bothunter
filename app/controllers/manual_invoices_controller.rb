class ManualInvoicesController < ApplicationController
  before_filter :authenticate_user!

  authorize_resource

  def new
    @user = User.find params[:user_id]
    @manual_invoice = current_user.manual_invoices.new(:user => @user)
    render :layout => !request.xhr?
  end

  def create
    @user = User.find params[:user_id]
    @manual_invoice = current_user.manual_invoices.new params[:manual_invoice].merge(:user => @user)

    if @manual_invoice.save
      @user.inc :groups_limit, @manual_invoice.groups_limit
      @manual_invoice.set :paid, true

      if request.xhr?
        render :js => %<$('a[data-user-id="#{@user.id.to_s}"]').text("#{@user.groups_limit.to_s}"); $('#create-invoice-modal').modal('hide')>
      else
        redirect_to users_path
      end
    else
      @manual_invoice.destroy
    end
  end
end
