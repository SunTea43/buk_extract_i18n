RSpec.describe ExtractI18n::Adapters::RubyAdapter do
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
end
