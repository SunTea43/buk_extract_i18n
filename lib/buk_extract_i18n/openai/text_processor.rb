module BukExtractI18n::Openai
  class TextProcessor
    def initialize
      @connector = Connector.new
    end

    def key_summary(text)
      # experimental
      prompt = "Provide only one suitable and descriptive i18n key (example: instructions_alert) based on the phrase: #{text}"
      result = @connector.request(prompt)
      transform_to_key(result)
    end

    def should_internationalized?(snippet)
      # experimental
      prompt = "Given the Ruby on Rails code snippet, determine if the text is intended for the end user and if it's already internationalized or if it needs to be. Answer only with 'yes', 'no', or 'indeterminate': #{snippet}"
      result = @connector.request(prompt)
      interpret_response(result)
    end

    private

    def transform_to_key(summary)
      summary.strip.
        unicode_normalize(:nfkd).gsub(/(\p{Letter})\p{Mark}+/, '\\1').
        gsub(/\W+/, '_').
        gsub(/_+$|^_+/, '')
    end

    def interpret_response(response_content)
      case response_content.downcase
      when "yes"
        :yes
      when "no"
        :no
      else
        :indeterminate
      end
    end
  end
end