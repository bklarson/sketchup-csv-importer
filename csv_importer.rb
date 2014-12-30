require 'sketchup.rb'

# SKETCHUP_CONSOLE.show

UI.menu("Plugins").add_item("Plywood Cuts") {
	plywood_cuts
}

def plywood_cuts
	model = Sketchup.active_model
	entities = model.entities

	prompts = ["Name", "Number", "Length", "Width"]
	defaults = ["", "1", "6", "9"]
	inputs = UI.inputbox(prompts, defaults, "Give me some dimensions!")

	name = inputs[0]
	number = inputs[1].to_f
	length = inputs[2].to_f
	width = inputs[3].to_f

	new_comp_def = Sketchup.active_model.definitions.add(name)

	points = Array.new
	points[0] = [0, 0, 0]
	points[1] = [width, 0, 0]
	points[2] = [width, length, 0]
	points[3] = [0, length, 0]
	new_comp_def.entities.add_face(points)
	# need to use a height of 1 here, otherwise the text is partway under
	# the face and gets hidden (Unless it is moved in the Sketchup app, which
	# seems to fix that.  Bug in the API?)
	point = Geom::Point3d.new( width/2, length/2, 1 )
	new_comp_def.entities.add_text( name, point )

	for x in 1..number
		point = Geom::Point3d.new( 0, (x-1)*(length+1), 0 )
		trans = Geom::Transformation.new( point )
		Sketchup.active_model.active_entities.add_instance( new_comp_def, trans )
	end
end

