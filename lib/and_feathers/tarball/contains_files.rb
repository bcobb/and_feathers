module AndFeathers
  class Tarball
    #
    # A module which gives instances of a class the +file+ DSL method
    #
    module ContainsFiles
      #
      # The default file content block, which returns an empty string
      #
      NO_CONTENT = Proc.new { "" }

      #
      # Add a +File+ named +name+ to this entity's list of children
      #
      # @param name [String] the file name
      # @param mode [Fixnum] the file mode
      #
      # @yieldreturn [String] the file contents
      #
      def file(name, mode = 33188, &content)
        content ||= NO_CONTENT

        @children.push(File.new(name, mode, content, self))
      end
    end
  end
end
