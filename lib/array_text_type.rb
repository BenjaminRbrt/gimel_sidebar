class ArrayTextType < ActiveRecord::Type::Value
  def cast(value)
    case value
    when String
      JSON.parse(value) rescue []
    when Array
      value
    else
      []
    end
  end

  def serialize(value)
    value.to_json
  end
end
