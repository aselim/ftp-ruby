# coding: utf-8

# a secure FTP server
#
# Usage:
#
#   em-ftpd examples/fake.rb
$:.unshift(File.expand_path('../lib/',__FILE__))
require 'helpers'
require 'aws/s3'

class MyFTPDriver
      Server = Helpers.new()
  
  def change_dir(path, &block)
    yield true
  end

  def dir_contents(path, &block)
    @res = Array.new
    Server.get_file(path) {|i|   @res.push(file_item("#{i}","120"))}
    Server.get_dir(path)  {|i|   @res.push(dir_item("#{i}"))}       
    yield @res
  end

  def authenticate(user, pass, &block)
    yield user == "test" && pass == "1234"
  end

  def bytes(path, &block)
    yield case path
          when "/one.txt"       then FILE_ONE.size
          when "/files/two.txt" then FILE_TWO.size
          else
            false
          end
  end

  def get_file(path, &block)
    
    item = AWS::S3::S3Object.find(path[1 .. path.length-1],'em-ftpd-trial')
    yield item.value and return
	

    #yield case path
    #      when "/one.txt"       then FILE_ONE
    #      when "/files/two.txt" then FILE_TWO
    #      else
    #        false
    #      end
  end

  def put_file(path, data, &block)
    puts path+","+data
    file = open(data)
    AWS::S3::S3Object.store(path,file.read,'em-ftpd-trial')
    yield file.read.length
  end

  def delete_file(path, &block)
    puts path
    AWS::S3::S3Object.delete(path,'em-ftpd-trial')
    yield true
  end

  def delete_dir(path, &block)
    yield false
  end

  def rename(from, to, &block)
    puts from+","+to
    AWS::S3::S3Object.rename(from,to,'em-ftpd-trial')
    yield true
  end

  def make_dir(path, &block)
    puts path
    AWS::S3::S3Object.store(path+'/','','em-ftpd-trial',:content_type => 'binary/octet-stream')
    yield true
  end

  private

  def dir_item(name)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => true, :size => 0)
  end

  def file_item(name, bytes)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => false, :size => bytes)
  end

end

# configure the server
driver     MyFTPDriver
#driver_args 1, 2, 3
#user      "ftp"
#group     "ftp"
#daemonise false
#name      "fakeftp"
#pid_file  "/var/run/fakeftp.pid"
