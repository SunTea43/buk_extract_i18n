require 'erb_lint/processed_source'
require 'erb_lint/linter'
require 'better_html'
require 'better_html/parser'
require 'better_html/tree/tag'
class BetterHtml::AST::Node
  def text
    loc.source
  end
  def replace_text!(key, i18n_t)
    new_text = self.loc.source.gsub(text, "@@=#{key}@@")
    children = [new_text]
    self.updated(self.type,[new_text])
  end
end
module BukExtractI18n::Adapters
  class ErbAdapter < Adapter
    NON_TEXT_TAGS = Set.new(["script", "style", "xmp", "iframe", "noembed", "noframes", "listing", "code"])
    NO_TRANSLATION_NEEDED = Set.new([
      "&nbsp;",
      "&amp;",
      "&lt;",
      "&gt;",
      "&quot;",
      "&copy;",
      "&reg;",
      "&trade;",
      "&hellip;",
      "&mdash;",
      "&bull;",
      "&ldquo;",
      "&rdquo;",
      "&lsquo;",
      "&rsquo;",
      "&larr;",
      "&rarr;",
      "&darr;",
      "&uarr;",
      "&ensp;",
      "&emsp;",
      "&thinsp;",
      "&times;",
    ])
    FORMULAS_WORDS = Set.new(["THEN", "WHERE", "WHEN", "END", "CASE", "TRUE", "FALSE"])
    IGNORABLE_REGEXP = [
      /\{{2}.*\}{2}/, # Variables de plantillas
    ].freeze
    def run(original_content)
      unless valid_erb?(original_content)
        puts "ERB invalid!"
        return original_content
      end
      document = BukExtractI18n::HTMLExtractor::ErbDocument.parse_string(original_content)
      processed_source = ERBLint::ProcessedSource.new(file_path,original_content)
      hardcoded_strings = processed_source.ast.descendants(:text).each_with_object([]) do |text_node, to_check|
        next if non_text_tag?(processed_source, text_node)
        offended_strings = text_node.to_a.select { |node| relevant_node(node) }
        offended_strings.each do |offended_string|
          offended_string.split("\n").each do |str|
            to_check << [text_node, str] if check_string?(str)
          end
        end
      end
      hardcoded_strings.compact.each do |text_node, offended_str|
        range = find_range(text_node, offended_str)
        source_range = processed_source.to_source_range(range)
        process_change(text_node)
      end
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
        source_line: node.text.strip,
        remove: node.text,
        t_template: %{ I18n.t('%s') },
        interpolation_type: :ruby
      )
      if @on_ask.call(change)
        node.replace_text!(change.key, change.i18n_t)
      end
    end
    private
    def check_string?(str)
      string = str.gsub(/\s*/, "")
      return false if contains_formula_reserved_words?(string)
      return false if contains_expresions_to_ignore?(string)
      string.length > 1 && !NO_TRANSLATION_NEEDED.include?(string)
    end
    def contains_formula_reserved_words?(string)
      FORMULAS_WORDS.each do |word|
        return true if string.include?(word)
      end
      false
    end
    def contains_expresions_to_ignore?(string)
      IGNORABLE_REGEXP.each do |regexp|
        return true if string.match?(regexp)
      end
      false
    end
    def relevant_node(inner_node)
      if inner_node.is_a?(String) && !inner_node.strip.empty? && !inner_node.include?("@")
        return inner_node
      end
      false
    end
    def non_text_tag?(processed_source, text_node)
      ast = processed_source.parser.ast.to_a
      index = ast.find_index(text_node)
  
      previous_node = ast[index - 1]
  
      if previous_node.type == :tag
        tag = BetterHtml::Tree::Tag.from_node(previous_node)
  
        NON_TEXT_TAGS.include?(tag.name) && !tag.closing?
      end
    end
    def find_range(node, str)
      match = node.loc.source.match(Regexp.new(Regexp.quote(str.strip)))
      return unless match

      range_begin = match.begin(0) + node.loc.begin_pos
      range_end   = match.end(0) + node.loc.begin_pos
      (range_begin...range_end)
    end
  end
end
