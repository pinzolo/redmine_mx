class MxDbPresenceValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    rel = options[:class_name].constantize.where(attribute => value)
    if options[:scope]
      Array.wrap(options[:scope]).each do |attr|
        rel = rel.where(attr => record.send(attr))
      end
    end
    rel = rel.where(id: record.id) if record.respond_to?(:id) && record.id
    record.errors.add(attribute, I18n.t('activerecord.errors.messages.taken')) if rel.exists?
  end
end
