module ValidatesAndFormatsPhones
  DEFAULT_FORMAT = ["###-####", "(###) ###-####", "#-###-###-####"].freeze
  
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end

  def self.extract_formats_and_fields(formats_and_fields)
    options = {:on => :save, :allow_nil => false}
    options.merge!(formats_and_fields.extract_options!)
    formats = DEFAULT_FORMAT
    fields = []
    formats_and_fields.each do |option|
      fields << option.to_sym
    end
    fields<< :phone if fields.empty?
    [formats, fields, options]
  end

  module ClassMethods

    def validates_and_formats_phones(*args)
      formats, fields, options = ValidatesAndFormatsPhones.extract_formats_and_fields(args)

      size_options = formats.collect {|format| format.count '#'}

      validates_each(*fields) do |record, attr, value|
        unless value.blank? || size_options.include?(value.scan(/\d/).size)
          if size_options.size > 1
            message = "must have 7, 10 or 11 digits."
          else
            message = "must have #{size_options[0]} digits."
          end
          record.errors.add attr, message 
        else
          record.format_phone_field(attr, formats)
        end
      end
    end

  end

  module InstanceMethods

    def format_phone_field(field_name, formats = [])
      formats = DEFAULT_FORMAT
      self.send("#{field_name}=", self.send(field_name).to_s.to_phone(formats)) unless send(field_name).blank?
    end
  end
end
