module AndFeathers
  class Archive
    #
    # Represents a File inside the archive
    #
    class File
      include Enumerable

      attr_reader :name, :mode, :content

      #
      # @!attribute [r] name
      #   @return [String] the file's name
      #
      # @!attribute [r] mode
      #   @return [Fixnum] the file's mode
      #
      # @!attribute [r] content
      #   @return [Fixnum] a block which returns the file's content
      #

      #
      # Creates a new +File+
      #
      # @param name [String] the file name
      # @param mode [Fixnum] the file mode
      # @param content [Proc] a block which returns the file contents
      # @param parent [Directory, Archive] the entity which contains this file
      #
      def initialize(name, mode, content, parent)
        @name = name
        @mode = mode
        @content = content
        @parent = parent
      end

      #
      # This +File+'s path
      #
      # @return [String]
      #
      def path
        ::File.join(@parent.path, name)
      end

      def path_from(relative_path)
        path.sub(/^#{Regexp.escape(relative_path)}\/?/, '')
      end

      #
      # This +File+'s contents
      #
      def read
        @content.call
      end

      #
      # +Enumerable+ interface which simply yields this +File+ to the block
      #
      # @yieldparam file [File]
      #
      def each(&block)
        block.call(self)
      end
    end
  end
end
