require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'csv'

include Asciidoctor

class CsvSubcolumnIncludeProcessor < Extensions::IncludeProcessor

  #handle target
  def handles? target
    #TODO relative file path handle. current only use absolute path.
    target.end_with? '.csv'
  end

  # process method
  def process doc, reader, target, attributes
    #TODO use table attributes [%autowidth%header, format=csv, separator=;]
    csvfile_separator = attributes['column_separator']

    if attributes.has_key? 'columns' #handle csv with column attributes

      columnNumbers = parse_attributes_columns attributes

      csv_string = ""
      CSV.foreach(target, "r", col_sep: csvfile_separator) do |row|
        columnNumbers.each do |columnNumber|

          if !(row[columnNumber].nil?)
            csv_string << row[columnNumber]
            csv_string << csvfile_separator
          else
            csv_string << csvfile_separator
          end

        end
        csv_string.delete_suffix!(csvfile_separator)
        csv_string << "\n"
      end

      reader.push_include csv_string, target, target, 1, attributes
      csv_string.clear

    else #handle csv without column attributes
      content = (open target).readlines
      reader.push_include content, target, target, 1, attributes
    end
  end

  #parse attributes. transform columns number to array.
  def parse_attributes_columns attributes
    #value for columns key in attributes hash list
    colNums_Str = attributes['columns']

    splitter = ""
    if colNums_Str.include? ","
      splitter = ","
    elsif colNums_Str.include? ";"
      splitter = ";"
    end

    #convert value string to int array
    colNums_Array = colNums_Str.split(splitter).map(&:to_i)

    return colNums_Array
  end

end
