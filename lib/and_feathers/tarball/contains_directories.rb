module AndFeathers
  class Tarball
    #
    # A module which gives instances of a class the +dir+ DSL method
    #
    module ContainsDirectories
      #
      # Add a +Directory+ named +name+ to this entity's list of children
      #
      # @param name [String] the directory name
      # @param mode [Fixnum] the directory mode
      #
      # @yieldparam directory [Directory] the newly-created +Directory+
      #
      def dir(name, mode = 16877, &block)
        Directory.new(name, mode, self).tap do |subdir|
          block.call(subdir) if block

          @children.push(subdir)
        end
      end
    end
  end
end
