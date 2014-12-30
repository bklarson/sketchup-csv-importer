require 'sketchup.rb'

SKETCHUP_CONSOLE.show

UI.menu("Plugins").add_item("Plywood Cuts") {
	UI.messagebox("I'm about to Cut some Wood!")
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
 
 for x in 1..number
 	x1 = 0
	x2 = width
	y1 = (x - 1) * (length + 1)
	y2 = y1 + length
	
	new_comp_def = Sketchup.active_model.definitions.add(name)

	points = Array.new
	points[0] = [x1, y1, 0]
	points[1] = [x2, y1, 0]
	points[2] = [x2, y2, 0]
	points[3] = [x1, y2, 0]

	new_face = new_comp_def.entities.add_face(points)
	trans = Geom::Transformation.new
	Sketchup.active_model.active_entities.add_instance(new_comp_def,trans);

 end
end

