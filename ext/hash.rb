class Hash
  def deep_traverse(&block)
    stack = self.map{ |k,v| [ [k], v ] }

    while not stack.empty?
      key, value = stack.pop

      case value
      when Hash
        yield(key.join("/"), nil)
        value.each { |k,v| stack.push [ key.dup << k, v ] }
      when Array
        yield(key.join("/"), nil)
        value.each { |i| stack.push [ key, i ] }
      else
        yield(key.join("/"), value)
      end
    end
  end
end
