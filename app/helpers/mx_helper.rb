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
end
