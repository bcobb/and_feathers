require 'and_feathers/archive/file'
require 'and_feathers/archive/directory'
require 'and_feathers/archive/fake_filesystem_sugar'

module AndFeathers
  #
  # The base archive representation
  #
  class Archive
    include FakeFileSystemSugar
    include Enumerable

    #
    # @!attribute [r] path
    #   @return [String] the base archive path
    #

    attr_reader :path

    #
    # Creates a new +Archive+
    #
    # @param path [String] the base archive path
    #
    def initialize(path = '.')
      @path = path
      @children = {}
    end

    #
    # Iterates through each entity in the archive, depth-first
    #
    # @yieldparam child [File, Directory]
    #
    def each(&block)
      @children.each do |_, child|
        block.call(child)
        child.each(&block)
      end
    end

    #
    # Returns this +Archive+ as a package of the given +package_type+
    #
    # @example
    #   require 'and_feathers/gzipped_tarball'
    #
    #   Archive.new.to_io(AndFeathers::GzippedTarball)
    #
    # @param package_type [.open,#add_file,#add_directory]
    #
    # @return [StringIO]
    #
    def to_io(package_type)
      package_type.open do |package|
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
