# encoding: utf-8

class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user_id_and_group_id

  authorize_resource

  def index
    groups_ids = @groups.map(&:id)

    @alive_count   = Group.alive_for_groups groups_ids
    @unknown_count = Group.unknown_for_groups groups_ids
    @bots_count    = Group.bots_for_groups groups_ids
  end

  def show
    if current_user.groups_limit <= 0
      @disabled = true
    end

    @alive   = @group.people.where(state: 'alive')
    @bots    = @group.people.where(state: 'bot')
    @unknown = @group.people.where(state: 'unknown')
  end

  def alive
    @persons = @group.people.alive.page params[:page]
    @title = 'Живые пользователи'

    render 'show_persons'
  end

  def bots
    @persons = @group.people.bots.page params[:page]
    @title = 'Боты'

    render 'show_persons'
  end

  def unknown
    @persons = @group.people.unknown.page params[:page]
    @title = 'Сомнительные'

    render 'show_persons'
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
  #  @alives = @group.persons.where(state: :alive)
  #  @bots = @group.persons.where(state: :bot)
  #  @unknown = @group.persons.where(state: :unknown)
  #end

  def report_persons
    @group = Group.find params[:id]
    blob = StringIO.new('')
    #workbook = WriteExcel.new(blob)

    def make_sheet sheet, sym
      sheet.add_row(["Ссылка", "Имя", "Фамилия"])
      i = 2

      @group.people.where(state: sym).each do |person|
        sheet.add_row(["http://vk.com/id#{person.uid}",person.first_name.encode("utf-8"),person.last_name.encode("utf-8")])
        i+=1
      end
    end

    file_name = "persons-report#{Time.now}"
    serializer = SimpleXlsx::Serializer.new(file_name) do |workbook|
      workbook.add_sheet("Живые") do |alives|
        make_sheet(alives, 'alive')
      end
      workbook.add_sheet("Сомнительные") do |unknown|
        make_sheet(unknown, 'unknown')
      end
      workbook.add_sheet("Боты") do |bots|
        make_sheet(bots, 'bot')
      end
    end

    send_file file_name,
              disposition: 'attachment',
              type: "application/ms-excel",
              filename: "bothunter.xlsx",
              x_sendfile: true
    #workbook.close
    #t.close
  end

  private

  def get_user_id_and_group_id
    if (current_user.admin? || current_user.manager?) && params[:user_id].present?
      @user = User.find params[:user_id]
    else
      @user = current_user
    end

    @groups = @user.groups.latest.scoped
    @group = @groups.find params[:id] if params[:id].present?

    authorize! :read, @groups
    authorize! :read, @group  if params[:id].present?
  end
end
