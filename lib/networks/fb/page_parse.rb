module Fb
  class ObjectIsNotAPage < Exception;end
  class ObjectIsNotFound < Exception;end

  class PageParse
    def self.parse page, token, only_page = false
      page_json = ::Fb::API.explorer ::Fb.arg2id page rescue nil
      if page_json.nil?
        raise Fb::ObjectIsNotFound, "Object #{page} is not found!"
      elsif only_page and page_json['category'].nil?
        raise Fb::ObjectIsNotAPage, "Object #{page} is not a page!"
      end

      page_id = page_json['id']
      page = Fb::Page.find_or_create_by_page_id page_id: page_id
      page.update_attributes({
        name: page_json['name'],
        username: page_json['username']
      })

      if block_given?
        yield page
      end

      page_id
    end
  end
end
