# encoding: utf-8

class AuthorizationsController < ApplicationController
  before_filter :authenticate_user!

  def create
    token = current_user.oauth_tokens.find_or_initialize_by_provider_and_domain(
      provider: request.env['omniauth.auth'][:provider],
      domain: request.env['omniauth.auth'][:extra][:raw_info][:domain]
    )
    token.update_attributes! token: request.env['omniauth.auth'][:credentials][:token]

    redirect_to root_path, notice: 'Ваша авторизация Вконтакте добавлена.'

    #omniauth = request.env['omniauth.auth']
    #@auth = Authorization.find_from_hash omniauth
    #
    #if current_user.present?
    #  current_user.authorizations.create :Provider => omniauth['provider'], :UID => omniauth['uid']
    #elsif @auth.present?
    #  Session.create @auth.user, true
    #else
    #  @new_auth = Authorization.create_from_hash omniauth, current_user
    #  Session.create @new_auth.user, true
    #end
    #
    #redirect_back_or_default
  end

  def failure
    #redirect_to root_url, notice: t('not_authorize')
    redirect_to root_path, error: 'Произошла ошибка при добавлении авторизации Вконтакте!'
  end

  def destroy
    #@authorization = current_user.authorizations.find params[:id]
    #@authorization.destroy

    #redirect_to root_url, notice: t('deleted_auth')
  end
end
