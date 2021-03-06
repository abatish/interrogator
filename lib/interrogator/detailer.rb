module Interrogator
  module Detailer

    def self.extended(base)
      base.class_eval{
        class_inheritable_accessor :exposed_methods
        self.exposed_methods ||= []
      }
    end

    def simple_columns_array(options={})
      @interrogator_columns_hash ||= columns_hash
      sort = options[:sort]||true
      excl_columns = options[:except]||[]
      incl_columns = options[:only]||[]
      res=[]
      @interrogator_columns_hash.each { |k, v|
        ks=k.to_sym
        next if excl_columns.include?(ks) || (!incl_columns.empty? && !incl_columns.include?(ks))
        res << {
          :column_name => k,
          :type => v.type,
          :limit => v.limit,
          :null => v.null
        }
      }
      sort ? res.sort{|a,b| a[:column_name] <=> b[:column_name]} : res
    end

    def associated_models_hash
       {}.tap do |hash|
        [:has_many, :has_one, :belongs_to].each do |assoc|
          hash[assoc] = []
          reflect_on_all_associations(assoc).each do |reflection|
            hash[assoc] << {:name => reflection.name, :options => reflection.options.tap{|o| o.delete(:extend)}}
          end
        end
      end
    end

    def expose_methods(*args)
      self.exposed_methods += args
    end

    def traits
      (self.column_names + self.exposed_methods + self.reflections.keys).map(&:to_s).sort
    end

  end
end