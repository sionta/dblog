# frozen_string_literal: true

require 'nokogiri'

module Jekyll
  module PageModified
    def page_modified(input)
      metadata = @context.registers[:site].data['metadata'] || {}
      fragment = fragment_element(input)
      fragment = parse_alerts(fragment, metadata['alerts'])
      fragment = parse_codes(fragment, metadata['codes'])
      fragment = parse_task_list(fragment)
      fragment.to_html
    end

    private

    def parse_alerts(doc, config)
      doc.css('.alert')&.each do |node|
        type = node['class'].match(/alert-(\w+)/)&.captures&.first

        # Set default values and then override if a specific type exists
        alert_data = config[type] || config['default'] || {}
        alert_icon = create_element('span', doc)
        alert_icon['class'] = 'alert-icon'
        alert_icon.add_child(svg_symbol(alert_data['icon']))

        alert_name = create_element('span', doc)
        alert_name['class'] = 'alert-name'
        alert_name.add_child(alert_data['name'])

        # Update the inner HTML with alert title and content
        alert_title = create_element('span', doc)
        alert_title['class'] = 'alert-header'
        alert_title.add_child(alert_icon)
        alert_title.add_child(alert_name)

        alert_content = create_element('div', doc)
        alert_content['class'] = 'alert-content'
        alert_content.add_child(node.inner_html)

        # Jekyll.logger.info('', node.name)
        node.name = 'div'
        node.inner_html = "#{alert_title}#{alert_content}"
        node.set_attribute('role', 'alert')
        node.set_attribute('data-type', alert_data['type']) if !node['data-type'] && alert_data['type']
      end
      doc
    end

    def parse_codes(doc, config)
      # From liquid tag => {% highlight %}
      doc.css('figure.highlight')&.each do |node|
        code_inner = node.at_css('pre code').inner_html
        data_lang = node.at_css('pre code')['data-lang']
        new_node = create_element('div', doc)
        node.attributes.each { |name, attr| new_node[name] = attr.value }
        new_node.remove_class('highlight')
        new_node.append_class("language-#{data_lang} highlighter-rouge")
        new_node.inner_html = %(<pre class="highlight"><code data-lang="#{data_lang}">#{code_inner}</code></pre>)
        node.replace(new_node)
      end

      doc = parse_mark_lines(doc)

      doc.css('[class*="language-"]')&.each do |node|
        language = node['class'].match(/language-(\S+)/).captures.first
        code_table = node.at_css('table:has(td pre)')
        next unless code_table

        code_icon = ''
        code_name = language

        config['languages'].each do |lang|
          next unless lang['alias'].include?(language)

          code_icon = svg_symbol(lang['icon'])
          code_name = lang['name']
          break
        end

        code_title = create_element('span', doc)
        code_title['class'] = 'code-header__title'
        code_title['data-name'] = code_name
        code_title.add_child(code_icon) if code_icon

        data_button = config['buttons'] || {
          copy: { name: 'Copy', icon: '' },
          success: { name: 'Copied', icon: '' },
          error: { name: 'Error!', icon: '' }
        }

        btn_icon_copy = create_element('span', doc)
        btn_icon_copy['class'] = 'code-copy'
        btn_icon_copy.inner_html = svg_symbol(data_button['copy']['icon'])
        btn_icon_success = create_element('span', doc)
        btn_icon_success['class'] = 'code-success'
        btn_icon_success.inner_html = svg_symbol(data_button['success']['icon'])

        code_action = create_element('button', doc)
        code_action['type'] = 'button'
        code_action['class'] = 'code-header__button'
        code_action['aria-label'] = "Copy #{code_name} code to clipboard"
        code_action['data-label-copy'] = data_button['copy']['name']
        code_action['data-label-success'] = data_button['success']['name']
        code_action.add_child(btn_icon_copy)
        code_action.add_child(btn_icon_success)

        container = create_element('figure', doc)
        container.append_class('highlight code-blocks')

        # Create header with language name and icon
        code_header = create_element('figcaption', doc)
        code_header.append_class('code-header')
        code_header.add_child(code_title)
        code_header.add_child(code_action)
        container.add_child(code_header)

        # Process line numbers and code content
        code_section = create_element('div', doc)
        code_section.append_class("#{code_table['class']} rouge-block")
        line_numbers = create_pre_block(doc, code_table, 'td:nth-child(1)')
        code_content = create_pre_block(doc, code_table, 'td:nth-child(2)')
        code_content.set_attribute('data-block-copy', 'true')
        code_section.add_child(line_numbers)
        code_section.add_child(code_content)
        container.add_child(code_section)

        # Replace original table with the new container
        node.inner_html = container
      end
      doc
    end

    def create_pre_block(input, table, query)
      pre_block = create_element('pre', input)
      table.at_css(query).attributes.each { |k, v| pre_block[k] = v.value }

      code_child = create_element('code', input)
      table.at_css("#{query} pre").attributes.each { |k, v| code_child[k] = v.value }
      code_child.add_child(table.at_css("#{query} pre").inner_html)

      pre_block.add_child(code_child)
      pre_block
    end

    def parse_mark_lines(doc)
      # config = @context.registers[:site].config || {}
      # highlighter_opts = config.dig('kramdown', 'syntax_highlighter_opts', 'block') || {}

      doc.css('[data-mark-lines]').each do |node|
        if node.at_css('table td:nth-child(2) pre')
          code_inner = node.at_css('table td:nth-child(2) pre')
        elsif node.at_css('pre code:not(:has(table))')
          code_inner = node.at_css('pre code:not(:has(table))')
        else
          next
        end

        data_lang = node['class'].match(/language-(\S+)/)&.captures&.first
        mark_lines = node['data-mark-lines'].split.map(&:to_i)
        code_block = code_inner.text

        lexer = Rouge::Lexer.find_fancy(data_lang, code_block) || Rouge::Lexers::PlainText
        formatter = Rouge::Formatters::HTML.new
        formatter = Rouge::Formatters::HTMLLineHighlighter.new(
          formatter,
          highlight_line_class: 'hll',
          highlight_lines: mark_lines
        )
        # formatter = table_formatter(formatter, highlighter_opts) if code_inner.name == 'pre'
        code_inner.inner_html = formatter.format(lexer.lex(code_block))
      end

      doc
    end

    def table_formatter(formatter, options)
      Rouge::Formatters::HTMLTable.new(
        formatter,
        css_class: options.fetch(:css_class, 'highlight'),
        line_class: options.fetch(:line_class, 'lineno'),
        table_class: options.fetch(:table_class, 'rouge-table'),
        gutter_class: options.fetch(:gutter_class, 'rouge-line'),
        code_class: options.fetch(:code_class, 'rouge-code')
      )
    end

    def parse_task_list(doc)
      doc.css('ul.task-list li').each do |item|
        checkbox = item.at('input.task-list-item-checkbox')
        next unless checkbox

        icon_name = checkbox['checked'] ? 'circle-check' : 'circle'
        icon_class = checkbox['class'] + (checkbox['checked'] ? ' checked' : ' disabled').to_s
        icon_elem = create_element('i', doc)
        icon_elem['class'] = "ti ti-#{icon_name} #{icon_class}"
        checkbox.replace(icon_elem)
      end
      doc
    end

    def create_element(tag, doc)
      doc ||= Nokogiri::HTML::Document.new
      Nokogiri::XML::Node.new(tag, doc)
    end

    def fragment_element(doc)
      Nokogiri::HTML::DocumentFragment.parse(doc)
    end

    def html_element?(text)
      doc = fragment_element(text)
      element = doc.children.first
      element && element.node_type == Nokogiri::XML::Node::ELEMENT_NODE
    end

    # Generates an SVG symbol element for icons.
    #
    # @param icon_name [String, nil] The name of the icon.
    # @param class_line [String, nil] Optional CSS class to be added.
    # @param attr_lines [String, nil] Optional inline attributes to be added.
    # @return [String, nil] The SVG symbol markup or nil if icon_name is nil or empty.
    #
    # @example
    #   svg_symbol('copy', 'icon-copy', 'aria-label="Copy"')
    #   # => '<svg class="icon icon-copy" aria-label="Copy" width="24" height="24" viewBox="0 0 24 24" aria-hidden="true"><use href="/assets/icons.svg#copy"></use></svg>'
    #
    def svg_symbol(icon_name = nil, class_line = nil, attr_lines = nil)
      return unless !icon_name.nil? && !icon_name.empty?

      return icon_name if html_element?(icon_name)

      # "baseurl" is required if build from github-pages.
      baseurl = @context.registers[:site].config['baseurl'] || ''
      svg_path = File.join(baseurl, 'assets', 'icons.svg')
      raise "File not found '#{svg_path}'" unless svg_path

      svg_path = "#{svg_path}##{icon_name}".downcase

      svg_class = class_line ? " #{class_line}" : ''
      svg_attrs = attr_lines ? " #{attr_lines}" : ''
      %(<svg class="icon#{svg_class}"#{svg_attrs} width="24" height="24" viewBox="0 0 24 24" aria-hidden="true"><use href="#{svg_path}"></use></svg>)
    end
  end
end

Liquid::Template.register_filter(Jekyll::PageModified)
