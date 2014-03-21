require 'and_feathers/archive/file'
require 'and_feathers/archive/directory'
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
end
