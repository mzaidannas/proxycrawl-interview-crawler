class Hash
  # Recursively remove nil items from Hash
  def deep_compact
    each_with_object(self.class.new) do |(key, value), new_hash|
      unless value.nil?
        new_hash[key] = value.is_a?(Hash) ? value.deep_compact : value
      end
      new_hash
    end
  end

  def deep_clean
    each_with_object(self.class.new) do |(key, value), new_hash|
      unless value.blank?
        new_hash[key] = value.is_a?(Hash) ? value.deep_compact : value
      end
      new_hash
    end
  end

  def clean
    select { |_, value| !value.blank? }
  end
end
