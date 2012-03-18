class Vk::GroupUsersParse
  @queue = "bothunter"

  def self.perform gid
    group  = Group.find_by_gid gid
    offset = 0
    count  = 0
    token  = group.users.shuffle.first.token_for('vkontakte')

    people_limit = group.users.map(&:people_limit).max

    return if (group.people.count >= people_limit) && (people_limit > 0)

    while offset <= count do
      return if (group.people.count >= people_limit) && (people_limit > 0)

      results = Vk::API.call_method token, 'groups.getMembers', gid: gid, offset: offset
      count   = results['count']
      uids    = results['users'].map(&:to_i)
      offset += 1000

      uids.uniq!

      exists_uids = Person.select(:uid).where(['uid IN (?)', uids.map(&:to_s)]).map(&:uid).map(&:to_i)
      uids -= exists_uids

      next if uids.empty?

      now = Time.now

      new_uids = uids.map do |id|
        "('#{id}', '#{now}', '#{now}')"
      end

      new_ids = []
      ActiveRecord::Base.transaction do
        _res = Person.connection.execute("INSERT INTO \"people\" (uid, created_at, updated_at) VALUES #{new_uids.join(',')} RETURNING id;")
        new_ids = _res.entries.map(&:values).flatten
      end

      #TODO: Assign persons(new and old) with current group
    end
  end
end
