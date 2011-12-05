class PagesController < ApplicationController
  respond_to :html
  
  def index
    @groups =  current_user.groups #Group.where(user: )
  end

  def create
    puts params['group_url']
    group = Vk::GroupParse.parse params['group_url']
    #group.save
    group.users << current_user
    group.save
    redirect_to :action=>'index'
  end

  def delete_robots

  end
end
