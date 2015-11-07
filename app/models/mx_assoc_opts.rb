module MxAssocOpts
  extend ActiveSupport::Concern

  module ClassMethods
    def assoc_opts(params)
      if Gem::Version.new(Rails.version) > Gem::Version.new('4.0.0')
        order_param = params.delete(:order)
        include_param = params.delete(:include)
        if order_param && include_param
          [Proc.new { order(order_param).includes(include_param) }, params]
        elsif order_param
          [Proc.new { order(order_param) }, params]
        elsif include_param
          [Proc.new { includes(include_param) }, params]
        else
          [params]
        end
      else
        [params]
      end
    end
  end
end
