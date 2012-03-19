# encoding: utf-8

class PromocodesController < ApplicationController
  before_filter :authenticate_user!

  authorize_resource

  def index
    @promocodes = Promocode.page params[:page]
  end

  def new
    respond_to do |format|
      format.html { @promocode = Promocode.new code: random_words_string }
      format.js
    end
  end

  def create
    @promocode      = Promocode.new params[:promocode]
    @promocode.code = random_words_string unless @promocode.code.present?

    if @promocode.save
      redirect_to promocodes_path, notice: 'Промо-код успешно создан'
    else
      render 'new'
    end
  end

  def destroy
    @promocode = Promocode.find params[:id]
    @promocode.delete

    redirect_to action: 'index', notice: 'Промо-код удален'
  end
end
