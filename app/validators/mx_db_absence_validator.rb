class MxDbAbsenceValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    attr = options[:attribute] || attribute
    rel = options[:class_name].constantize.where(attr => value)
    if options[:scope]
      Array.wrap(options[:scope]).each do |att|
        rel = rel.where(att => record.send(att))
      end
    end
    if rel.first && rel.first.id != record.id
      record.errors.add(attribute, :taken)
    end
  end
end

