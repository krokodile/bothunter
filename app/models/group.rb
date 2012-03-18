# encoding: utf-8

class Group < ActiveRecord::Base
  has_and_belongs_to_many :people, uniq: true
  has_and_belongs_to_many :users, uniq: true

  validates_presence_of :gid
  validates_uniqueness_of :gid
  validates_numericality_of :gid, greater_than: 0

  def self.find_by_vkontakte_gid gid
    gid = gid.to_s
    #group = ::Vk::Helpers.parse_gid url
    #puts "parse is #{group} on url #{url}"

    if ::Vk::Helpers.is_gid? gid
      Group.find_by_gid gid
    else
      Group.find_by_domain gid
    end
  end

  def self.report_persons gid
    #workbook = RubyXL::Workbook.new
    #serializer = ::SimpleXlsx::Serializer.new("/home/boris/me.xls") do |doc|
    #worbook = WriteExcel.new("/home/boris/me.xls")
    #sheet = worbook.add_worksheet("Живые")
    #sheet.write("Ссылка", "Имя", "Фамилия")

    doc = SimpleXlsx::Serializer.new("test.xlsx")
    sheet = doc.add_sheet("Живые")
    Group.where(gid: gid).first.people.where(state: :human).each do |person|
      sheet.add_row(["http://vk.com/id#{person.uid}",person.first_name,person.last_name])
    end
    #workbook.close
   #(sheet,:human)
    #end

  end
end
