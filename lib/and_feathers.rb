require 'and_feathers/tarball/file'
require 'and_feathers/tarball/directory'
require 'and_feathers/tarball'
require 'and_feathers/version'

#
# The entry-point to the builder DSL
#
module AndFeathers
  #
  # Builds a new +Tarball+. If +base+ is not given, the tarball's contents
  # would be extracted to intermingle with whichever directory contains the
  # tarball. If +base+ is given, the tarball's contents will live inside a
  # directory with that name. This is just a convenient way to have a +dir+
  # call wrap the tarball's contents
  #
  # @param base [String] name of the base directory containing the tarball's
  #   contents
  # @param base_mode [Fixnum] the mode of the base directory
  #
  # @yieldparam tarball [Tarball]
  #
  def self.build(base = nil, base_mode = 16877, &block)
    if base && base_mode
      Tarball.new.tap do |tarball|
        tarball.dir(base, base_mode) do |dir|
          block.call(dir)
        end
      end
    else
      Tarball.new.tap do |tarball|
        block.call(tarball)
      end
    end
  end
end
