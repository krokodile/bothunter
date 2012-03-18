# encoding: utf-8

class PagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  
  def index
    @groups =  current_user.groups.all

    if current_user.objects_amount <= 0
      @disabled = true
    end

    if params['group_id']
      @group = Group.find(params['group_id'])
      @humans = @group.persons.where(state: :human)#.count
      @robots = @group.persons.where(state: :robot)#.count
      @undetected = @group.persons.where(state: :undetected)#.count
    end
  end

  def create
    if current_user.objects_amount > 0
      gid = Vk::Helpers.parse_gid params['group_url']
      api_result = Vk::API.call_method current_user.oauth_tokens.shuffle.first.token, 'groups.getById', gid: gid

      group = ::Group.find_or_create_by_gid api_result["gid"]
      group.update_attributes!({
        title: api_result["name"],
        domain: api_result["screen_name"]
      })

      group.users << current_user

      current_user.groups << group
      current_user.objects_amount -= 1
      current_user.save!

      group.save!
    else
      flash[:notice] = 'Вы не можете добавить группу из-за ограничений вашего аккаунта. Пожалуйста, свяжитесь с менеджером.'
    end

    redirect_to action: 'index'
  end
end
