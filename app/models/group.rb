# encoding: utf-8

class Group < ActiveRecord::Base
  extend ActiveRecord::ConnectionAdapters::Quoting

  has_and_belongs_to_many :people, uniq: true
  has_and_belongs_to_many :users, uniq: true

  validates_presence_of :gid
  validates_uniqueness_of :gid
  validates_numericality_of :gid, greater_than: 0

  mount_uploader :cover, GroupCoverUploader

  scope :latest, order('updated_at DESC, created_at DESC')

  def self.alive_for_groups groups_ids
    self.count_for_groups groups_ids, 'alive'
  end

  def self.unknown_for_groups groups_ids
    self.count_for_groups groups_ids, 'unknown'
  end

  def self.bots_for_groups groups_ids
    self.count_for_groups groups_ids, 'bot'
  end

  def self.report_persons gid
    #workbook = RubyXL::Workbook.new
    #serializer = ::SimpleXlsx::Serializer.new("/home/boris/me.xls") do |doc|
    #worbook = WriteExcel.new("/home/boris/me.xls")
    #sheet = worbook.add_worksheet("Живые")
    #sheet.write("Ссылка", "Имя", "Фамилия")

    doc = SimpleXlsx::Serializer.new("test.xlsx")
    sheet = doc.add_sheet("Живые")
    Group.where(gid: gid).first.people.where(state: 'alive').each do |person|
      sheet.add_row(["http://vk.com/id#{person.uid}",person.first_name,person.last_name])
    end
    #workbook.close
   #(sheet,:alive)
    #end

  end

  private

  def self.count_for_groups groups_ids, state
    uncached do
      self.connection.execute(%Q{
        SELECT COUNT(DISTINCT(people.id)) as count
        FROM people
        JOIN groups ON groups.id IN (#{groups_ids.map(&:to_i).join(',')})
        JOIN groups_people ON groups_people.group_id = groups.id AND
          groups_people.person_id = people.id
        WHERE people.state = #{quote state.to_s}
      }).entries.first.values.first.to_i rescue 0
    end
  end
end
