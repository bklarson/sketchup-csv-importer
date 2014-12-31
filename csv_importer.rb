require 'sketchup.rb'
require 'csv'

UI.menu("Plugins").add_item("Import CSV") {
	import_csv
}

def import_csv
	current_x = 0
	start_row = 0
	width_col = 0
	length_col = 1
	count_col = 2
	name_col = 3
	
	chosen_file = UI.openpanel("Open csv File", nil, "csv|*.csv||")
	if( chosen_file == nil )
		# No file was selected; abort
		return
	end

	arr_of_arrs = CSV.read( chosen_file )
	arr_of_arrs[0].length.times do |i|
		# Look for headers in csv.
		case arr_of_arrs[0][i]
		when "width"
			start_row = 1
			width_col = i
		when "height", "length"
			start_row = 1
			length_col = i
		when "count", "num", "number"
			start_row = 1
			count_col = i
		when "name", "label"
			start_row = 1
			name_col = i
		end
	end

	for i in start_row..arr_of_arrs.length-1
		if arr_of_arrs[i][count_col] == nil
			count = 1
		else
			count = arr_of_arrs[i][count_col].to_i
		end
		width = str_to_f( arr_of_arrs[i][width_col] )
		length = str_to_f( arr_of_arrs[i][length_col] )
		create_boards(
			width,
			length,
			count,
			arr_of_arrs[i][name_col],
			current_x )
		current_x += width + 1
	end
end

def create_boards(width, length, count, name, x)
	model = Sketchup.active_model
	entities = model.entities
	if( name != nil )
		new_comp_def = Sketchup.active_model.definitions.add(name)
	else
		new_comp_def = Sketchup.active_model.definitions.add("")
	end

	points = Array.new
	points[0] = [0, 0, 0]
	points[1] = [width, 0, 0]
	points[2] = [width, length, 0]
	points[3] = [0, length, 0]

	new_comp_def.entities.add_face(points)
	if( name != nil )
		# need to use a height of 1 here, otherwise the text is partway under
		# the face and gets hidden (Unless it is moved in the Sketchup app, which
		# seems to fix that.  Bug in the API?)
		point = Geom::Point3d.new( width/2, length/2, 1 )
		new_comp_def.entities.add_text( name, point )
	end

	for i in 1..count
		point = Geom::Point3d.new( x, (i-1)*(length+1), 0 )
		trans = Geom::Transformation.new( point )
		Sketchup.active_model.active_entities.add_instance( new_comp_def, trans )
	end
end

# This converts the input string to a float.  Sure, Ruby has .to_f, but we
# want to support strings of the format "2 1/2".
def str_to_f(str)
	if( str.strip.include? " " )
		# Assume this is a number like "7  5/8"
		nums = str.split(/[ \/]/).reject(&:empty?)
		# The .reject is necessary in case there are multiple spaces in str,
		# which Excel tends to do with fraction formats.
		# Nums is now ["7", "5", "8"].
		return nums[0].to_f + (nums[1].to_f / nums[2].to_f)
	end

	return str.to_f
end
