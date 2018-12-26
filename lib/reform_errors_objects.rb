require "reform"
require "reform_errors_objects/version"

module ReformErrorsObjects
  JsonErrorsCollector = ->(form) do
    result = {}

    # skip non-form objects
    return result unless form.is_a?(Reform::Form)
    return result unless form.errors.messages.any?

    # get properties errors
    result.merge!(form.instance_variable_get(:@result).errors || {})

    form.schema.each_pair do |property, definition|
      options = definition.instance_variable_get(:@options)

      if options[:collection] && form.send(property) # ? collection
        nested_errors = form.send(property).each.with_index.inject({}) do |memo, (obj, index)|
          nested_errors = JsonErrorsCollector.call(obj)

          memo[index.to_s.to_sym] = nested_errors if nested_errors.any?

          memo
        end

        result[property.to_sym] = nested_errors if nested_errors.any?
      elsif options[:nested] && form.send(property) # ? nested
        nested_errors = JsonErrorsCollector.call(form.send(property))

        result[property.to_sym] = nested_errors if nested_errors.any?
      end
    end

    result
  end

  def objects
    @objects ||= JsonErrorsCollector.call(@form)
  end
end

Reform::Contract::Result::Errors.include(ReformErrorsObjects)
