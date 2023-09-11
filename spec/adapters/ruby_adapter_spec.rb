RSpec.describe BukExtractI18n::Adapters::RubyAdapter do
  def stub_openai_response(*responses)
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .to_return(*responses.map do |response|
        {
          status: 200,
          body: { choices: [ { message: { content: response } } ] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      end)
  end

  specify 'normal string' do
    stub_openai_response("hallo_welt")
    file = <<~DOC
      a = "Hallo Welt"
    DOC
    expect(run(file)).to be == [
      "a = I18n.t(\"models.foo.hallo_welt\")\n", { 'models.foo.hallo_welt' => 'Hallo Welt' }
    ]
  end

  specify 'Heredoc' do
    stub_openai_response("hallo_welt")
    file = <<~DOC
      a = <<~FOO
        Hallo
        Welt
      FOO
    DOC
    expect(run(file)).to be == [
      "a = I18n.t(\"models.foo.hallo_welt\")\n", { 'models.foo.hallo_welt' => "Hallo\nWelt\n" }
    ]
  end

  specify 'String placeholder' do
    stub_openai_response("date_today", "what_date_is_it")
    file = <<~DOC
      a = "What date is it: \#{Date.today}!"
    DOC
    expect(run(file)).to be == [
      "a = I18n.t(\"models.foo.what_date_is_it\", date_today: Date.today)\n", {
        'models.foo.what_date_is_it' => "What date is it: %{date_today}!"
      }
    ]
  end

  specify 'Ignore active record stuff' do
    file = <<~DOC
      has_many :foos, class_name: "FooBar", foreign_key: "foobar"
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore active record functions' do
    file = <<~DOC
      sql = User.where("some SQL Condition is true").order(Arel.sql("Foobar"))
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore regex' do
    file = <<~DOC
      a = /Hallo Welt/
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore active record stuff' do
    file = <<~DOC
      has_many :foos, class_name: "FooBar", foreign_key: "foobar"
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore already translation' do
    file = <<~DOC
      flash[:notice] = t('jobs.create.recovered')
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore anchor' do
    file = <<~DOC
      redirect_to employee_path(job_params_with_contractual_attrs[:employee_id], anchor: 'timeline')
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore conditions' do
    file = <<~DOC
      current_user.country == 'chile'
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore hash reference' do
    file = <<~DOC
      employee_country = Employee.find_by(id: params["job"]["employee_id"])&.country_namespace
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore complex hash reference' do
    file = <<~DOC
      values['c'][0]['p']
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore on interpolation' do
    file = <<~DOC
      form_prefix = "\#{param_key.first}[\#{param_key.last}]"
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore empty tags' do
    file = <<~DOC
      return render(html: '<div></div>'.html_safe, layout: false) if sistema_remuneracion.blank?
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore empty strings' do
    file = <<~DOC
      return render(html: '', layout: false) if sistema_remuneracion.blank?
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore without words' do
    file = <<~DOC
      @employee_ids = params[:employee_ids].split(',')
      mensaje_inicial += step_info[:mensaje_inicial] + ", "
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore logger' do
    file = <<~DOC
      Rails.logger.info "Error formato(Procesos): mime:\#{export.mime}, titulo:\#{filename}"
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore slice' do
    file = <<~DOC
      filename_hash = filtered_log.slice("filename")
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore get_files_history' do
    file = <<~DOC
      @download_history = get_files_history("descarga")
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore strftime' do
    file = <<~DOC
      {:date => Time.zone.parse(log["date"]).strftime("%d/%m/%Y-%H:%M")}
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore date format' do
    file = <<~DOC
      {format: "%B %Y"}
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore complex format' do
    file = <<~DOC
      "\#{name} \#{l(@variable.start_date, format: "%B %Y").capitalize}\#{export.extension}"
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore profile block' do
    file = <<~DOC
      @employees = Buk::Profile.block('tabla')
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore address_error_message' do
    file = <<~DOC
      error_message = address_error_message error, 'crear'
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore initializer' do
    file = <<~DOC
      raise AbstractController::ActionNotFound.new('Not Found') unless General.doble_trabajo
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore extensions' do
    file = <<~DOC
      employee_query = { people: Person.where_rut(employee_company_params[:identifier].delete('.pdf'))}
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore dig' do
    file = <<~DOC
      value = values.dig('c', 0, 'v', 0)
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore find_by' do
    file = <<~DOC
      Model.find_by(section: :employee, name: 'Vigentes', user_id: nil)
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore cancancan load' do
    file = <<~DOC
      load_and_authorize_resource class: 'ParameterTable'
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore .not' do
    file = <<~DOC
      Model.order(:nombre).where.not("nombre = ? AND tipo = ?", NON_USABLE_ACCOUNTS[0], CuentaContable.tipos[:general])
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore .starts_with?' do
    file = <<~DOC
      query.starts_with?('en:') && query.split(' ')
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore .include?' do
    file = <<~DOC
      query.select{ |q| q.include?("en:\#{group}") }.any?
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore .eql?' do
    file = <<~DOC
      action_name.eql? 'update'
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore load_and_authorize_resource?' do
    file = <<~DOC
      load_and_authorize_resource instance_name: 'sobretiempo', class: 'Sobretiempo', only: [:approve, :reject]
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore load_and_authorize_resource?' do
    file = <<~DOC
      send_data file.contenido, filename: file_name + ".xls", type: "application/vnd.ms-excel"
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore country_namespace' do
    file = <<~DOC
      {country_namespace: "colombia"}
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore table_id' do
    file = <<~DOC
      {table_id: "multi-select-employee"}
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore include?' do
    file = <<~DOC
      Object.include?("employees")
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end

  specify 'Ignore error logger' do
    file = <<~DOC
      Rails.logger.error "Document Signature request failed"
    DOC
    expect(run(file)).to be == [
      file, {}
    ]
  end
end
