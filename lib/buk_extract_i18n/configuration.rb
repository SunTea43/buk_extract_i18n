module BukExtractI18n
  class Configuration

    attr_accessor :use_open_ai, :app_dir, :openai_api_key, :openai_model, :processed_files_path

    def initialize
      @use_open_ai = false
      @app_dir = 'config/locales'
      @openai_api_key = 'open_ai_api_key'
      @openai_model = 'gpt-3.5-turbo'
      @processed_files_path = '.processed_translation_files'
    end
  end
end