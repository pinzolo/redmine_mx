class MxVm::Base
  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  def persisted?
    false
  end

  def params_with(*attributes)
    Hash[attributes.map { |attribute| [attribute, send(attribute)] }]
  end

  private

  def merge_children_errors!(children, prefix)
    children.each do |child|
      next if child.valid?

      child.errors.each do |field, error|
        add_error_unless_included("#{prefix}_#{field}".to_sym, error)
      end
    end
  end

  def simple_load_values!(object, *attributes)
    if object.is_a?(Hash)
      simple_load_values_from_hash!(object, *attributes)
    else
      simple_load_values_from_object!(object, *attributes)
    end
  end

  def simple_load_values_from_hash!(params, *attributes)
    attributes.each { |attribute| send("#{attribute}=", params[attribute]) }
  end

  def simple_load_values_from_object!(object, *attributes)
    attributes.each { |attribute| send("#{attribute}=", object.send(attribute)) }
  end

  def add_error_unless_included(field, error)
    errors.add(field, error) unless Array.wrap(errors.messages[field]).include?(error)
  end
end
