module MxHelper
  def mx_bool_icon(flag, option={})
    if flag
      image_tag('true.png') unless option[:blank_true]
    else
      image_tag('false.png') unless option[:blank_false]
    end
  end
end
