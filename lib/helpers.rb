require 'aws/s3'

class Helpers

  def initialize()
	AWS::S3::Base.establish_connection!(
	  :access_key_id => "AKIAJFPIHK4NAK4WUM5A",
	  :secret_access_key => "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"
	  )
#	@bucket_root = AWS::S3::Service.buckets()
#	@list = Array.new
#	for i in 0 .. @bucket_root.size-1
#		puts @bucket_root[i].name
#		@list = @list.push(@bucket_root[i].name)
#	end
#  return @list
  end
  
  def get_dir(path)

        @bucket_root = AWS::S3::Service.buckets()
	$bucket_name = @bucket_root[0].name
	@bucket_dir = AWS::S3::Bucket.objects($bucket_name)
	@dir = Array.new
	for i in 0 .. @bucket_dir.size-1
		$buffer = @bucket_dir[i].key
		if ($buffer=~/\//)
			tmp = path+"/"
			@buffer = $buffer.split(tmp[1..tmp.length-1])
			if (path == '/')
 	                       @dir.push(@buffer[0])
			elsif (@buffer[1]=~/\//)
				$a=@buffer[1]
				@tmp_dir=$a.split('/')
                               @dir.push(@tmp_dir[0])
			end
		end
	end
	@dir = @dir.uniq	
	for i in 0 .. @dir.size-1
		yield @dir[i]
	end
  end

  def get_file(path)

        @bucket_root = AWS::S3::Service.buckets()
        $bucket_name = @bucket_root[0].name
        @bucket_file = AWS::S3::Bucket.objects($bucket_name)
        @file = Array.new
	@size = Array.new
        for i in 0 .. @bucket_file.size-1
                $buffer = @bucket_file[i].key
#                if (($buffer=~/\//) == nil)
                        tmp = path+"/"
                        @buffer = $buffer.split(tmp[1..tmp.length-1])
#			puts $buffer
                        if (path == '/' and ($buffer=~/\//) == nil)
                               @file.push(@buffer[0])
                        elsif (path != '/' and @buffer[1] and (@buffer[1]=~/\//) == nil)
                                $a=@buffer[1]
                                @tmp_dir=$a.split('/')
                               @file.push(@tmp_dir[0])
                        end
#                end
        end
        @file = @file.uniq
        for i in 0 .. @file.size-1
#		puts @file[i]
              yield @file[i]
        end
  end
end
