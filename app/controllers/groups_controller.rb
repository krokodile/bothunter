class GroupsController < ApplicationController


  def show #gid
    group = ::Group.where(_id: params['id']).first
    @humans = group.people.where(state: :human)
    @robots = group.people.where(state: :robot)
    @undetected = group.people.where(state: :undetected)
  end

end
