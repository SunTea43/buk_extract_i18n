RSpec.describe BukExtractI18n::Adapters::ErbAdapter do
  describe 'plaintext' do
    specify 'normal string' do
      file = <<~DOC
        <p>\nHello World\n</p>
      DOC
      expect(run(file)).to be == [
        "<p>\n<%= I18n.t('models.foo.hello_world') %>\n</p>\n", { 'models.foo.hello_world' => 'Hello World' }
      ]
    end

    specify 'conditionals' do
      file = <<~DOC
        <div>
          <% if a == b %>
            Some Text
          <% end %>
          Other Text
        </div>
      DOC
      expect(run(file)[0]).to be == <<~DOC
        <div>
          <% if a == b %>
            <%= I18n.t('models.foo.some_text') %>
          <% end %>
          <%= I18n.t('models.foo.other_text') %>
        </div>
      DOC
    end
  end

  describe 'attributes' do
    specify 'placeholder' do
      file = <<~DOC
        <div><input placeholder="Some text"></div>
      DOC
      expect(run(file)[0]).to be == <<~DOC
        <div><input placeholder="<%= I18n.t('models.foo.some_text') %>"></div>
      DOC
    end

    specify 'title' do
      file = <<~DOC
        <div><span title="Some text"></span></div>
      DOC
      expect(run(file)[0]).to be == <<~DOC
        <div><span title="<%= I18n.t('models.foo.some_text') %>"></span></div>
      DOC
    end
  end

  describe "ruby strings" do
    specify 'link-to' do
      file = <<~DOC
        <%= link_to "Hello", some_url, title: \'Some title\' %>
      DOC
      expect(run(file)[0]).to be == <<~DOC
        <%= link_to I18n.t('models.foo.hello'), some_url, title: I18n.t('models.foo.some_title') %>
      DOC
    end
    specify 'submit' do
      file = <<~DOC
        <%= some.submit "submit text" %>
        <%= some.label :email, "label text" %>
      DOC
      expect(run(file)[0]).to be == <<~DOC
        <%= some.submit I18n.t('models.foo.submit_text') %>
        <%= some.label :email, I18n.t('models.foo.label_text') %>
      DOC
    end

    specify 'fields' do
      file = <<~DOC
        <%= some.text_area :text, placeholder: "textarea label", class: "some" %>
        <%= some.email_field :email, placeholder: "email", class: "some" %>
      DOC
      expect(run(file)[0]).to be == <<~DOC
        <%= some.text_area :text, placeholder: I18n.t('models.foo.textarea_label'), class: "some" %>
        <%= some.email_field :email, placeholder: I18n.t('models.foo.email'), class: "some" %>
      DOC
    end

    specify 'complex erb' do
      file = <<~DOC
        <%= simple_form_for :bono, method: :post, url: create_defaults_public_sector_items_active_admin_bonos_path, html: {class: 'bg-white'} do |f| %>
          <fieldset class='inputs'>
            <%= f.input :remuneration_system, label: 'Sistema Remuneración', as: :select, collection: remuneration_systems, wrapper_html: {class: 'select input required'} %>
            <div class = 'form-group select input'>
              <%= f.label 'Asignar items', class: 'control-label select required' %>
              <%= f.input :assign_assignable_always, label: false, as: :boolean %>
            </div>
            <fieldset class='actions'>
              <%= f.submit I18n.t('cells.admin.bono_admin.public_sector_defaults.show.crear_items') %>
              <%= link_to I18n.t('cells.admin.bono_admin.public_sector_defaults.show.volver'), active_admin_bonos_path %>
            </fieldset>
          </fieldset>
        <% end %>
      DOC
      expect(run(file)[0]).to be == <<~DOC
        <%= simple_form_for :bono, method: :post, url: create_defaults_public_sector_items_active_admin_bonos_path, html: {class: 'bg-white'} do |f| %>
          <fieldset class='inputs'>
            <%= f.input :remuneration_system, label: 'Sistema Remuneración', as: :select, collection: remuneration_systems, wrapper_html: {class: 'select input required'} %>
            <div class = 'form-group select input'>
              <%= f.label 'Asignar items', class: 'control-label select required' %>
              <%= f.input :assign_assignable_always, label: false, as: :boolean %>
            </div>
            <fieldset class='actions'>
              <%= f.submit I18n.t('cells.admin.bono_admin.public_sector_defaults.show.crear_items') %>
              <%= link_to I18n.t('cells.admin.bono_admin.public_sector_defaults.show.volver'), active_admin_bonos_path %>
            </fieldset>
          </fieldset>
        <% end %>
      DOC
    end
  end
end
