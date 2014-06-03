require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map {|hash| self.new(hash)}
  end
end

class SQLObject < MassObject

  def self.columns
    DBConnection.execute2("SELECT * FROM #{self.table_name}")[0].each do |column|
      define_method("#{column}"){attributes[column]}
      define_method("#{column}="){|value| attributes[column] = value}
    end
  end

  def self.table_name=(table_name)
    @table = table_name
  end

  def self.table_name
    @table || self.to_s.pluralize.downcase
  end

  def self.all
    all_hashes = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{table_name}
    SQL
    self.parse_all(all_hashes)

    #all_hashes.map{|row_hash| self.new(row_hash)}
  end

  def self.find(id)
    self.parse_all(DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{table_name}
    WHERE id = #{id}
    SQL
    ).first
  end

  def attributes
    @attributes || @attributes = {}
  end

  def insert
    p col_names = attributes.keys.join(',')
    p questions = ("?"*col_names.split(',').length).split('').join(',')
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{questions})
    SQL

   self.id = DBConnection.last_insert_row_id
  end

  def initialize(*params)
    self.class.columns
    params[0].each do |key, value|
      send("#{key}=", value)
    end
  end

  def save
    # ...
  end

  def update
    p col_names = attributes.keys[1..-1].join(' = ?, ')+' = ?'
    p id = self.id
    p attribute_values
    DBConnection.execute(<<-SQL, *attribute_values)
    UPDATE
      #{self.class.table_name}
    SET
      #{col_names}
    WHERE
      id = #{self.id}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def attribute_values
    attributes.values
  end
end

class Cat < SQLObject
end

cat = Cat.new({name: 'Gizmo', owner_id: 2})
cat.insert
#p second_cat = Cat.find(2)
p Cat.all
