module MxHelper
  def mx_bool_icon(flag, option={})
    if flag
      image_tag('true.png') unless option[:blank_true]
    else
      image_tag('false.png') unless option[:blank_false]
    end
  end

  def mx_label_for(name, options={})
    label_text = l("mx.label_#{name}") + (options.delete(:required) ? content_tag('span', ' *', :class => 'required') : '')
    content_tag('label', label_text.html_safe)
  end

  def mx_image_button(name, options={})
    image_file = "#{name}.png"
    image_tag(image_file, options.reverse_merge(title: l("button_#{name}")).merge(class: 'mx-image-button'))
  end

  def mx_submit(label, options={})
    submit_tag(label, options.merge(disable_with: label))
  end

  def class_for(object, attribute)
    object.errors[attribute.to_sym].present? ? 'mx-error' : ''
  end
end
