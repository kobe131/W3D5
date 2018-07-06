class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    # name = ":@#{names.first}"

    names.each do |name|
      define_method(name.to_sym){ instance_variable_get("@#{name}".to_sym)  }

      define_method("#{name}=") do |new_value|
        instance_variable_set("@#{name}".to_sym, new_value)
      end
    end
  end
end
