require 'zip'

module AndFeathers
  #
  # Conforms to the interface expected by +Archive#to_io+ in the service of
  # turning +Archive+s into .zip files
  #
  class Zip
    #
    # Yields a +Zip+ ready for adding files and directories.
    #
    # @yieldparam package [Zip::File]
    #
    # @return [StringIO]
    #
    def self.open(&block)
      io = StringIO.new('')

      ::Zip::OutputStream.write_buffer(io) do |zip|
        block.call(new(zip))
      end

      io
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
    # @param file [AndFeathers::File]
    #
    def add_file(file)
      @zip.put_next_entry(file.path)
      @zip.write(file.read)
    end

    #
    # Adds the given directory to the zip
    #
    # @param directory [AndFeathers::Directory]
    #
    def add_directory(directory)
      @zip.put_next_entry(directory.path)
    end
  end
end
