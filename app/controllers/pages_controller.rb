# encoding: utf-8

class PagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  
  def index
    @groups =  current_user.groups.all #Group.where(user: )
    if current_user.objects_amount <= 0
      @disabled = true
    end
    if params['group_id']
      @group = Group.find(params['group_id'])
      @humans = @group.persons.where(state: :human).count
      @robots = @group.persons.where(state: :robot).count
      @undetected = @group.persons.where(state: :undetected).count
    end
  end

  def create
    #puts params['group_url']
    if current_user.objects_amount > 0
      group = Vk::GroupParse.parse params['group_url']
      #group.save
      group.users << current_user
      current_user.groups << group
      current_user.objects_amount -= 1
      current_user.save!
      group.save!
    else
      flash[:notice] = 'Вы не можете добавить группу из-за ограничений вашего аккаунта. Пожалуйста, свяжитесь с менеджером.'
    end

    redirect_to action: 'index'
#    Thread.new do
#      Vk::GroupUsersParse.perform(group.gid)
  end
end
