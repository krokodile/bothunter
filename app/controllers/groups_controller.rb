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

  def report_persons
    @group = Group.find params[:id]
    blob = StringIO.new('')
    workbook = WriteExcel.new(blob)
    def make_sheet sheet,sym
      sheet.write("Ссылка", "Имя", "Фамилия")
      @group.persons.where(state: :human).each do |person|
        sheet.write(["http://vk.com/id#{person.uid}",person.first_name,person.last_name])
      end
    end
    humans = workbook.add_worksheet("Живые")
    make_sheet()
    workbook.close
    send_data blob, :type => "application/ms-excel"

  end

end
