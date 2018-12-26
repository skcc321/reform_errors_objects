require "reform"
require "reform_errors_objects/version"

module ReformErrorsObjects
  JsonErrorsCollector = ->(form) do
    result = {}
    # get properties errors
    result.merge!(form.instance_variable_get(:@result).errors)

    form.schema.each_pair do |property, definition|
      options = definition.instance_variable_get(:@options)

      if options[:collection] && form.send(property) # ? collection
        result[property.to_sym] = form.send(property).each.with_index.inject({}) { |memo, (obj, index)| memo[index.to_s.to_sym] = JsonErrorsCollector.call(obj); memo }
      elsif options[:nested] && form.send(property) # ? nested
        result[property.to_sym] = JsonErrorsCollector.call(form.send(property))
      end
    end

    result
  end

  def objects
    @objects ||= JsonErrorsCollector.call(@form)
  end
end

Reform::Contract::Result::Errors.include(ReformErrorsObjects)
