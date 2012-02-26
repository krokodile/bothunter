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
      sheet.write_row("A1",["Ссылка", "Имя", "Фамилия"])
      i = 2
      @group.persons.where(state: sym).each do |person|
        sheet.write_row("A#{i}",["http://vk.com/id#{person.uid}",person.first_name,person.last_name])
        i+=1
      end
    end
    humans = workbook.add_worksheet("Живые")
    humans.write_row("A1",["Ссылка", "Имя", "Фамилия"])
    make_sheet(humans,:human)
    undetected = workbook.add_worksheet("Сомнительные")
    make_sheet(undetected,:undetected)
    robots = workbook.add_worksheet("Боты")
    make_sheet(robots,:robot)
    workbook.close
    send_data  blob.string, :type => "application/ms-excel"

  end

end
