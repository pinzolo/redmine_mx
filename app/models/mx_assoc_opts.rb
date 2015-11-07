module MxAssocOpts
  extend ActiveSupport::Concern

  module ClassMethods
    def assoc_opts(options)
      if Gem::Version.new(Rails.version) > Gem::Version.new('4.0.0')
        order_option = options.delete(:order)
        include_option = options.delete(:include)
        if order_option && include_option
          [Proc.new { order(order_option).includes(include_option) }, options]
        elsif order_option
          [Proc.new { order(order_option) }, options]
        elsif include_option
          [Proc.new { includes(include_option) }, options]
        else
          [options]
        end
      else
        [options]
      end
    end
  end
end
