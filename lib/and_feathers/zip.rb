require 'rubyzip'

module AndFeathers
  class Zip
    #
    # Yields a +Zip+ ready for adding files and directories.
    #
    # @yieldparam package [Zip::File]
    #
    # @return [StringIO]
    #
    def self.open(&block)
    end

    #
    # Creates a new +Zip+. Provides the interface require by
    # +AndFeathers::Zip#to_io+
    #
    # @param zip [Zip::File]
    #
    def initialize(zip)
      @zip = zip
    end

    #
    # Adds the given file to the zip
    #
    # @param file [AndFeathers::Archive::File]
    #
    def add_file(file)
    end

    #
    # Adds the given directory to the zip
    #
    # @param directory [AndFeathers::Archive::Directory]
    #
    def add_directory(directory)
    end
  end
end
