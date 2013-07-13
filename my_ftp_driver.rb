# coding: utf-8

# a secure FTP server
#
# Usage:
#
#   em-ftpd examples/fake.rb
$:.unshift(File.expand_path('../lib/',__FILE__))
require 'em-ftpd'
require 'helpers'
require 'aws/s3'


class MyFTPDriver
attr_accessor :server

  def initialize()
      @server = Helpers.new()
	puts 'welcome'
  end

  def change_dir(path, &block)
    dir = self.server.is_dir(path)
puts dir
    if (dir == 'dir' or path == '/')
	puts "is dir"
	yield true
    else
	puts "is false"
	yield false
    end
  end

  def dir_contents(path, &block)
    @res = Array.new
    self.server.get_file(path) {|i,j|   @res.push(file_item("#{i}","#{j}"))}
    self.server.get_dir(path)  {|i|   @res.push(dir_item("#{i}"))}       
    yield @res
  end

  def authenticate(user, pass, &block)
    @res = Array.new
    self.server.get_dir('/')  {|i|   @res.push("#{i}")}
    yield (@res.include? user or user == "test") && pass == "1234"
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
    dir = self.server.is_dir(from)
    if (dir == 'dir')
	puts "is dir"
	from = from[1 .. from.length-1]+"/"
	to = to[1 .. to.length-1]+"/"
	result = AWS::S3::S3Object.rename(from,to,'em-ftpd-trial')
    elsif (dir == 'file')
	puts "is file"
	result = AWS::S3::S3Object.rename(from,to,'em-ftpd-trial')
    else
	puts "is false"
	result = false
    end

    if (result)
	yield true
    else	
    	yield false
    end
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
#driver     MyFTPDriver
#driver_args 1, 2, 3
#user      "ftp"
#group     "ftp"
#daemonise false
#name      "fakeftp"
#pid_file  "/var/run/fakeftp.pid"
