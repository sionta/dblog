# frozen_string_literal: true

require 'nokogiri'

module Jekyll
  module HelperFilters
    # @example Usage in Liquid:
    #   {{ page.content | inject_attributes: "a", { "target": "_blank", "rel": "noopener" } }}
    #
    # Very useful for ensuring external links open in new tabs
    # and come with security attributes like rel="noopener"
    # without having to manually add attributes to each link.
    def inject_attributes(input, tag, attributes = {})
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      doc.css(tag).each do |element|
        attributes.each do |attr, value|
          element.set_attribute(attr, value)
        end
      end
      doc.to_html
    end

    # Removes specified attributes from the given HTML tags in the input content.
    #
    # @param input [String] The HTML content to process.
    # @param tag [String] The HTML tag to remove attributes from (e.g., "img").
    # @param attributes [Array] An array of attributes to remove (e.g., ["width", "height"]).
    # @return [String] The content with the specified attributes removed from the tags.
    #
    # @example Usage in Liquid:
    #   {{ page.content | remove_attributes: "img", ["width", "height"] }}
    #
    # This will remove the "width" and "height" attributes from all <img> tags.
    def remove_attributes(input, tag, attributes = [])
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      doc.css(tag).each do |element|
        attributes.each { |attr| element.remove_attribute(attr) }
      end
      doc.to_html
    end

    # Removes all occurrences of a specified HTML tag from the input content.
    #
    # @param input [String] The HTML content to process.
    # @param tag [String] The HTML tag to remove (e.g., "script").
    # @return [String] The content with the specified tags removed.
    #
    # @example Usage in Liquid:
    #   {{ page.content | remove_elements: "script" }}
    #
    # This will remove all <script> tags from the content.
    def remove_elements(input, tag)
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      doc.css(tag).remove
      doc.to_html
    end

    # Adds a specified class to all elements with a given tag in the HTML content.
    #
    # @param input [String] The HTML content to modify.
    # @param tag [String] The HTML tag to target (e.g., "img", "div").
    # @param class_name [String] The CSS class to add to the elements.
    # @return [String] The modified HTML content with the added class.
    #
    # @usage
    # {{ page.content | add_class_to_elements: "img", "responsive" }}
    #
    # This will add the class "responsive" to all <img> elements in the content.
    def append_class(input, tag, class_name)
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      doc.css(tag).each do |element|
        element['class'] = element['class'].to_s.split(/\s+/).push(class_name).uniq.join(' ')
      end
      doc.to_html
    end

    # Prepends a CSS class to the specified HTML tag within the input content.
    #
    # @param input [String] The HTML content to process.
    # @param tag [String] The HTML tag to prepend the class to (e.g., "div").
    # @param class_name [String] The CSS class to prepend.
    # @return [String] The content with the class prepended to the specified tags.
    #
    # @example Usage in Liquid:
    #   {{ page.content | prepend_class: "div", "highlight" }}
    #
    # This will prepend the class "highlight" to all <div> tags in the content.
    def prepend_class(input, tag, class_name)
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      doc.css(tag).each do |element|
        existing_classes = element.get_attribute('class').to_s.split(' ')
        element.set_attribute('class', ([class_name] + existing_classes).uniq.join(' '))
      end
      doc.to_html
    end

    # Replaces one type of HTML tag with another in the input content.
    #
    # @param input [String] The HTML content to process.
    # @param old_tag [String] The HTML tag to replace (e.g., "div").
    # @param new_tag [String] The HTML tag to replace it with (e.g., "section").
    # @return [String] The content with all occurrences of the old tag replaced by the new tag.
    #
    # @example Usage in Liquid:
    #   {{ page.content | replace_elements: "div", "section" }}
    #
    # This will replace all <div> tags with <section> tags in the content.
    def replace_elements(input, old_tag, new_tag)
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      doc.css(old_tag).each { |elem| elem.name = new_tag }
      doc.to_html
    end

    # Wraps the specified HTML tag with another tag in the input content.
    #
    # @param input [String] The HTML content to process.
    # @param target_tag [String] The HTML tag to wrap (e.g., "img").
    # @param wrapper_tag [String] The HTML tag to wrap around the target tag (e.g., "figure").
    # @return [String] The content with the target tag wrapped in the wrapper tag.
    #
    # @example Usage in Liquid:
    #   {{ page.content | wrap_element: "img", "figure" }}
    #
    # This will wrap all <img> tags with <figure> tags in the content.
    def wrap_element(input, target_tag, wrapper_tag)
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      doc.css(target_tag).each do |element|
        wrapper = Nokogiri::XML::Node.new(wrapper_tag, doc)
        element.replace(wrapper)
        wrapper.add_child(element)
      end
      doc.to_html
    end

    # Removes all empty HTML elements (elements with no content) from the input content.
    #
    # @param input [String] The HTML content to process.
    # @return [String] The content with all empty elements removed.
    #
    # @example Usage in Liquid:
    #   {{ page.content | remove_empty_elements }}
    #
    # This will remove all HTML tags that do not contain any content.
    def remove_empty_elements(input)
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      doc.css('*:empty').remove
      doc.to_html
    end

    # Removes all occurrences of a specific HTML tag from the input string.
    #
    # @param input [String] The HTML content to process.
    # @param tag [String] The HTML tag to remove (e.g., 'script' or 'style').
    # @return [String] The content with all occurrences of the specified tag removed.
    #
    # @example Usage in Liquid:
    #   {{ page.content | remove_specific_tag: 'script' }}
    #
    # This will remove all <script> tags from the content.
    def remove_specific_tag(input, tag)
      input.gsub(%r{<#{tag}[^>]*>.*?</#{tag}>}m, '')
    end

    # Sanitizes the input HTML by removing unsafe tags (like <script>).
    #
    # @param input [String] The HTML content to sanitize.
    # @return [String] The sanitized content with unsafe elements removed.
    #
    # @example Usage in Liquid:
    #   {{ page.content | sanitize_html }}
    #
    # This will remove unsafe tags like <script> from the content.
    def sanitize_html(input)
      unsafe_tags = %w[script iframe object embed]
      unsafe_tags.each do |tag|
        input = input.gsub(%r{<#{tag}[^>]*>.*?</#{tag}>}m, '')
      end
      input
    end

    # Extracts the first image URL from the HTML input.
    #
    # @param input [String] The HTML content to process.
    # @return [String] The URL of the first image found, or an empty string if no image is found.
    #
    # @example Usage in Liquid:
    #   {{ page.content | extract_first_image }}
    #
    # This will return the URL of the first <img> tag in the content.
    def extract_first_image(input)
      match = input.match(/<img[^>]+src="([^">]+)"/i)
      match ? match[1] : ''
    end

    # Checks if the input matches a given regex pattern.
    #
    # @param input [String] The text content to check.
    # @param pattern [String] The regex pattern to match.
    # @return [Boolean] True if the input matches the pattern, false otherwise.
    #
    # @example Usage in Liquid:
    #   {% if page.content | regex_match: '^Hello' %}
    #     The content starts with "Hello".
    #   {% endif %}
    def regex_match(input, pattern)
      !!(input =~ /#{pattern}/)
    end

    # Captures the part of the input that matches a given regex pattern.
    #
    # @param input [String] The text content to process.
    # @param pattern [String] The regex pattern to match and capture.
    # @return [String] The part of the content that matches the pattern, or an empty string if no match is found.
    #
    # @example Usage in Liquid:
    #   {{ page.content | regex_capture: 'Hello (\w+)' }}
    def regex_capture(input, pattern)
      match = input.match(/#{pattern}/)
      match ? match[1] : ''
    end

    # Replaces text in the input string using a regular expression pattern.
    #
    # @param input [String] The string to modify.
    # @param pattern [String] The regular expression pattern to search for.
    # @param replacement [String] The string that will replace the matched pattern.
    # @return [String] The modified string with the replacements.
    #
    # @example Usage in Liquid:
    #   {{ page.content | replace_regex: "\\d+", "NUMBER" }}
    #
    # This will replace all numeric values in the content with the word "NUMBER".
    def replace_regex(input, pattern, replacement)
      regex = Regexp.new(pattern)
      input.gsub(regex, replacement)
    end

    # Removes all HTML comments from the input string.
    #
    # @param input [String] The HTML content to process.
    # @return [String] The content with all HTML comments removed.
    #
    # @example Usage in Liquid:
    #   {{ page.content | remove_html_comments }}
    #
    # This will remove all HTML comments (<!-- ... -->) from the content.
    def remove_html_comments(input)
      input.gsub(/<!--.*?-->/m, '')
    end

    # Removes all CSS comments from the input string.
    #
    # @param input [String] The CSS content to process.
    # @return [String] The content with all CSS comments removed.
    #
    # @example Usage in Liquid:
    #   {{ page.content | remove_css_comments }}
    #
    # This will remove all CSS comments (/* ... */) from the content.
    def remove_css_comments(input)
      input.gsub(%r{/\*.*?\*/}m, '')
    end

    # Removes all JavaScript comments from the input string.
    #
    # @param input [String] The JavaScript content to process.
    # @return [String] The content with all JavaScript comments removed.
    #
    # @example Usage in Liquid:
    #   {{ page.content | remove_js_comments }}
    #
    # This will remove all JS comments (// ... and /* ... */) from the content.
    def remove_js_comments(input)
      input.gsub(%r{//.*$}, '').gsub(%r{/\*.*?\*/}m, '')
    end

    # Removes all comments (JavaScript, HTML, and CSS) from the input string.
    #
    # @param input [String] The content to process.
    # @return [String] The content with all JavaScript, HTML, and CSS comments removed.
    #
    # @example Usage in Liquid:
    #   {{ page.content | remove_all_comments }}
    #
    # This will remove all comments from JavaScript (// ... and /* ... */), HTML (<!-- ... -->), and CSS (/* ... */).
    def remove_all_comments(input)
      input = input.clone
      # Remove JS single-line (// ...) and multi-line (/* ... */) comments
      input = input.gsub(%r{//.*$}, '').gsub(%r{/\*.*?\*/}m, '')

      # Remove HTML comments (<!-- ... -->)
      input = input.gsub(/<!--.*?-->/m, '')

      # Remove CSS comments (/* ... */)
      input = input.gsub(%r{/\*.*?\*/}m, '')

      input.to_s
    end

    # Strips leading and trailing whitespace from the input and collapses multiple spaces into a single space.
    #
    # @param input [String] The text content to process.
    # @return [String] The content with leading and trailing spaces removed, and multiple spaces collapsed into one.
    #
    # @example Usage in Liquid:
    #   {{ page.title | strip_spaces }}
    #
    # This will remove any leading/trailing spaces and collapse consecutive spaces into one in the title.
    def strip_spaces(input)
      input.strip.gsub(/\s+/, ' ')
    end

    # Converts the input string to title case, where the first letter of each word is capitalized.
    #
    # @param input [String] The text content to convert.
    # @return [String] The content with each word's first letter capitalized.
    #
    # @example Usage in Liquid:
    #   {{ page.title | titlecase }}
    #
    # This will convert the title of the page to title case, where the first letter of each word is capitalized.
    def titlecase(input)
      input.split(' ').map(&:capitalize).join(' ')
    end

    # Encodes the input string into a URL-safe format.
    #
    # @param input [String] The text content to encode.
    # @return [String] The URL-encoded content.
    #
    # @example Usage in Liquid:
    #   {{ page.url | url_encode }}
    #
    # This will convert the URL into a format safe for use in web addresses by encoding special characters.
    def url_encode(input)
      CGI.escape(input)
    end

    # Highlights specified keywords in the given HTML content by wrapping them in <mark> tags.
    #
    # @param input [String] The HTML content to modify.
    # @param keywords [Array<String>] An array of keywords to highlight.
    # @return [String] The modified HTML content with the keywords wrapped in <mark> tags.
    #
    # @example Usage in Liquid:
    #   {{ page.content | highlight_keywords: ["Jekyll", "Markdown"] }}
    #
    # This will wrap the keywords "Jekyll" and "Markdown" in <mark> tags in the content.
    def highlight_keywords(input, keywords)
      doc = Nokogiri::HTML::DocumentFragment.parse(input)
      keywords.each do |keyword|
        doc.xpath('//text()').each do |node|
          next unless node.content.include?(keyword)

          highlighted = node.content.gsub(keyword, "<mark>#{keyword}</mark>")
          node.replace(Nokogiri::XML::Text.new(highlighted, doc))
        end
      end
      doc.to_html
    end

    # Escapes the input string so that it can be safely used in JavaScript code.
    #
    # @param input [String] The content to escape.
    # @return [String] The content with special characters escaped for use in JavaScript.
    #
    # @example Usage in Liquid:
    #   <script>
    #     var content = "{{ page.content | escape_js }}";
    #   </script>
    #
    # This will escape the content so that it can be safely embedded in a JavaScript variable.
    def escape_js(input)
      input.to_json.gsub(/\A"|"\Z/, '')
    end

    # Converts the input to JSON format and ensures that JSON output does not cause
    # XSS (cross-site scripting) issues when inserted into HTML by escaping `<` and `>`.
    #
    # @param input [Object] The content to convert to JSON. This could be an object, array, or string.
    # @return [String] The JSON-encoded content with characters < and > safely escaped.
    #
    # @example Usage in Liquid:
    #   {{ page.data | jsonify_safe }}
    #
    # This will output the JSON representation of `page.data` with < and > escaped to prevent XSS.
    def jsonify_safe(input)
      input.to_json.gsub('<', '\u003c').gsub('>', '\u003e')
    end
  end
end
