require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    if @columns
      return @columns
    end

    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL

    @columns = data.first.map {|column| column.to_sym}

  end

  def self.finalize!
    self.columns.each do |c|
      # debugger
      define_method("#{c}"){ self.attributes[c]}

      # instance_variable_get(self.attributes[c.to_s])   }

      define_method("#{c}=") do |new_value|
        self.attributes[c] = new_value
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
    # table_name ? @table_name = table_name : @table_name = self.class.name.tableize
  end

  def self.table_name

    @table_name ? @table_name : self.name.tableize
    #@table_name
    # ...
  end

  def self.all
    # ...
    data = DBConnection.execute(<<-SQL)
    SELECT
    *
    FROM
      #{self.table_name}
    SQL

    self.parse_all(data)

  end

  def self.parse_all(data)
    # ...each element in data is a row in the database.
    # We need to take each value in that row, and create
    # an object using those as parameters.

    results = []
    data.each do |element|
      results << self.new(element)
    end
    results


  end

  def self.find(id)
    # ...
    data = DBConnection.execute(<<-SQL)
    SELECT
    *
    FROM
      #{self.table_name}
    WHERE
      id = #{id}
    SQL
    return nil if data.empty?
    self.new(data.first)
  end

  def initialize(params = {})
    # ...
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      self.send("#{attr_name}=",value)
    end
  end

  def attributes
    # ...
    unless @attributes
      @attributes = {}
    end
    @attributes
  end

  def attribute_values
    # ...
    self.attributes.values
  end

  def insert
    # ...
    col_names = self.class.columns.join(",")
    question_marks = (["?"] * self.class.columns.length).join(",")

    DBConnection.execute(<<-SQL, *self.attribute_values)
    INSERT INTO
      #{self.table_name} (col_names)
    VALUES
      question_marks
    SQL

    DBConnnection.last_insert_row_id

  end

  def update
    # ...
  end

  def save
    # ...
  end
end
