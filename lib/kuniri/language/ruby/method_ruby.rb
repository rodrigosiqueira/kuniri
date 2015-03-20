require_relative '../abstract_container/method'
require_relative '../container_data/method_data'
require_relative '../../util/html_logger'

module Languages

  module Ruby

    # Handling ruby method
    class MethodRuby < Languages::Method

      public

        def initialize
          @log = Util::HtmlLogger.new
        end

        def get_function(pLine)
          result = detect_method(pLine)
          return nil unless result

          @log.write_log("Info: get method")

          methodRuby = Languages::MethodData.new(result)

          parameters = handling_parameter(pLine)
          if parameters
            parameters.each do |parameter|
              methodRuby.add_parameters(parameter)
            end
          end

          @log.write_log("Debug: Method: #{methodRuby.name}, Parameter:
                         #{methodRuby.parameters}")

          return methodRuby
        end

      protected

        def detect_function(pLine)
          regexExpression = /^\s*def\b\s*(\w*)\b/
          return nil unless pLine =~ regexExpression
          return pLine.scan(regexExpression)[0].join("")
        end

        def remove_unnecessary_information(pLine)
          if pLine =~ /\s+|\(|\)/
            return pLine.gsub(/\s+|\(|\)/,"")
          end
          return pLine
        end

        def handling_default_parameter(pLine)
          return pLine unless pLine =~ /=/

          if pLine =~ /,/
            partialParameters = pLine.split(",")
          else
            partialParameters = [pLine]
          end

          newList = []
          partialParameters.each do |element|
            if element =~ /=/
              parameter = element.scan(/(\w*)=/).join("")
              value = element.scan(/=(\w*)/).join("")
              defaultParameter = Hash(parameter => value)
              newList.push(defaultParameter)
              next
            end
            newList.push(element)
          end

          return newList

        end

        def handling_parameter(pLine)
          return nil unless pLine =~ /\(.+\)/

          partialParameters = pLine.scan(/\((.+)\)/).join("")
          partialParameters = remove_unnecessary_information(partialParameters)

          if partialParameters =~ /=/
            return handling_default_parameter(partialParameters)
          end

          return split_string_by_comma(partialParameters)
        end

      private

        @log

        def split_string_by_comma(pString)
          return pString.split(",") if pString =~ /,/
          return [pString]
        end

    # Class
    end

  # Ruby
  end

# Language
end
