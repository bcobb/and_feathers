require 'and_feathers/file'
require 'and_feathers/directory'
require 'and_feathers/sugar'

module AndFeathers
  class Archive
    include Sugar
    include Enumerable

    attr_reader :versions, :initial_version

    def initialize(extract_to = '.', extraction_mode = 16877)
      @initial_version = Directory.new(extract_to, extraction_mode)
      @versions = [@initial_version]
      @extract_to = extract_to
      @extraction_mode = extraction_mode
    end

    def add_directory(directory)
      @versions << Directory.new(@extract_to, @extraction_mode).tap do |parent|
        parent.add_directory(directory)
      end
    end

    def add_file(file)
      @initial_version.file(file.name, file.mode, &file.content)
    end

    def each(&block)
      @versions.reduce(&:|).each(&block)
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
