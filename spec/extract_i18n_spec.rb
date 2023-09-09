RSpec.describe ExtractI18n do
  specify 'File key' do
    expect(
      ExtractI18n.file_key("app/models/user.rb")
    ).to be == 'models.user'
  end

  specify 'File key controller' do
    expect(
      ExtractI18n.file_key("app/controllers/services/command.rb")
    ).to be == 'controllers.services.command'
  end

  specify 'File key erb' do
    expect(
      ExtractI18n.file_key("app/cells/employee/form/show.erb")
    ).to be == 'cells.employee.form.show'
  end
end
