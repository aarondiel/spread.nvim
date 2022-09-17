local function combine(...)
	local result = { }

	for _, current_table in pairs({ ... }) do
		for index, element in pairs(current_table) do
			result[index] = element
		end
	end

	return result
end

local function overwrite_default_options(defaults, options)
	local result = { }

	for node, _ in pairs(options) do
		result[node] = combine(defaults, options[node])
	end

	return result
end

local default_config = {
	-- enable or disable a node for spreading
	enabled = true,

	-- if padding should be added or not
	padding = {
		-- add padding to the start, e.g. {1, 2, 3} vs. { 1, 2, 3}
		start = false,

		-- add padding to the end, e.g. {1, 2, 3} vs. {1, 2, 3 }
		stop = false
	},

	-- if delimiters should be padded or not, e.g. {1,2,3} vs. {1, 2, 3}
	-- this option also works without specifying any delimiters, it will simply
	-- add a space between each element
	delimiter_padding = false,

	-- if nodes should be combined at either the start or at the end of the node
	-- this is especially imporant for tag nodes where for instance "<" and "img"
	-- would be put on seperate lines otherwise
	-- the number specifies how many nodes should be combined
	combine = {
		start = 0,
		stop = 0
	},

	-- specify delimiters for the node, for instance
	-- delimiters = { [ "," ] = true } for something like a table / array
	-- ({ 1, 2, 3 }) where the comma seperates the individual elements
	-- this is needed for the delimiters not to be put on their own seperate
	-- lines or to add delimiter_padding
	delimiters = { }
}

local node_options = { }

node_options.block = {
	delimiter_padding = true,
	delimiters = { [ ";" ] = true },
	padding = {
		start = true,
		stop = true
	}
}

node_options.array_type = node_options.block

node_options.object = {
	delimiter_padding = true,
	delimiters = { [ "," ] = true },
	padding = {
		start = true,
		stop = true
	}
}

node_options.object_type = node_options.object
node_options.tuple_type = node_options.object
node_options.named_imports = node_options.object
node_options.table_constructor = node_options.object
node_options.array = node_options.object
node_options.array_pattern = node_options.object
node_options.array_expression = node_options.object
node_options.list = node_options.object
node_options.dictionary = node_options.object
node_options.initializer_list = node_options.object

node_options.parameters = {
	delimiter_padding = true,
	delimiters = { [ "," ] = true }
}

node_options.arguments = node_options.parameters
node_options.formal_parameters = node_options.parameters
node_options.type_parameters = node_options.parameters
node_options.type_arguments = node_options.parameters
node_options.parameter_list = node_options.parameters
node_options.argument_list = node_options.parameters
node_options.tuple = node_options.parameters

node_options.self_closing_tag = {
	delimiter_padding = true,
	combine = {
		start = 1,
		stop = 0
	},

	padding = {
		start = true,
		stop = false
	}
}

node_options.start_tag = node_options.self_closing_tag

node_options.element = {}

return overwrite_default_options(default_config, node_options)
