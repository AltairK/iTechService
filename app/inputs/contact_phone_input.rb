class ContactPhoneInput < SimpleForm::Inputs::StringInput

  def input
    template.content_tag(:div, class: 'input-append') do
      @builder.input_field(attribute_name, class: 'input-large') +
      template.link_to(template.glyph(:copy), '#', id: 'device_contact_phone_copy', class: 'btn btn-info', title: template.t('devices.edit.copy_client_phone')) +
      template.link_to('None', '#', id: 'device_contact_phone_none', class: 'btn btn-warning')
    end.html_safe
  end

end