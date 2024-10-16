# frozen_string_literal: true

module Jekyll
  module Tags
    class TabsBlock < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @tabs = []
        @tabs_id = rand(999..9999)
      end

      def render(context)
        context.registers[:tabs] = self
        super

        results = @tabs.map.with_index do |tab, index|
          parse_tabs(tab[:title], tab[:content], index)
        end.join

        <<~HTML
          <fieldset class="tabs" id="tabs-#{@tabs_id}">
            <legend style="display: none;">Tabs</legend>
            #{results}
          </fieldset>
        HTML
      end

      def add_tab(title, content)
        @tabs << { title: title, content: content }
      end

      private

      def parse_tabs(title, panel, index)
        require 'nokogiri'

        input_id = "tab-input-#{index}-#{@tabs_id}"
        content_id = "tab-panel-#{index}-#{@tabs_id}"

        elem_input = Nokogiri::XML::Node.new('input', Nokogiri::HTML::Document.new)
        elem_input['id'] = input_id
        elem_input['name'] = "tab-input-#{@tabs_id}"
        elem_input['type'] = 'radio'
        elem_input['class'] = 'tab-input'
        elem_input['checked'] = '' if index.zero?

        elem_label = Nokogiri::XML::Node.new('label', Nokogiri::HTML::Document.new)
        elem_label['for'] = input_id
        # elem_label['aria-controls'] = content_id
        elem_label['role'] = 'tab'
        elem_label['class'] = 'tab-label'
        elem_label.inner_html = title

        elem_panel = Nokogiri::XML::Node.new('div', Nokogiri::HTML::Document.new)
        elem_panel['id'] = content_id
        # elem_panel['aria-labelledby'] = input_id
        elem_panel['role'] = 'tabpanel'
        elem_panel['class'] = 'tab-panel'
        elem_panel.inner_html = render_markdown(panel)

        %(#{elem_input.to_html}#{elem_label.to_html}#{elem_panel.to_html})
      end

      def render_markdown(content)
        require 'kramdown'

        site = Jekyll.sites.first.config
        options = site['kramdown'] || {}

        if site['markdown'] == 'kramdown'
          Kramdown::Document.new(content, options).to_html
        else
          content.to_str
        end
      end
    end

    class TabBlock < Liquid::Block
      def initialize(tag_name, markup, tokens)
        super
        @tab_title = markup.strip.gsub(/[',"]/, '')
      end

      def render(context)
        return unless context.registers[:tabs]

        context.registers[:tabs].add_tab(@tab_title, super.strip)
      end
    end
  end
end

Liquid::Template.register_tag('tabs', Jekyll::Tags::TabsBlock)
Liquid::Template.register_tag('tab', Jekyll::Tags::TabBlock)
