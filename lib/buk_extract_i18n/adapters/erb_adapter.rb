module BukExtractI18n::Adapters
  class ErbAdapter < Adapter
    def run(original_content)
      unless valid_erb?(original_content)
        puts "ERB invalid!"
        return original_content
      end
      document = BukExtractI18n::HTMLExtractor::ErbDocument.parse_string(original_content)
      nodes_to_translate = BukExtractI18n::HTMLExtractor::Match::Finder.new(document).matches
      nodes_to_translate.each { |node|
        next if node.text == ""

        process_change(node)
      }
      result = document.save

      result
    end

    def valid_erb?(content)
      Parser::CurrentRuby.parse(ERB.new(content).src)
      true
    rescue StandardError => e
      warn e.inspect
      false
    end

    def process_change(node)
      change = BukExtractI18n::SourceChange.new(
        i18n_key: "#{@file_key}.#{BukExtractI18n.key(node.text.strip)}",
        i18n_string: node.text,
        interpolate_arguments: {},
        source_line: node.to_s,
        remove: node.text,
        t_template: %{ I18n.t('%s') },
        interpolation_type: :ruby
      )
      if @on_ask.call(change)
        node.replace_text!(change.key, change.i18n_t)
      end
    end
  end
end
