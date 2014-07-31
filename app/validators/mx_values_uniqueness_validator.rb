class MxValuesUniquenessValidator < ActiveModel::Validator

  def validate(record)
    values = record.send(options[:collection])
    if options[:attribute]
      Array.wrap(options[:attribute]).each do |attr|
        values = values.map(&attr.to_sym)
      end
    end
    if values.size != values.uniq.size
      field = options[:field] || :base
      message = options[:message] || I18n.t('activerecord.errors.messages.duplicated')
      record.errors.add(field, message)
    end
  end
end

