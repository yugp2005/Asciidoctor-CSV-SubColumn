require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'csv'
require 'tempfile'

include Asciidoctor

class CsvSubcolumnIncludeProcessor < Extensions::IncludeProcessor

  #handle target
  def handles? target
    #TODO relative file path handle. current only use absolute path.
    target.end_with? '.csv'
  end

  # process method
  def process doc, reader, target, attributes
    if attributes.has_key? 'columns'

      columnNumbers = parse_attributes_columns attributes, ';'

      out_file = File.new("subColumnCSV.csv", "w")

      columnNumbers.each do |columnNumber|
          CSV.foreach(target) do |row|
            out_file.puts(row[columnNumber])
        end
      end

      #reader.push_include out_file, target,target, 1, attributes

      out_file.close

      #reader.push_include row[columnNumber], target,target, 1, attributes
    else
      content = (open target).readlines
      reader.push_include content, target, target, 1, attributes
    end
  end

  #parse attributes. transform columns number to array.
  def parse_attributes_columns attributes, splitter

    #value for columns key in attributes hash list
    colNums_Str = attributes['columns']

    #convert value string to int array
    colNums_Array = colNums_Str.split(splitter).map(&:to_i)

    return colNums_Array
  end


end
=begin
#include example
  def process doc, reader, target, attributes
    content = (open target).readlines
    reader.push_include content, target, target, 1, attributes
    reader
    end
=end
