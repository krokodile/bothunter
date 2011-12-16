class PagesController < ApplicationController
  respond_to :html
  
  def index
    @groups =  current_user.groups #Group.where(user: )
    if params['group_id']
      @group = @groups.find(params['group_id'])
      @humans = @group.persons.where(state: :human)
      @robots = @group.persons.where(state: :robot)
      @undetected = @group.persons.where(state: :undetected)
      if params['human_person_id']
        @person = @group.persons.find(params['human_person_id'])
        @person.state = "human"
        @person.save
      elsif params['robot_person_id']
        @person = @group.persons.find(params['robot_person_id'])
        @person.state = "robot"
        @person.save
      end
    end
  end

  def create
    puts params['group_url']
    group = Vk::GroupParse.parse params['group_url']
    #group.save
    group.users << current_user
    group.save
    redirect_to :action=>'index'
#    Thread.new do
#      Vk::GroupUsersParse.perform(group.gid)
#    end
  end

  def delete_robots

  end
end
