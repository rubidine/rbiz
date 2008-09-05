module Office::CartConfigsHelper
  def config_input form, opt
    if opt.hide_from_user?
      h(opt.value)
    elsif opt.basic_type and opt.basic_type.match(/^bool/i)
      ov = opt.value
      #form.checkbox :value, [['True', 1], ['False', 0]]
      form.check_box  :value
    else
      if opt.value.is_a? Hash
        form.text_area :value, :value => opt.serial_value
      else
        form.text_field :value, :value => opt.value
      end
    end
  end
end
