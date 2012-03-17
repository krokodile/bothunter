class PeopleController < ApplicationController
  before_filter :authenticate_user!

  def humanize
    @person = Person.find(params[:id])
    # FIXME: access control!
    # (not possible to do easy way because of DB schema)

    if request.get?
      @person.set :state, :human
    elsif request.delete?
      @person.set :state, :robot
    end

  end
end
