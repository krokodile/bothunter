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

      results     = Vk::API.call_method token, 'groups.getMembers', gid: gid, offset: offset
      count       = results['count']
      result_uids = results['users'].map(&:to_i)
      offset     += 1000

      result_uids.uniq!

      exists_people = Person.select(['people.id', 'people.uid']).
                      where(['uid IN (?)', result_uids.map(&:to_s)])
      old_ids       = exists_people.map(&:id).map(&:to_i)
      exists_uids   = exists_people.map(&:uid).map(&:to_i)
      result_uids  -= exists_uids

      next if result_uids.empty?

      now = Time.now

      new_uids = result_uids.map do |id|
        "('#{id}', '#{now}', '#{now}')"
      end

      new_ids = []
      ActiveRecord::Base.transaction do
        _res = Person.connection.execute("INSERT INTO \"people\" (uid, created_at, updated_at)
                                          VALUES #{new_uids.join(',')} RETURNING id;")
        new_ids = _res.entries.map(&:values).flatten.map(&:to_i)
      end

      ids_for_group     = (old_ids + new_ids).uniq
      exists_group_ids  = group.people.select('people.id').
                          where(['people.id IN (?)', ids_for_group]).
                          map(&:id).map(&:to_i)
      ids_for_group    -= exists_group_ids

      next if ids_for_group.empty?

      ids_for_group.map! do |id|
        "('#{id}', '#{gid}')"
      end

      ActiveRecord::Base.transaction do
        Person.connection.execute("INSERT INTO \"groups_people\" (person_id, group_id)
                                   VALUES #{ids_for_group.join(',')}")
      end
    end
  end
end
