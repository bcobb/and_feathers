require 'and_feathers/archive'
require 'and_feathers/version'

#
# The entry-point to the builder DSL
#
module AndFeathers
  #
  # Builds a new +Archive+. If +base+ is not given, the archives's contents
  # would be extracted to intermingle with whichever directory contains the
  # archive. If +base+ is given, the archive's contents will live inside a
  # directory with that name. This is just a convenient way to have a +dir+
  # call wrap the archive's contents
  #
  # @param base [String] name of the base directory containing the archive's
  #   contents
  # @param base_mode [Fixnum] the mode of the base directory
  #
  # @yieldparam archive [Archive]
  #
  def self.build(base = nil, base_mode = 16877, &block)
    if base && base_mode
      Archive.new.tap do |archive|
        archive.dir(base, base_mode) do |dir|
          block.call(dir)
        end
      end
    else
      Archive.new.tap do |archive|
        block.call(archive)
      end
    end
  end

  #
  # Builds a new +Archive+ from the directory at the given +path+. The
  # innermost directory is taken to be the parent folder of the archive's
  # contents.
  #
  # @param path [String] path to the directory to archive
  #
  # @yieldparam archive [Archive] the loaded Archive
  #
  def self.from_path(path, &block)
    if !File.exists?(path)
      raise ArgumentError, "#{path} does not exist"
    end

    directories, files = ::Dir[::File.join(path, '**/*')].partition do |path|
      ::File.directory?(path)
    end

    base = path.split(::File::SEPARATOR).last

    if base == '.'
      base = ::File.expand_path(base).split(::File::SEPARATOR).last
    end

    Archive.new.tap do |archive|
      archive.dir(base) do |base_dir|
        directories.map do |directory|
          directory.sub(/^#{Regexp.escape(path)}\/?/, '')
        end.each do |directory|
          base_dir.dir(directory)
        end

        files.each do |file|
          File.open(file, 'rb') do |io|
            content = io.read

            base_dir.file(file.sub(/^#{Regexp.escape(path)}\/?/, '')) do
              content
            end
          end
        end
      end

      block.call(archive) if block
    end
  end
end
