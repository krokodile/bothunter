# encoding: utf-8

class UsersController < ApplicationController
  before_filter :authenticate_user!

  authorize_resource

  def new
    @user = User.new
  end

  def index
    @users = User.latest.page params[:page]
  end

  def create_as_admin
    @user = User.new params[:user], as: :admin

    if @user.save
      redirect_to users_path, notice: 'Пользователь успешно создан'
    else
      render 'new'
    end
  end

  def manager
    manager = !resource.manager?
    resource.set :_type, (manager ? 'Manager' : 'User')
    render :js => %<$('a[data-manager-id="#{resource.id.to_s}"]')['#{manager ? 'addClass' : 'removeClass'}']('success').text('#{manager ? 'Y' : 'N'}')>
  end

  def approved
    approved = !resource.approved?
    resource.set :approved, approved
    render :js => %<$('a[data-approved-id="#{resource.id.to_s}"]')['#{approved ? 'addClass' : 'removeClass'}']('success').text('#{approved ? 'Y' : 'N'}')>
  end

  def destroy
    @user = User.find params[:id]

    unless user == current_user
      @user.delete

      flash[:notice] = 'Пользователь удален'
    else
      flash[:error] = 'Пользователь не может удалить самого себя!'
    end

    redirect_to users_path
  end

  protected

  def collection
    @users ||= if params[:show].nil?
                 end_of_association_chain.all
               elsif params[:show] == 'inactive'
                 end_of_association_chain.where(['approved != ?', true])
               end
  end
end
