require 'and_feathers/file'
require 'and_feathers/directory'
require 'and_feathers/sugar'

module AndFeathers
  #
  # The parent class of a given directory tree. It knows whether or not the
  # archive's contents should be extracted into its own directory or into its
  # containing directory.
  #
  # An +Archive+ exposes the same sugary interface exposed by a +Directory+,
  # but it is implemented so that adding files and directories directly to the
  # +Archive+ is not destructive. In fact, whenever a file or directory is
  # added to an +Archive+, the +Archive+ creates a new top-level directory, and
  # delegates the change to it. That way, when it's time to enumerate the
  # entries in the +Archive+, we can take the union of all of these top-level
  # directories and enumerate _its_ entries. Thus, the only possibility for
  # loss is if two changes modify the same file, in which case we take the
  # latest file to be the authoritative file.
  #
  class Archive
    include Sugar
    include Enumerable

    #
    # Creates a new +Archive+
    #
    # @param extract_to [String] the path under which the +Archive+ should be
    #   extracted
    # @param extraction_mode [Fixnum] the mode of the +Archive+'s base directory
    #
    def initialize(extract_to = '.', extraction_mode = 16877)
      @initial_version = Directory.new(extract_to, extraction_mode)
      @versions = [@initial_version]
      @extract_to = extract_to
      @extraction_mode = extraction_mode
    end

    #
    # Adds a +Directory+ to the top level of the +Archive+
    #
    # @param directory [Directory]
    #
    def add_directory(directory)
      @versions << Directory.new(@extract_to, @extraction_mode).tap do |parent|
        parent.add_directory(directory)
      end
    end

    #
    # Adds a +File+ to the top level of the +Archive+
    #
    # @param file [File]
    #
    def add_file(file)
      @initial_version.file(file.name, file.mode, &file.content)
    end

    #
    # Iterates depth-first through the +Archive+'s entries
    #
    # @yieldparam entry [Directory, File]
    #
    def each(&block)
      @versions.reduce(&:|).each(&block)
    end

    #
    # Returns this +Archive+ as a package of the given +package_type+
    #
    # @example
    #   require 'and_feathers/gzipped_tarball'
    #
    #   format = AndFeathers::GzippedTarball
    #   AndFeathers::Archive.new('test', 16877).to_io(format)
    #
    # @see https://github.com/bcobb/and_feathers-gzipped_tarball
    # @see https://github.com/bcobb/and_feathers-zip
    #
    # @param package_type [.open,#add_file,#add_directory]
    #
    # @return [StringIO]
    #
    def to_io(package_type)
      package_type.open do |package|
        package.add_directory(@initial_version)

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
