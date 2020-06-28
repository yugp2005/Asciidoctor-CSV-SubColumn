require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'csv'

include Asciidoctor

class CsvSubcolumnIncludeProcessor < Extensions::IncludeProcessor

  #handle target
  def handles? target
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

  #method parse attributes. transform columns number to array.
  def parse_attributes_columns attributes
    #value for columns key in attributes hash list
    colNums_Str = attributes['columns']

    #column splitter: ',', ';'
    splitter = ""
    if colNums_Str.include? ","
      splitter = ","
    elsif colNums_Str.include? ";"
      splitter = ";"
    end

    if (splitter.nil_or_empty?) && (colNums_Str.include? '.')
      return stringRange_to_integerArray colNums_Str
    else
      split_str = colNums_Str.split(splitter)
      return stringArray_to_IntegerArray split_str
    end
  end

  #method convert string to integer array
  def stringArray_to_IntegerArray stringArray

    integerArray = Array.new

    stringArray.each do |str_int|
      countDot = str_int.count('.')
      if  countDot == 1
        puts "#{str_int} should be integer, single dot is not valid range"
      elsif countDot == 2
        elements = str_int.split('..')
        range_newTwo = Range.new(elements[0].to_i, elements[1].to_i)
        range_newTwo.to_a.each do |single|
          integerArray << single.to_i
        end
      elsif countDot == 3
        elements = str_int.split('...')
        range_newThree = Range.new(elements[0].to_i, elements[1].to_i - 1)
        range_newThree.to_a.each do |singleThree|
          integerArray << singleThree.to_i
        end
      elsif countDot > 3
        puts "#{str_int} should be valid range. Too many dots between number."
      else
        integerArray << str_int.to_i
      end
    end
    return integerArray
  end

  #method string range to integer array
  def stringRange_to_integerArray stringRange
    integerArray = Array.new
    countDot = stringRange.count('.')
    case countDot
    when 1
      puts "#{stringRange} should be integer, single dot is not valid range"
    when 2
      elements = stringRange.split('..')
      range_newTwo = Range.new(elements[0].to_i, elements[1].to_i)
      range_newTwo.to_a.each do |single|
        integerArray << single.to_i
      end
    when 3
      elements = stringRange.split('...')
      range_newThree = Range.new(elements[0].to_i, elements[1].to_i - 1)
      range_newThree.to_a.each do |singleThree|
        integerArray << singleThree.to_i
      end
    else
      puts "#{stringRange} should be valid range. Too many dots between number."
    end
    return integerArray
  end

end
