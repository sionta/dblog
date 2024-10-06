# frozen_string_literal: true

require 'nokogiri'

module Jekyll
  module PageModified
    def page_modified(input)
      metadata = @context.registers[:site].data['metadata'] || {}
      document = parse_html(input)
      document = parse_alerts(document, metadata['block_alerts'])
      document = parse_codes(document, metadata['block_codes'])
      document = parse_task_list(document)
      document.to_html
    end

    private

    def create_element(tag, doc)
      Nokogiri::XML::Node.new(tag, doc)
    end

    def parse_html(doc)
      Nokogiri::HTML5.fragment(doc)
      # Nokogiri::HTML::DocumentFragment.parse(doc)
    end

    def parse_alerts(doc, config)
      doc.css('.alert')&.each do |node|
        type = node['class'].match(/alert-(\w+)/)&.captures&.first

        # Set default values and then override if a specific type exists
        alert_data = config[type] || config['default'] || {}
        alert_icon = create_element('span', doc)
        alert_icon['class'] = 'alert-icon'
        alert_icon.add_child(alert_data['icon'])

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
        node.set_attribute('data-type', alert_data['type']) if !node['data-alert-type'] && alert_data['type']
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

      doc.css('[class*="language-"]')&.each do |node|
        language = node['class'].match(/language-(\S+)/).captures.first
        code_table = node.at_css('table:has(td pre)')
        next unless code_table

        code_icon = '<i class="ti ti-code"></i>'
        code_name = language

        config['languages'].each do |lang|
          next unless lang['alias'].include?(language)

          code_icon = lang['icon']
          code_name = lang['name']
          break
        end

        code_title = create_element('span', doc)
        code_title['class'] = 'code-header__title'
        code_title['data-name'] = code_name
        code_title.add_child(code_icon)

        data_button = config['buttons'] || {
          copy: { name: 'Copy', icon: '' },
          success: { name: 'Copied', icon: '' },
          error: { name: 'Error!', icon: '' }
        }

        btn_icon_copy = create_element('span', doc)
        btn_icon_copy['class'] = 'code-copy'
        btn_icon_copy.inner_html = data_button['copy']['icon']
        btn_icon_success = create_element('span', doc)
        btn_icon_success['class'] = 'code-success'
        btn_icon_success.inner_html = data_button['success']['icon']

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
        code_section.append_class("#{code_table['class']} code-section")
        line_numbers = create_pre_block(doc, code_table, 'td:nth-child(1)')
        code_content = create_pre_block(doc, code_table, 'td:nth-child(2)')
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
  end
end

Liquid::Template.register_filter(Jekyll::PageModified)
