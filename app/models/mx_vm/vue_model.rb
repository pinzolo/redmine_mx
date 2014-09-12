module MxVm::VueModel
  extend ActiveSupport::Concern

  included do
    __send__(:include, ActiveModel::Conversion)
    __send__(:include, ActiveModel::Validations)
    __send__(:include, ActiveModel::Serializers::JSON)
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    class << self
      alias_method_chain :i18n_scope, :mx_vm
    end
    __send__(:def_attr, :id)
  end

  module ClassMethods
    def defined_attributes
      @defined_attributes
    end

    def i18n_scope_with_mx_vm
      :mx_vm
    end

    private

    def def_attr(*syms)
      @defined_attributes ||= []
      @defined_attributes += Array.wrap(syms)
      attr_accessor(*syms)
    end
  end

  def persisted?
    false
  end

  def params_with(*attributes)
    Hash[attributes.map { |attribute| [attribute, send(attribute)] }]
  end

  def attributes
    if self.class.defined_attributes
      Hash[self.class.defined_attributes.map { |attr| [attr, nil] }]
    else
      {}
    end
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

