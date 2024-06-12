module Jekyll
  class LastModifiedAtTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      page = context.registers[:page]

      if page
        last_modified_at = page['last_modified_at']
        last_modified_at ||= find_last_modified_from_generator(context)
        format_last_modified_at(last_modified_at, context)
      end
    end

    private

    def find_last_modified_from_generator(context)
      site = context.registers[:site]
      site.posts.docs.each do |post|
        return post['last_modified_at'] if post['last_modified_at']
      end
      nil
    end

    def format_last_modified_at(last_modified_at, context)
      if @markup.empty?
        last_modified_at.strftime("%Y-%m-%d %H:%M:%S %z") if last_modified_at
      else
        date_format = Liquid::Template.parse(context[@markup]).render(context)
        last_modified_at.strftime(date_format) if last_modified_at
      end
    end
  end

  class LastModifiedGenerator < Generator
    priority :low

    def generate(site)
      site.posts.docs.each do |post|
        if post.data['last_modified_at'].nil?
          post.data['last_modified_at'] = File.mtime(post.path)
        end
      end
    end
  end
end

Liquid::Template.register_tag('last_modified_at', Jekyll::LastModifiedAtTag)
