# frozen_string_literal: true

# rubocop:disable Lint/InterpolationCheck
RSpec.describe BukExtractI18n::FileProcessor do
  around(:each) do |ex|
    pwd = Dir.pwd
    Dir.mktmpdir do |dir|
      @dir = dir
      Dir.chdir(@dir)
      ex.run
    end
  ensure
    Dir.chdir(pwd)
  end

  before(:each) do
    allow_any_instance_of(TTY::Prompt).to receive(:yes?).and_return(true)
    allow_any_instance_of(TTY::Prompt).to receive(:no?).and_return(false)
    allow_any_instance_of(BukExtractI18n::FileProcessor).to receive(:puts)
  end

  let(:yml) { 'config/locales/models/foobar/es.yml' }
  specify 'integration test' do
    create_file_with_layout(
      'app/models/foobar.rb' => 'a = "Hello #{Date.today}!"' + "\n"
    )
    processor = BukExtractI18n::FileProcessor.new(file_path: 'app/models/foobar.rb', locale: 'es')
    processor.run

    expect(
      File.read(yml)
    ).to be == <<~DOC
      ---
      es:
        models:
          foobar:
            hello: Hello %{date_today}!
    DOC

    expect(
      File.read('app/models/foobar.rb')
    ).to be == <<~DOC
      a = I18n.t(\"models.foobar.hello\", date_today: Date.today)
    DOC
  end

  def create_file_with_layout(hash)
    hash.each do |k, v|
      FileUtils.mkdir_p File.dirname(k)
      File.write(k, v)
    end
  end
end
