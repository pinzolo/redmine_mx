class MxDbPresenceValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    attr = options[:attribute] || attribute
    rel = options[:class_name].constantize.where(attr => value)
    record.errors.add(attribute, :invalid) unless rel.exists?
  end
end
