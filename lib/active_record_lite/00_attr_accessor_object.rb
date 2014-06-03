class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name|
     # name_equal = (name.to_s + '=')
      name_equal = "#{name}="

      #name_var = ('@' + name.to_s)
      name_var = "@#{name}"
      define_method(name){self.instance_variable_get(name_var)}
      define_method(name_equal){|value| self.instance_variable_set(name_var, value)}
    end

  end
end
