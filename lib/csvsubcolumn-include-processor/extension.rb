require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'csv'

include Asciidoctor

class CsvSubcolumnIncludeProcessor < Asciidoctor::Extensions::IncludeProcessor

	def handles? target
		target.end_with? '.csv'
	end

	def process doc, reader, target, attributes
		#TODO use table attributes [%autowidth%header, format=csv, separator=;]

		# set a default column separator if not provided
		if attributes.has_key? 'column_separator'
			csvfile_separator = attributes['column_separator']
		else
			csvfile_separator = ","
		end

		if attributes.has_key? 'lines'
			line_numbers = parse_asciidoc_range attributes['lines']
		end

		if attributes.has_key? 'columns'
			column_numbers = parse_asciidoc_range attributes['columns']
		end

		# subset csv by columns (lines optional)
		if column_numbers.kind_of?(Array)
			csv_string = ""
			CSV.foreach(target, "r", col_sep: csvfile_separator).with_index(1) do |row, lineno|

				# if lines are requested, skip those not in the attributes
				if line_numbers.kind_of?(Array) and not line_numbers.include?(lineno)
					next
				end

				row_subset = row.select.with_index { |e, i| column_numbers.include? i+1 }

				quoted_row = row_subset.map do |item|
					if item.nil?
						item
					elsif item.include?(",")
						'"' + item + '"'
					else
						item
					end
				end

				csv_string << quoted_row.join(',')
				csv_string << "\n"
			end

			reader.push_include csv_string, target, target, 1, attributes
			csv_string.clear

			# subset csv by line
		elsif line_numbers.kind_of?(Array)
			csv_string = ""
			CSV.foreach(target, "r", col_sep: csvfile_separator).with_index(1) do |row, lineno|
				if line_numbers.include?(lineno)

					quoted_row = row.map do |item|
						if item.nil?
							item
						elsif item.include?(",")
							'"' + item + '"'
						else
							item
						end
					end

					csv_string << quoted_row.join(',')
					csv_string << "\n"
				end
			end

			reader.push_include csv_string, target, target, 1, attributes
			csv_string.clear

			# do not subset csv
		else
			content = (open target).readlines
			reader.push_include content, target, target, 1, attributes
		end
	end

	#method parse attributes. transform columns number to array.
	def parse_asciidoc_range asciidoc_range_string

		#column splitter: ',', ';'
		splitter = ""
		if asciidoc_range_string.include? ","
			splitter = ","
		elsif asciidoc_range_string.include? ";"
			splitter = ";"
		end

		if (splitter.nil_or_empty?) && (asciidoc_range_string.include? '.')
			return stringRange_to_integerArray asciidoc_range_string
		else
			split_str = asciidoc_range_string.split(splitter)
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
