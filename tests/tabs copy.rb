# frozen_string_literal: true

#
# Jekyll Tabs Plugin
#
# This plugin allows users to create tabbed content in their Jekyll site.
#
# Usage:
#   {% tabs %}
#     {% tab label="Tab 1" %}
#     Content for Tab 1.
#     {% endtab %}
#     {% tab label="Tab 2" %}
#     Content for Tab 2.
#     {% endtab %}
#   {% endtabs %}

module Jekyll
  module Tags
    class TabsBlock < Liquid::Block
      def initialize(tag_name, params, tokens)
        super
        @tabs = []
        @content_blocks = []
      end

      def render(context)
        context.registers[:tabs_parent] = self # Register the TabsBlock instance

        content = super
        render_output(content)
      end

      # Add a tab to the list
      #
      # @param label [String] The label for the tab
      # @param content [String] The content for the tab
      def add_tab(label, content)
        @tabs << label
        @content_blocks << content
      end

      # Renders the tabs and content blocks
      #
      # @param content [String] The content to include within the tabs
      # @return [String] The generated HTML for the tabs and content
      def render_output(_content)
        tab_labels = render_labels
        tab_contents = render_contents

        <<~HTML
          <div class="tabs" role="tablist" aria-label="Tabbed content">
            <ul class="tab-labels">
              #{tab_labels}
            </ul>
            <div class="tab-contents">
              #{tab_contents}
            </div>
          </div>
        HTML
      end

      # Render the HTML for the tab labels
      #
      # @return [String] The generated HTML for the tab labels
      def render_labels
        @tabs.map.with_index do |label, index|
          active_class = index.zero? ? 'active' : ''
          "<li class=\"tab-label #{active_class}\" data-tab=\"tab-#{index}\" role=\"tab\" aria-selected=\"#{active_class}\">#{label}</li>"
        end.join("\n")
      end

      # Render the HTML for the tab contents
      #
      # @return [String] The generated HTML for the tab contents
      def render_contents
        @content_blocks.map.with_index do |content, index|
          active_class = index.zero? ? 'active' : ''
          # Render Markdown content to HTML
          html_content = render_markdown(content)
          "<div id=\"tab-#{index}\" class=\"tab-content #{active_class}\" role=\"tabpanel\">#{html_content}</div>"
        end.join("\n")
      end

      # Renders Markdown content into HTML using Kramdown
      #
      # @param content [String] The Markdown content to render
      # @return [String] The rendered HTML
      def render_markdown(content)
        Kramdown::Document.new(content).to_html # Use Kramdown to convert Markdown to HTML
      end
    end

    class TabBlock < Liquid::Block
      def initialize(tag_name, params, tokens)
        super
        @label = params.match(/label="(.+?)"/)[1] # Extract the label from the params
      end

      def render(context)
        parent = context.registers[:tabs_parent]
        content = super

        raise 'No parent TabsBlock found in the context' unless parent

        # Add the tab label and its content to the parent TabsBlock
        parent.add_tab(@label, content)

        '' # We don't need to output anything here directly
      end
    end
  end
end

Liquid::Template.register_tag('tabs', Jekyll::Tags::TabsBlock)
Liquid::Template.register_tag('tab', Jekyll::Tags::TabBlock)
