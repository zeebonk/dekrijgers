require "open-uri"
require "stringio"
require "fileutils"

require File.join(File.dirname(__FILE__), '/image_temp_file')

module MiniMagick
  class MiniMagickError < RuntimeError; end

  VERSION = '1.2.3'

  class Image
    attr :path
    attr :tempfile
    attr :output

    # Class Methods
    # -------------
    class <<self
      def from_blob(blob, extension=nil)
        begin
          tempfile = ImageTempFile.new("minimagick#{extension}")
          tempfile.binmode
          tempfile.write(blob)
        ensure
          tempfile.close
        end
        
        return self.new(tempfile.path, tempfile)
      end

      # Use this if you don't want to overwrite the image file
      def open(image_path)
        File.open(image_path, "rb") do |f|
          self.from_blob(f.read, File.extname(image_path))
        end
      end
      alias_method :from_file, :open
    end

    # Instance Methods
    # ----------------
    def initialize(input_path, tempfile=nil)
      @path = input_path
      @tempfile = tempfile # ensures that the tempfile will stick around until this image is garbage collected.

      # Ensure that the file is an image
      run_command("identify", @path)
    end

    # For reference see http://www.imagemagick.org/script/command-line-options.php#format
    def [](value)
      # Why do I go to the trouble of putting in newlines? Because otherwise animated gifs screw everything up
      case value.to_s
      when "format"
        run_command("identify", "-format", format_option("%m"), @path).split("\n")[0]
      when "height"
        run_command("identify", "-format", format_option("%h"), @path).split("\n")[0].to_i
      when "width"
        run_command("identify", "-format", format_option("%w"), @path).split("\n")[0].to_i
      when "dimensions"
        dimensions = run_command("identify", "-format", format_option("%w %h"), @path).split("\n")[0].split(" ")
        { :width => dimensions[0].to_i, :height => dimensions[1].to_i }
      when "size"
        File.size(@path) # Do this because calling identify -format "%b" on an animated gif fails!
      when "original_at"
        # Get the EXIF original capture as a Time object
        Time.local(*self["EXIF:DateTimeOriginal"].split(/:|\s+/)) rescue nil
      when /^EXIF\:/i
        run_command('identify', '-format', "\"%[#{value}]\"", @path).chop
      else
        run_command('identify', '-format', "\"#{value}\"", @path).split("\n")[0]
      end
    end

    # This is a 'special' command because it needs to change @path to reflect the new extension
    # Formatting an animation into a non-animated type will result in ImageMagick creating multiple
    # pages (starting with 0).  You can choose which page you want to manipulate.  We default to the
    # first page.
    def format(format, page=0)
      run_command("mogrify", "-format", format, @path)

      @path.sub!(/(\.\w+)?$/, ".#{format}")
      @path.sub!(".#{format}", "-#{page}.#{format}") unless File.exists?(@path)

      raise "Unable to format to #{format}" unless File.exists?(@path)
    end

    # Scale an image down and crop away any extra to achieve a certain size.
    # This is handy for creating thumbnails of the same dimensions without
    # changing the aspect ratio.
    def crop_resized(width, height, gravity = "Center")
      width = width.to_i
      height = height.to_i

      # Grab the width and height of the current image in one go.
      dimensions = self[:dimensions]

      # Only do anything if needs be. Who knows, maybe it's already the exact
      # dimensions we're looking for.
      if(width != dimensions[:width] && height != dimensions[:height])
        combine_options do |c|
          # Scale the image down to the widest dimension.
          if(width != dimensions[:width] || height != dimensions[:height])
            scale = [width / dimensions[:width].to_f, height / dimensions[:height].to_f].max * 100
            c.resize("#{scale}%")
          end

          # Align how things will be cropped.
          c.gravity(gravity)

          # Crop the image to size.
          c.crop("#{width}x#{height}+0+0")
        end
      end
    end

    # Writes the temporary image that we are using for processing to the output path
    def write(output_path)
      FileUtils.copy_file @path, output_path
      run_command "identify", output_path # Verify that we have a good image
    end

    # Give you raw data back
    def to_blob
      f = File.new @path
      f.binmode
      f.read
    ensure
      f.close
    end

    # If an unknown method is called then it is sent through the morgrify program
    # Look here to find all the commands (http://www.imagemagick.org/script/mogrify.php)
    def method_missing(symbol, *args)
      args.push(@path) # push the path onto the end
      run_command("mogrify", "-#{symbol}", *args)
      self
    end

    # You can use multiple commands together using this method
    def combine_options(&block)
      c = CommandBuilder.new
      block.call c
      run_command("convert", *c.args << @path << @path)
    end

    # Check to see if we are running on win32 -- we need to escape things differently
    def windows?
      !(RUBY_PLATFORM =~ /win32/).nil?
    end

    # Outputs a carriage-return delimited format string for Unix and Windows
    def format_option(format)
      windows? ? "#{format}\\n" : "#{format}\\\\n"
    end

    def run_command(command, *args)
      args.collect! do |arg|
        arg = arg.to_s
        arg = %|"#{arg}"| unless arg[0] == ?- # values quoted because they can contain characters like '>', but don't quote switches          
        arg
      end

      @output = `#{command} #{args.join(' ')}`

      if $? != 0
        raise MiniMagickError, "ImageMagick command (#{command} #{args.join(' ')}) failed: Error Given #{$?}"
      else
        @output
      end
    end
  end

  class CommandBuilder
    attr :args

    def initialize
      @args = []
    end

    def method_missing(symbol, *args)
      @args << "-#{symbol}"
      @args += args
    end
    
    def +(value)
      @args << "+#{value}"
    end
  end
end