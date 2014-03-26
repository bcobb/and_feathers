module AndFeathers
  #
  # Represents a File inside the archive
  #
  class File
    attr_reader :name, :mode, :content
    attr_accessor :parent

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
    # @!attribute [rw] parent
    #   @return [Directory] the file's parent
    #

    #
    # Creates a new +File+
    #
    # @param name [String] the file name
    # @param mode [Fixnum] the file mode
    # @param content [Proc] a block which returns the file contents
    #
    def initialize(name, mode, content)
      @name = name
      @mode = mode
      @content = content
      @parent = nil
    end

    #
    # Reset +parent+ when calling +dup+ or +clone+ on a +File+
    #
    # @param source [File]
    #
    def initialize_copy(source)
      super

      @parent = nil
    end

    #
    # This +File+'s path
    #
    # @return [String]
    #
    def path
      if @parent
        ::File.join(@parent.path, name)
      else
        ::File.join('.', name)
      end
    end

    #
    # Determines this +File+'s path relative to the given path.
    #
    # @return [String]
    #
    def path_from(relative_path)
      path.sub(/^#{Regexp.escape(relative_path)}\/?/, '')
    end

    #
    # This +File+'s contents
    #
    def read
      @content.call
    end
  end
end
