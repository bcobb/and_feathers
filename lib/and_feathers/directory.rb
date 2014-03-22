require 'and_feathers/sugar'

module AndFeathers
  #
  # Represents a Directory
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

    #
    # Computes the union of this +Directory+ with another +Directory+. If the
    # two directories have a file path in common, the file in the +other+
    # +Directory+ takes precedence. If the two directories have a sub-directory
    # path in common, the union's sub-directory path will be the union of those
    # two sub-directories.
    #
    # @raise [ArgumentError] if the +other+ parameter is not a +Directory+
    #
    # @param other [Directory]
    #
    # @return [Directory]
    #
    def |(other)
      if !other.is_a?(Directory)
        raise ArgumentError, "#{other} is not a Directory"
      end

      self.dup.tap do |directory|
        other.files.each do |file|
          directory.add_file(file.dup)
        end

        other.directories.each do |new_directory|
          existing_directory = @directories[new_directory.name]

          if existing_directory.nil?
            directory.add_directory(new_directory.dup)
          else
            directory.add_directory(new_directory.dup | existing_directory.dup)
          end
        end
      end
    end

    #
    # The +File+ entries which exist in this +Directory+
    #
    # @return [Array<File>]
    #
    def files
      @files.values
    end

    #
    # The +Directory+ entries which exist in this +Directory+
    #
    # @return [Array<Directory>]
    #
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

    #
    # Sets the given +directory+'s parent to this +Directory+, and adds it as a
    # child.
    #
    # @param directory [Directory]
    #
    def add_directory(directory)
      @directories[directory.name] = directory
      directory.parent = self
    end

    #
    # Sets the given +file+'s parent to this +Directory+, and adds it as a
    # child.
    #
    # @param file [File]
    #
    def add_file(file)
      @files[file.name] = file
      file.parent = self
    end
  end
end
