class GroupsController < ApplicationController
  def add
    group = Vk::GroupParse.parse params['group_url']
    group.users << current_user
    group.save
  end

  def show #gid
    group = ::Group.where(_id: params['id']).first
    @humans = group.people.where(state: :human)
    @robots = group.people.where(state: :robot)
    @undetected = group.people.where(state: :undetected)
  end

end
