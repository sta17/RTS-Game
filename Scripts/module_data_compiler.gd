extends RefCounted
# Module Constants
# --------------------------------------------
# Allows a single place to see all the constants in the project
# --------------------------------------------

const M_C = preload("res://Scripts/module_constants.gd")
const M_F_M = preload("res://Scripts/module_file_manager.gd")

static func encode_data_to_string(text:String) -> String:
	return Marshalls.utf8_to_base64(text)
	
static func decode_data_to_string(text:String) -> String:
	return Marshalls.base64_to_utf8(text)

static func compile_csvdata_files() -> void:
	for file in DirAccess.get_files_at(M_C.PATH_FOLDER_DATA):
		if file.ends_with(M_C.FORMAT_CSVDATA):
			M_F_M.Encode_Data_File(M_C.PATH_FOLDER_DATA + file)

static func build_data_dictionaries(dictonaries:Dictionary) -> void:
	var dict_names:Array = dictonaries.keys()
	var dict_vars:Array = dictonaries.values()
	
	var i:int = 0
	for dict in dict_names:
		
		# grab the dictonary data file
		for file in DirAccess.get_files_at(M_C.PATH_FOLDER_DATA):
			if file.count(dict) and file.ends_with(M_C.FORMAT_DATA):
				var encoded_data:String = M_F_M.Load_Text_file(M_C.PATH_FOLDER_DATA + file)
				var decoded_data:String = decode_data_to_string(encoded_data)
				var all_csv_lines:PackedStringArray = decoded_data.split("\r\n")
				dictonaries[ dict_names[i] ] = data_parse_CSV(all_csv_lines)
				#dict_vars[i] = data_parse_CSV(all_csv_lines)
				
		i += i
		
	pass

static func data_parse_CSV(all_csv_lines:PackedStringArray) -> Dictionary:
	var stored_csv_dict:Dictionary = {} # Returned dict
	if all_csv_lines.size() > 1: # IS DATA PASSED VALID? 2 lines minimum (HEADER: DATA)
		var csv_headers_processed:bool = false
		var csv_line_headers:Array = []
		for csv_line in all_csv_lines: # for a string line of the csv data file. -------------------- CSV PROCESS LINE
			if !csv_line.is_empty(): # IGNORE EMPTY STRINGS, LIKE END OF LINE
				# ["a,b,c,d"]
				var first_cell:String = csv_line[0]
				if (!first_cell.begins_with("#") and # NOT BEGINS AS A COMMENT     #
					first_cell != ";" and 			 # NOT HAVE ONLY DELIMITERS    ;
					first_cell != ""				 # NOT HAVE ONLY BLANK STRINGS ""
				): #THIS STRING CSV LINE is VALID
					#print("PROCESSING VALID CSV STRING LINE : ", csv_line)
					var csv_splitted_data:PackedStringArray = csv_line.split(";")
					
					# PROCESS CSV LINE HEADERS
					if !csv_headers_processed:
						var i:int = 0
						for header in csv_splitted_data:
							csv_line_headers.append( str_to_var(csv_splitted_data[i]) )
							i += 1
						csv_headers_processed = true
					
					else: # PROCESS CSV LINE PIECES
						var entry_id = str_to_var( csv_splitted_data[0])
						var csv_i:int = 0
						for csv_data in csv_splitted_data: # for entry from same csv line. --------- CSV PROCCES LINE PICES
							if !stored_csv_dict.keys().has(entry_id):
								# create id if not present.
								stored_csv_dict[entry_id] = {}
							stored_csv_dict[entry_id][ csv_line_headers[csv_i] ] = str_to_var(csv_data)
							csv_i += 1
	
	return stored_csv_dict
