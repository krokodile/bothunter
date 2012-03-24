class PeopleController < ApplicationController
  before_filter :authenticate_user!

  authorize_resource

  def humanize
    @person = Person.find(params[:id])
    # FIXME: access control!
    # (not possible to do easy way because of DB schema)

    if request.get?
      @person.set :state, :alive
    elsif request.delete?
      @person.set :state, :bot
    end

  end
end
