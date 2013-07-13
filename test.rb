$:.unshift(File.expand_path('../lib/',__FILE__))
require 'helpers'

 A=Helpers.new()
 puts A.is_dir('/aselim/123.txt')
