# encoding: utf-8

class PagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  
  def index
    @groups =  current_user.groups.all

    if current_user.groups_limit <= 0
      @disabled = true
    end
  end

  def create
    token = current_user.token_for('vkontakte')

    if token.present?
      if current_user.groups_limit > 0
        gid = Vk::Helpers.parse_gid params['group_url']
        api_result = Vk::API.call_method token, 'groups.getById', gid: gid

        if api_result.present? && api_result["gid"].to_i > 0
          group = ::Group.find_or_create_by_gid api_result["gid"].to_s
          group.update_attributes!({
            title:  api_result["name"],
            domain: api_result["screen_name"],
            remote_cover_url:  api_result["photo_medium"]
          })

          group.users << current_user

          current_user.groups << group
          current_user.groups_limit -= 1
          current_user.save!

          group.save!
        else
          flash[:error] = "Группа \"#{view_context.link_to params[:group_url], params[:group_url]}\" не найдена!".html_safe # without XSS
        end
      else
        flash[:notice] = 'Вы не можете добавить группу из-за ограничений вашего аккаунта. Пожалуйста, свяжитесь с менеджером.'
      end
    else
      flash[:error] = "Для начала нужно #{view_context.link_to "добавить", '/auth/vkontakte'} свой Вконтакте аккаунт!".html_safe
    end

    redirect_to action: 'index'
  end
end
