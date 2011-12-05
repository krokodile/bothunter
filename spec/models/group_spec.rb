require 'spec_helper'


describe Group do
  context "Simple operations" do
     before do
       group1 = Group.new(gid: 'g_0', link: '/ffff')
       group2 = Group.new(gid: 'g_1', link: '/ffff')
       profile1 = Person.new(uid: 'u_0')
       profile2 = Person.new(uid: 'u_1')
       group1.people << profile1
       group1.save
       group2.save
       profile1.save
       profile2.groups << group1
       profile2.save
     end


    it "test relations" do

      #To change this template use File | Settings | File Templates.
      Group.where(gid: 'g_0').first.people.size.should be 2
      Person.where(uid: 'u_0').first.groups.size.should be 1
    end
  end
end