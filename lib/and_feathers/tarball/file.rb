module AndFeathers
  class Tarball
    #
    # Represents a File inside the tarball
    #
    class File
      include Enumerable

      attr_reader :name, :mode

      #
      # @!attribute [r] name
      #   @return [String] the directory name
      #
      # @!attribute [r] mode
      #   @return [Fixnum] the directory mode
      #

      #
      # Creates a new +File+
      #
      # @param name [String] the file name
      # @param mode [Fixnum] the file mode
      # @param content [Proc] a block which returns the file contents
      # @param parent [Directory, Tarball] the entity which contains this file
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
