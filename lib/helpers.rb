require 'aws/s3'

class Helpers
module EM::FTPD
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
  
  def is_dir(path)
	puts path
        @bucket_root = AWS::S3::Service.buckets()
	$bucket_name = @bucket_root[0].name
	path = path+"/"
	@tmp = AWS::S3::Bucket.objects($bucket_name, :prefix => path[1 .. path.length-1])
	puts @tmp.size
	if (@tmp.size != 0)
		return 'dir'
	else
		begin
			AWS::S3::S3Object.find(path[1 .. path.length-2],$bucket_name)
			return 'file'
		rescue => e
			return false
		end
	end
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
	for i in 0 .. @bucket_file.size-1
                $buffer = @bucket_file[i].key
#		puts $size
#                if (($buffer=~/\//) == nil)
                        tmp = path+"/"
                        @buffer = $buffer.split(tmp[1..tmp.length-1])
#			puts $buffer
                        if (path == '/' and ($buffer=~/\//) == nil)
				$size = @bucket_file[i].content_length
                               @file.push(@buffer[0]+","+$size)
                        elsif (path != '/' and @buffer[1] and (@buffer[1]=~/\//) == nil)
				$size = @bucket_file[i].content_length
				$a=@buffer[1]
                                @tmp_dir=$a.split('/')
                               @file.push(@tmp_dir[0]+","+$size)

                        end
#                end
        end
        @file = @file.uniq
        for i in 0 .. @file.size-1
		@file_tmp=@file[i].split(',')
		yield @file_tmp[0],@file_tmp[1]
        end
  end
end
end
