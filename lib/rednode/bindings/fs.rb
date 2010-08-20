module Rednode::Bindings
  class Fs
    
    def initialize
      @descriptors = {}
    end
    
    def Stats
      Fs::Stats
    end

    def open(path, flags, mode)
      file = File.new(path, flags, mode)
      file.fileno.tap do |fd|
        @descriptors[fd] = file
      end
    end
    
    def close(fd)
      file(fd) do |f|
        f.close()
        @descriptors.delete(fd)
      end
    end
    
    def read(fd, buffer, offset, length, position)
      file(fd) do |f|
        raise "Second argument needs to be a buffer" unless buffer.kind_of?(Buffer::StringBuffer)
        raise "Offset is out of bounds" unless offset <= buffer.length
        raise "Length is extends beyond buffer" unless (offset + length) <= buffer.length
        f.seek(position) if position
        data = buffer.send(:data)
        bytes = f.read(length)
        data[offset, bytes.length] = bytes
        bytes.length
      end
    end
    
    def stat(path)
      Stats.new(path)
    end
    
    class Stats
      def initialize(path)
        @stat = File.new(path).stat
      end
      
      def size
        @stat.size
      end
    end
    
    private
    
    def file(fd)
      if file = @descriptors[fd]
        yield file
      end
    end
  end
end