# encoding: utf-8
class GroupsController < ApplicationController

  def delete_robots
    @group = Group.find params[:id]
    # FIXME: доступ!
    #raise 'Это не ваша группа' unless @group.user_id == current_user.id
    Resque.enqueue BotFilter, @group.gid, params[:login], params[:password]
    render :js => %<$('a[data-gid-to-delete="#{@group.gid}"]').removeClass('danger').addClass('info').text('OK!')>
  rescue
    render :js => %<$('a[data-gid-to-delete="#{@group.gid}"]').removeClass('danger').text(#{$!.to_s.inspect})>
  end


  #def show #gid
  #  @group = Group.first( :conditions {id: params['group_id']})
  #  @humans = @group.persons.where(state: :human)
  #  @robots = @group.persons.where(state: :robot)
  #  @undetected = @group.persons.where(state: :undetected)
  #end

end
