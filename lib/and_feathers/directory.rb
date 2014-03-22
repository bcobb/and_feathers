require 'and_feathers/sugar'

module AndFeathers
  #
  # Represents a Directory inside the archive
  #
  class Directory
    include Sugar
    include Enumerable

    attr_reader :name, :mode
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
      @files = {}
      @directories = {}
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
        if name != '.'
          ::File.join('.', name)
        else
          name
        end
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

    def files
      @files.values
    end

    def directories
      @directories.values
    end

    #
    # Iterates through this +Directory+'s children depth-first
    #
    # @yieldparam child [File, Directory]
    #
    def each(&block)
      files.each(&block)

      directories.each do |subdirectory|
        block.call(subdirectory)

        subdirectory.each(&block)
      end
    end

    def add_directory(directory)
      @directories[directory.name] = directory
      directory.parent = self
    end

    def add_file(file)
      @files[file.name] = file
      file.parent = self
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
