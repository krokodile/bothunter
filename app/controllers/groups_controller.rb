class GroupsController < ApplicationController
  def add
    group = Vk::GroupParse.parse params['group_url']
    group.users << current_user
    group.save
  end

  #def show #gid
  #  @group = Group.first( :conditions {id: params['group_id']})
  #  @humans = @group.persons.where(state: :human)
  #  @robots = @group.persons.where(state: :robot)
  #  @undetected = @group.persons.where(state: :undetected)
  #end

end
