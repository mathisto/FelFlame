class FelFlame
  class Helper
    class BaseComponent
      class <<self
        def signature
          @signature ||= FelFlame::Signature.create_new_signature\
            FelFlame::Helper::ComponentHelper.underscore(ancestors[0].name.split('::').last)
        end

        def data
          @data ||= []
        end

        def new(**opts)
          new_component = super

          # Generate ID
          new_id = self.data.find_index { |i| i.nil? }
          new_id = self.data.size if new_id.nil?
          new_component.id = new_id

          # Fill params
          opts.each do |key, value|
            new_component.send "#{key}=", value
          end

          # Save Component
          data[new_id] = new_component
        end

        #def add(entity_id)
        #  data[entity_id] = new
        #end

        #def delete(entity_id)
        #  data.delete entity_id
        #end
      end

      def set(**opts)
        opts.each do |key, value|
          send "#{key}=", value
        end
      end

      #def create_data(name, default = nil)
      #  #TODO: fill this out
      #end

      def get #TODO: maybe optimize removing the @ symbol
        instance_variables.each_with_object({}) do |key, final|
          final[key.to_s.delete_prefix('@').to_sym] = instance_variable_get(key)
        end
      end

      def dump #TODO: Needs to get id and stuff?
        # should return a json or hash of all data in this component
      end
    end

    class Level < FelFlame::Helper::BaseComponent
      class <<self
        def data
          @data ||= { add: [], remove: [], grid: FelFlame::Helper::Array2D.new }
        end

        def add(entity_id)
          super
          data[:add].push entity_id
        end

        def remove(entity_id)
          data[:remove].push entity_id
          super
        end
      end
    end

    class Array2D < Array
      def [](val)
        unless val.nil?
          return self[val] = [] if super.nil?
        end
        super
      end
    end

    class ArrayOfHashes < Array
      def [](val)
        unless val.nil?
          return self[val] = {} if super.nil?
        end
        super
      end
    end

    module ComponentHelper
      class <<self
        def up? char
          char == char.upcase
        end

        def down? char
          char == char.downcase
        end

        def underscore(input)
          output = input[0].downcase
          (1...(input.length - 1)).each do |iter|
            if down?(input[iter]) && up?(input[iter + 1])
              output += "#{input[iter].downcase}_"
            elsif up?(input[iter - 1]) && up?(input[iter]) && down?(input[iter + 1])
              output += "_#{input[iter].downcase}"
            else
              output += input[iter].downcase
            end
          end
          output += input[-1].downcase unless input.length == 1
          output
        end
      end
    end
  end
end
