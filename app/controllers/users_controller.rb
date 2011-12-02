class UsersController < InheritedResources::Base # ApplicationController
  before_filter :authenticate_manager!
end
