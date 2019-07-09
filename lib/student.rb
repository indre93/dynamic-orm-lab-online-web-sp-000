require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord
  define_attributes
end
