module BukExtractI18n

  class FileManager
    REGISTER_FILE_PATH = BukExtractI18n.configuration.processed_files_path
    def self.register!(file_path)
      existing_paths = []

      if File.exist?(REGISTER_FILE_PATH)
        existing_paths = File.readlines(REGISTER_FILE_PATH).map(&:chomp)
      end

      unless existing_paths.include?(file_path)
        File.open(REGISTER_FILE_PATH, "a") do |file|
          file.puts(file_path)
        end
      end
    end

    def self.registered?(file_path)
      return false unless File.exist?(REGISTER_FILE_PATH)

      existing_paths = File.readlines(REGISTER_FILE_PATH).map(&:chomp)
      existing_paths.include?(file_path)
    end
  end
end