require 'and_feathers/sugar'

module AndFeathers
  #
  # Represents a Directory inside the archive
  #
  class Directory
    include Sugar
    include Enumerable

    attr_reader :name, :mode, :children
    attr_writer :parent

    #
    # @!attribute [r] name
    #   @return [String] the directory name
    #
    # @!attribute [r] mode
    #   @return [Fixnum] the directory mode
    #
    # @!attribute [rw] parent
    #   @return [Directory] the directory's parent
    #

    #
    # Creates a new +Directory+
    #
    # @param name [String] the directory name
    # @param mode [Fixnum] the directory mode
    #
    def initialize(name = '.', mode = 16877)
      @name = name
      @mode = mode
      @parent = nil
      @children = {}
    end

    #
    # Adds a child node to this directory
    #
    # @param entity [Directory, File]
    #
    def add_child(entity)
      @children[entity.name] = entity
      entity.parent = self
    end

    #
    # This +Directory+'s path
    #
    # @return [String]
    #
    def path
      if @parent
        ::File.join(@parent.path, name)
      else
        name
      end
    end

    #
    # Determines this +Directory+'s path relative to the given path.
    #
    # @return [String]
    #
    def path_from(relative_path)
      path.sub(/^#{Regexp.escape(relative_path)}\/?/, '')
    end

    #
    # Iterates through this +Directory+'s children depth-first
    #
    # @yieldparam child [File, Directory]
    #
    def each(&block)
      files, subdirectories = @children.partition do |_, child|
        child.is_a?(File)
      end

      files.map(&:last).each(&block)

      subdirectories.map(&:last).each do |subdirectory|
        block.call(subdirectory)

        subdirectory.each(&block)
      end
    end

    #
    # Returns this +Directory+ as a package of the given +package_type+
    #
    # @example
    #   require 'and_feathers/gzipped_tarball'
    #
    #   format = AndFeathers::GzippedTarball
    #   Archive::Directory.new('test', 16877).to_io(format)
    #
    # @param package_type [.open,#add_file,#add_directory]
    #
    # @return [StringIO]
    #
    def to_io(package_type)
      package_type.open do |package|
        package.add_directory(self)

        each do |child|
          case child
          when File
            package.add_file(child)
          when Directory
            package.add_directory(child)
          end
        end
      end
    end
  end
end
