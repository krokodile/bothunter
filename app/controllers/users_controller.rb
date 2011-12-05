class UsersController < ApplicationController
  inherit_resources

  before_filter :authenticate_manager!

  def manager
    manager = !resource.manager?
    resource.set :_type, (manager ? 'Manager' : 'User')
    render :js => %<$('a[data-manager-id="#{resource.id.to_s}"]')['#{manager ? 'addClass' : 'removeClass'}']('success').text('#{manager ? 'Y' : 'N'}')>
  end
end
