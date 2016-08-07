
require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
    #is there another way to do this? I tried to
    #write my own pluralize method before I was informed
    #it existed, would be interested to see other ways
  end

  def initialize(attributes={})
    attributes.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    table = DB[:conn].execute(sql)
    table.collect! do |column|
      column["name"]
    end
    table.compact
  end

  def save
    sql = "INSERT INTO
    #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    results = DB[:conn].execute("SELECT
    last_insert_rowid()
    FROM #{table_name_for_insert}")
    self.id = results[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|value| value == "id"}.join(", ")
    #why can't I put the curlies on the second line
    #it should not affect the run of the program
    #caused errors
  end

  def values_for_insert
    column_array = self.class.column_names.delete_if {|value| value == "id"}
    values = []
    column_array.each do |column_title|
      #i had 'column' inside my do statement first
      #why did that not work?
      values << "'#{self.send(column_title)}'"
    end
    values.join(", ")
  end



  def self.find_by(attributes)
    sql = "SELECT * FROM
    #{self.table_name}
    WHERE #{attributes.keys[0]} = '#{attributes.values[0]}'"
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM
    #{self.table_name}
    WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
