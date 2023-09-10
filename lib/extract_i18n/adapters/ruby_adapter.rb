# frozen_string_literal: true

require 'parser/current'
require 'tty-prompt'
require 'pry'
require 'pastel'
require 'yaml'
require 'extract_i18n/source_change'

module ExtractI18n::Adapters
  class RubyAdapter < Adapter
    def run(original_content)
      buffer        = Parser::Source::Buffer.new('(example)')
      buffer.source = original_content
      temp = Parser::CurrentRuby.parse(original_content)
      rewriter = ExtractI18n::Adapters::Rewriter.new(
        file_key: file_key,
        on_ask: on_ask
      )
      # Rewrite the AST, returns a String with the new form.
      rewriter.rewrite(buffer, temp)
      # rescue StandardError => e
      #   puts 'Parsing error'
      #   puts e.inspect
    end
  end

  class Rewriter < Parser::TreeRewriter
    PROMPT = TTY::Prompt.new
    PASTEL = Pastel.new

    def initialize(file_key:, on_ask:)
      @file_key = file_key
      @on_ask = on_ask
    end

    def process(node)
      @nesting ||= []
      @nesting.push(node)
      super
      @nesting.pop
    end

    def on_dstr(node)
      return if ignore?(node, parent: @nesting[-2])
      return if node.children.all? { |child| child.type == :begin }
      # Si todos los hijos del tipo :str contienen solo símbolos, ignoramos el nodo
      if node.children.all? { |child| child.type != :str || child.children[0].match?(/\A[[:punct:]]+\z/) }
        return
      end
      interpolate_arguments = {}
      out_string = ""
      node.children.each do |i|
        if i.type == :str
          out_string += i.children.first
        else
          inner_source = i.children[0].loc.expression.source.gsub(/^#\{|}$/, '')
          interpolate_key = ExtractI18n.key(inner_source)
          out_string += "%{#{interpolate_key}}"
          interpolate_arguments[interpolate_key] = inner_source
        end
      end

      i18n_key = ExtractI18n.key(node.children.select { |i| i.type == :str }.map { |i| i.children[0] }.join(' '))

      ask_and_continue(
        i18n_key: i18n_key, i18n_string: out_string, interpolate_arguments: interpolate_arguments, node: node,
      )
    end

    def on_str(node)
      string = node.children.first

      # Ignorar si es una operación ==
      parent_node = @nesting[-2]
      if parent_node && parent_node.type == :send && parent_node.children[1] == :==
        return
      end

      # Ignorar si el nodo es usado como un índice de un hash
      if parent_node && parent_node.type == :send && parent_node.children[1] == :[] && parent_node.children[2] == node
        return
      end

      string = node.children.first
      # Ignorar si la cadena contiene solo etiquetas HTML sin contenido
      return if string.match?(/\A\s*<\w+>\s*<\/\w+>\s*\z/)
      # Ignorar si la cadena contiene un string vacío
      return if string.empty?
      # Ignora strings que no contienen caracteres de palabra
      return unless string =~ /\w/
      # Ignora strings que no contienen al menos una letra
      return unless string =~ /[a-zA-Z]/

      # Resto de las comprobaciones
      return if ignore?(node) || ignore_parent?(@nesting[-2])

      ask_and_continue(i18n_key: ExtractI18n.key(string), i18n_string: string, node: node)
    end


    private

    def ask_and_continue(i18n_key:, i18n_string:, interpolate_arguments: {}, node:)
      change = ExtractI18n::SourceChange.new(
        i18n_key: "#{@file_key}.#{i18n_key}",
        i18n_string: i18n_string,
        interpolate_arguments: interpolate_arguments,
        source_line: node.location.expression.source_line,
        remove: node.loc.expression.source
      )
      if @on_ask.call(change)
        replace_content(node, change.i18n_t)
      end
    end

    def log(string)
      puts string
    end

    def replace_content(node, content)
      if node.loc.is_a?(Parser::Source::Map::Heredoc)
        replace(node.loc.expression.join(node.loc.heredoc_end), content)
      else
        replace(node.loc.expression, content)
      end
    end

    def ignore?(node, parent: nil)
      unless node.respond_to?(:children)
        return false
      end
      if parent && ignore_parent?(parent)
        return true
      end
      if node.type == :str
        ExtractI18n.ignorelist.any? { |item| node.children[0][item] }
      else
        node.children.any? { |child|
          ignore?(child)
        }
      end
    end

    def ignore_parent?(node)
      node.children[1] == :require ||
        node.type == :regexp ||
        (node.type == :pair && ExtractI18n.ignore_hash_keys.include?(node.children[0].children[0].to_s)) ||
        (node.type == :send && ExtractI18n.ignore_functions.include?(node.children[1].to_s)) ||
        (node.type == :send && node.children[1] == :info && node.children[0].type == :send && node.children[0].children[1] == :logger) ||
        (node.type == :send && node.children[1] == :info && node.children[0].type == :const && node.children[0].children[1] == :Rails)
    end
  end
end
