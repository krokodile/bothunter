class UsersController < ApplicationController
  before_filter :authenticate_user!

  authorize_resource

  def index
    @users = User.page params[:page]
  end

  def manager
    manager = !resource.manager?
    resource.set :_type, (manager ? 'Manager' : 'User')
    render :js => %<$('a[data-manager-id="#{resource.id.to_s}"]')['#{manager ? 'addClass' : 'removeClass'}']('success').text('#{manager ? 'Y' : 'N'}')>
  end

  def approved
    approved = !resource.approved?
    resource.set :approved, approved
    render :js => %<$('a[data-approved-id="#{resource.id.to_s}"]')['#{approved ? 'addClass' : 'removeClass'}']('success').text('#{approved ? 'Y' : 'N'}')>
  end

  protected

  def collection
    @users ||= if params[:show].nil?
                 end_of_association_chain.all
               elsif params[:show] == 'inactive'
                 end_of_association_chain.where(['approved != ?', true])
               end
  end
end
