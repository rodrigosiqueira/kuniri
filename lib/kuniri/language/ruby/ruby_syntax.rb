require_relative 'ruby_syntax_support'
require_relative 'token_ruby'
require_relative '../language'
require_relative '../container_data/class_data'

module Languages

  def remove_me(a, b)
    puts "xpto"
  end

  # Handling the ruby syntax for extract information.
  class RubySyntax < Languages::Language

    public

      def clear_data
        @rubySyntaxSupport = Languages::RubySyntaxSupport.new
        #You have to make it more generic, for the situation of many class.
        @currentClass = Languages::ClassData.new
        @classes = []
        @visibility = "public"
        @class_token = 0
        @token = 0
        @attributeList = []
        @externRequirements = []
        @functionList = []
      end

      def analyse_source(pPath)
        @name = File.basename(pPath, ".*")
        @path = File.dirname(pPath)
        analyse_first_step(pPath)
        #self.analyse_second_step
      end

      # Extract all the comments from the source.
      # @param source [String] Source code to analys.
      def comment_extract
        all_comments = Array.new
        #Find a simple Ruby comment with '#'
        @source.scan(/#(.*)/).each do |comments|
          all_comments.push(comments[0])
        end
        #Find multiple line comment.
        @source.scan(/^=begin(.*?)^=end/m).each do |comment|
          all_comments.push(comment[0].lstrip)
        end
        return all_comments
      end

      # Extract all method from the source.
      # @param source [String]
      def method_extract
        return @currentClass.get_methods
      end

      # Extract all the class declared in the source.
      # @param source [String]
      def class_extract
        return @currentClass
      end

      # @param source [String]
      def attribute_extract
        return @currentClass.get_attributes
      end

      # @param source [String]
      def global_variable_extract
        raise NotImplementedError
      end

      def extern_requirement_extract
        return @externRequirements
      end

      def dumpData
        puts "=" * 30
        puts @currentClass.dumpClassData
        puts "_" * 30
        puts extern_requirement_extract
        puts "-" * 30
        puts @functionList
        puts "-" * 30
        puts @token
      end

    private

      @class_token
      @token
      @rubySyntaxSupport
      @classes
      @currentClass
      @functionList
      attr_accessor :visibility
      @source
      @attributeList
      @externRequirements

      def analyse_first_step(path)
        @source = File.open(path, "rb")
        @source.each do |line|
          tokenType = @rubySyntaxSupport.get_token_type(line)
          if tokenType == Languages::Ruby::CLASS_TOKEN || @class_token > 0
            tokenType = @rubySyntaxSupport.get_token_type(line, true)
            handle_class(tokenType, line)
          else
            handle_nonclass(tokenType, line)
          end
        end
      end

      def handle_class(tokenType, line)
        case tokenType
          when Languages::Ruby::CLASS_TOKEN
            save_class(line)
            @class_token = @class_token + 1
            @token = @token + 1
          when Languages::Ruby::ATTRIBUTE_TOKEN
            save_attribute(line)
          when Languages::Ruby::DEF_TOKEN
            save_method(line)
            @token = @token + 1
          when Languages::Ruby::END_TOKEN
            @token = @token - 1
          when Languages::Ruby::VISIBILITY_TOKEN
            update_visibility(line)
          when Languages::Ruby::BEGIN_TOKEN
            @token = @token + 1
          when Languages::Ruby::CASE_TOKEN
            @token = @token + 1
          when Languages::Ruby::DO_TOKEN
            @token = @token + 1
          when Languages::Ruby::IF_TOKEN
            @token = @token + 1
          when Languages::Ruby::MODULE_TOKEN
            @token = @token + 1
          when Languages::Ruby::UNLESS_TOKEN
            @token = @token + 1
          else
            return
          end
      end

      def handle_nonclass(tokenType, line)
        case tokenType
          when Languages::Ruby::MODULE_TOKEN
            @token = @token + 1
          when Languages::Ruby::DEF_TOKEN
            save_function(line)
            @token = @token + 1
          when Languages::Ruby::REQUIRE_TOKEN
            save_requirement(line)
          when Languages::Ruby::END_TOKEN
            @token = @token - 1
          else
            return
        end
        return line
      end

      def save_function(pLine)
        function = @rubySyntaxSupport.get_function(pLine)
        @functionList.push(function)
      end

      def save_requirement(pLine)
        #TODO: Add the requirment to the list.
        requirementName = @rubySyntaxSupport.get_extern_requirement(pLine)
        @externRequirements.push(requirementName)
      end

      def save_class(line)
        # Regex in the line
        @currentClass.name = @rubySyntaxSupport.get_class_name(line)
        @classes.push(@currentClass)
        # Get inherintance
      end

      def save_attribute(line)
        attributeName = @rubySyntaxSupport.get_attribute(line)
        return if @attributeList.include?(attributeName)

        @attributeList.push(attributeName)
        attribute = Languages::AttributeData.new(attributeName)
        attribute.visibility = @visibility
        @currentClass.add_attribute(attribute)
      end

      def save_method(line)
        method = @rubySyntaxSupport.get_method(line)
        method.visibility = @visibility
        @currentClass.add_method(method)
      end

      def update_visibility(line)
        @visibility = @rubySyntaxSupport.get_visibiliy(line)
      end

  # Class
  end

# Module
end
