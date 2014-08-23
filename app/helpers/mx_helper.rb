module MxHelper
  def mx_bool_icon(flag, option = {})
    if flag
      image_tag('true.png') unless option[:blank_true]
    else
      image_tag('false.png') unless option[:blank_false]
    end
  end

  def mx_label_for(name, options = {})
    label_text = l("mx.label_#{name}") + (options.delete(:required) ? content_tag('span', ' *', :class => 'required') : '')
    content_tag('label', label_text.html_safe)
  end

  def mx_image_button(name, options = {})
    image_file = options.delete(:icon) || "#{name}.png"
    image_tag(image_file, options.reverse_merge(title: l("button_#{name}")).merge(class: 'mx-image-button'))
  end

  def mx_submit(label, options = {})
    submit_tag(label, options.merge(disable_with: label))
  end

  def mx_cell_class_for(object, attribute)
    object.errors[attribute.to_sym].present? ? 'mx-error' : ''
  end

  def mx_database_tabs(database, selected_tab)
    content_tag(:div, class: 'tabs') do
      ul = content_tag(:ul) do
        [:tables, :column_sets].each do |symbol|
          link_opts = selected_tab.to_s == symbol.to_s ? { class: 'selected' } : {}
          url_opts = { controller: "mx_#{symbol}".to_sym, action: :index, project_id: database.project, database_id: database }
          link = link_to(l("mx.tab_#{symbol}"), url_for(url_opts), link_opts)
          concat(content_tag(:li, link))
        end
      end
      concat(ul)
    end
  end

  def mx_enumerate_texts_with_wbr(texts)
    texts.map { |text| h(text) }.join(', <wbr/>').html_safe
  end

  def mx_options_from_collection(collection, value_method = :id, text_method = :name, selected = nil)
    content_tag(:option, '', :value => '').safe_concat(options_from_collection_for_select(collection, value_method, text_method, selected)).html_safe
  end
end
