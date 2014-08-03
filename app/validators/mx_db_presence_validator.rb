class MxDbPresenceValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    rel = options[:class_name].constantize.where(attribute => value)
    if options[:scope]
      Array.wrap(options[:scope]).each do |attr|
        rel = rel.where(attr => record.send(attr))
      end
    end
    if rel.first && rel.first.id != record.id
      record.errors.add(attribute, :taken)
    end
  end
end