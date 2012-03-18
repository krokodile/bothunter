# encoding: utf-8

class GroupsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @groups =  current_user.groups.scoped

    if current_user.objects_amount <= 0
      @disabled = true
    end

    @group = @groups.find params[:id]
    @humans = @group.people.where(state: :human)
    @robots = @group.people.where(state: :robot)
    @undetected = @group.people.where(state: :undetected)
  end

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
    require "simple_xlsx"
    @group = Group.find params[:id]
    blob = StringIO.new('')
    #workbook = WriteExcel.new(blob)
    def make_sheet sheet,sym
      sheet.add_row(["Ссылка", "Имя", "Фамилия"])
      i = 2
      @group.people.where(state: sym).each do |person|
        sheet.add_row(["http://vk.com/id#{person.uid}",person.first_name.encode("utf-8"),person.last_name.encode("utf-8")])
        i+=1
      end
    end
    file_name = "persons-report#{Time.now}"
    serializer = SimpleXlsx::Serializer.new(file_name) do |workbook|
      workbook.add_sheet("Живые") do |humans|
        make_sheet(humans,:human)
      end
      workbook.add_sheet("Сомнительные") do |undetected|
        make_sheet(undetected,:undetected)
      end
      workbook.add_sheet("Боты") do |robots|
        make_sheet(robots,:robot)
      end
    end
    send_file file_name, :disposition => 'attachment', :type => "application/ms-excel",
              :filename => "bothunter.xlsx", :x_sendfile=>true
    #workbook.close
    #t.close
  end

end
