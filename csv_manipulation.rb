require 'csv'
require 'pry'

#read from .csv file
csv_table = CSV.read("sample_data.csv")
first_row = csv_table[0]
columns = {}
first_row.each_with_index do |title, index|
  columns[title.to_sym] = index
end



#references..
header_row_index = 0
published_column_index = columns[:Published]
images_column_index = columns[:Images]

#for every row in the table
bad_indexes = []
index = 0
for row in csv_table
  puts "reading row:"
  puts "#{row}"
  if index != header_row_index #except the first header row
    #if the published column is 1
    row_published_value = row[published_column_index]
    row_images_value = row[images_column_index]
    puts "row's published column value: #{row_published_value}"
    if row_published_value == "1"
      #remove the row from the table
      #csv_table.delete_at(index)
      bad_indexes.append(index)
    elsif row_images_value.nil?
      bad_indexes.append(index)
    else
      if row.include?("Direct URL") == false
        bad_indexes.append(index)
      else
        direct_url_index = row.find_index("Direct URL")
        index_to_right_of_direct_url = direct_url_index + 1
        if index_to_right_of_direct_url.nil?
          bad_indexes.append(index)
        end
    end
  end
    #if the images column is empty
  puts "row index after deletion: #{csv_table[index]}"
end
index += 1
end
bad_indexes = bad_indexes.reverse
for target in bad_indexes
  csv_table.delete_at(target)
end

##copy right of merchant into "Button" column.
##identify the button column programatically
column_full_name = ''
column_index = ''

columns.each do |key, value|
  if key.to_s.include? "Button"
    column_full_name = key
    column_index = value
  end
end
#find "merchant" cell
for row in csv_table
  if row.include? "merchant"
    right_index = row.find_index("merchant") + 1
    #copy the text inside it
    copy_this_to_button_column = row[right_index]
    row[column_index] = "Buy on " + copy_this_to_button_column
  end
end
  
  

#cell_to_right_of_merchant

output = ''
#output += csv_table[0]
for line in csv_table do
  output += CSV.generate_line(line)
end
p output
file = File.open('new_table.csv', 'w+')
file.write(output)
file.close

#remove bad words
censored_words = ["Slide", "House", "fRame"]
file = File.new("new_table.csv", 'r')
contents = file.read
file.close
file = File.new("censored_table.csv", 'w+')
for word in censored_words do
  contents = contents.gsub(/#{word}/i, "")
end
file.write(contents)
file.close

#change the value of remaining "Published" columns to 1
csv_table = CSV.read("censored_table.csv")

first_row_skipped = false
for row in csv_table
  if first_row_skipped == false
    first_row_skipped = true
    next
  else
    row[published_column_index] = 1
  end
end

file = File.new("published_to_1.csv", "w+")
output = ''
for line in csv_table do
  output += CSV.generate_line(line)
end
file.write(output)
file.close

#
