# frozen_string_literal: true

# Copyright 2018 Tristan Robert

# This file is part of ForemanFogProxmox.

# ForemanFogProxmox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# ForemanFogProxmox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ForemanFogProxmox. If not, see <http://www.gnu.org/licenses/>.

module ProxmoxFormHelper
  def password_proxmox_f(f, attr, options = {})
    unset_button = options.delete(:unset)
    value = f.object[attr] if options.delete(:keep_value)
    password_field_tag(:fakepassword, value, :style => 'display: none', :autocomplete => 'new-password-fake') +
      field(f, attr, options) do
        options[:autocomplete]   ||= 'new-password'
        options[:placeholder]    ||= password_proxmox_placeholder(f.object, attr)
        options[:disabled] = true if unset_button
        options[:value] = value if value.present?
        addClass options, 'form-control'
        pass = f.password_field(attr, options) +
               tag(:span, '', class: 'glyphicon glyphicon-warning-sign input-addon', title: 'Caps lock ON', style: 'display:none')
        if unset_button
          button = link_to_function(icon_text('edit', '', :kind => 'pficon'), 'toggle_input_group(this)', :id => 'disable-pass-btn', :class => 'btn btn-default', :title => _('Change the password'))
          input_group(pass, input_group_btn(button))
        else
          pass
        end
      end
  end

  def password_proxmox_placeholder(obj, attr = nil)
    pass = obj.attributes.key?(attr)
    pass ? '********' : ''
  end

  def new_child_fields_template_typed(form_builder, association, options = {})
    if options[:object].blank?
      association_object = form_builder.object.class.reflect_on_association(association)
      options[:object] = association_object.klass.new(association_object.foreign_key => form_builder.object.id)
    end
    options[:partial]            ||= association.to_s.singularize
    options[:form_builder_local] ||= :f
    options[:form_builder_attrs] ||= {}

    content_tag(:div, :class => "#{options[:type]}_#{association}_fields_template form_template", :style => 'display: none;') do
      form_builder.fields_for(association, options[:object], :child_index => "new_#{options[:type]}_#{association}") do |f|
        render(:partial => options[:partial], :layout => options[:layout],
               :locals => { options[:form_builder_local] => f }.merge(options[:form_builder_attrs]))
      end
    end
  end

  def add_child_link_typed(name, association, type, opts = {})
    opts[:class] = [opts[:class], 'add_nested_fields btn btn-primary'].compact.join(' ')
    opts[:"data-association"] = (type + '_' + association.to_s).to_sym
    hide = ''
    hide += '$("[data-association=' + type + '_volumes]").hide();' unless ['hard_disk', 'mp'].include?(type)
    link_to_function(name.to_s, 'add_child_node(this);' + hide, opts)
  end

  def remove_child_link_typed(name, f, type, opts = {})
    opts[:class] = [opts[:class], 'remove_nested_fields'].compact.join(' ')
    hide = ''
    hide += '$("[data-association=' + type + '_volumes]").show();' unless ['hard_disk', 'mp'].include?(type)
    f.hidden_field(opts[:method] || :_destroy) + link_to_function(name, 'remove_child_node(this);' + hide, opts)
  end
end
