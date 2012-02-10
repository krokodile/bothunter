class PagesController < ApplicationController
  respond_to :html
  
  def index
    @groups =  current_user.groups.all #Group.where(user: )
    if params['group_id']
      @group = Group.find(params['group_id'])
      @humans = @group.persons.where(state: :human)
      @robots = @group.persons.where(state: :robot)
      @undetected = @group.persons.where(state: :undetected)
    end
  end

  def create
    puts params['group_url']
    group = Vk::GroupParse.parse params['group_url']
    #group.save
    group.users << current_user
    current_user.groups << group
    current_user.save!
    group.save
    redirect_to :action=>'index'
#    Thread.new do
#      Vk::GroupUsersParse.perform(group.gid)
#    end
  end
end
