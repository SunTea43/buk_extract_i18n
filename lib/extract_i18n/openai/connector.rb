require 'json'
require 'openai'

module ExtractI18n::Openai
  class Connector
    def request(prompt)
      client = OpenAI::Client.new(access_token: ExtractI18n.configuration.openai_api_key)
      response = client.chat(
        parameters: {
          model: ExtractI18n.configuration.openai_model,
          messages: [{ role: "user", content: prompt}],
          temperature: 0.7,
        })
      response.dig("choices", 0, "message", "content")
    end
  end
end