require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    table_data = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
    column_names = []
    table_data.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end

  def initialize(**attributes_hash)
    attributes_hash.each do |keys, value|
      self.send("#{keys}=", value)
    end
  end

  def self.define_attributes
    self.column_names.each do |col_name|
      attr_accessor col_name.to_sym
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{self.class.table_name} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
      SQL
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert} ORDER BY id")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    sql = "SELECT * FROM #{self.table_name} WHERE '#{attribute}' = '#{attribute}' LIMIT 1"
    DB[:conn].execute(sql)
  end

end
