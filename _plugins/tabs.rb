# _plugins/tabs_tag.rb

module Jekyll
  class TabsBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @tabs = [] # Array untuk menyimpan tab judul dan konten
    end

    def render(context)
      # Menyimpan instance tabs block ke dalam konteks
      context.registers[:tabs] = self

      # Ambil semua konten di dalam blok dan hapus whitespace
      # Proses konten untuk memisahkan tab dari konten
      process_content(super.strip)

      tabs_id = "tabs-#{rand(999..9999)}" # ID unik untuk tab
      results = @tabs.map.with_index { |v, i| render_tabs(v[:title], v[:content], tabs_id, i) }.join

      # Buat markup untuk header tab dan konten
      "<div class=\"tabs\" id=\"#{tabs_id}\">#{results}</div>"
    end

    # Fungsi untuk menghasilkan markup header tab
    def render_tabs(title, panel, ids, idx)
      checked = ('checked' if idx.zero?)
      <<~HTML
        <input id="#{ids}__tab#{idx}" name="#{ids}-tabs" #{checked} class="tab-input" type="radio">
        <label for="#{ids}__tab#{idx}" class="tab-label">#{title}</label>
        <div id="#{ids}__panel#{idx}" class="tab-panel">#{panel}</div>
      HTML
    end

    # Metode untuk menambahkan tab
    def add_tab(title, content)
      @tabs << { title: title, content: content.strip } # Tambahkan tab ke array
    end

    # Proses konten untuk memisahkan judul dan konten dari masing-masing tab
    def process_content(input)
      # Memisahkan konten berdasarkan tag {% tab %}
      input.scan(/\{% tab "([^"]+)" %\}([^%]+)\{% endtab %\}/m).each do |match|
        title, tab_content = match.map(&:strip) # Menghapus spasi
        add_tab(title, tab_content) # Tambahkan tab menggunakan metode add_tab
      end
    end
  end

  class TabTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @tab_title = markup.strip.gsub(/"/, '') # Ambil judul dari markup
    end

    def render(context)
      return unless context.registers[:tabs]

      # Akses konteks dari TabsBlock dan tambahkan tab
      context.registers[:tabs].add_tab(@tab_title, super.strip)
    end
  end
end

# Daftarkan tag tabs dan tab
Liquid::Template.register_tag('tabs', Jekyll::TabsBlock)
Liquid::Template.register_tag('tab', Jekyll::TabTag)
