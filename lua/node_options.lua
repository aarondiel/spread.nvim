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
	enabled = true,
	padding = false,
	space_delimiter = false,
	delimiter_padding = false,
	self_colsing_tag = false,
	pad_self_closing_tag = false,
	delimiters = { }
}

local node_options = { }

node_options.block = {
	delimiter_padding = true,
	delimiters = { [ ";" ] = true },
	padding = true
}

node_options.object = {
	delimiter_padding = true,
	delimiters = { [ "," ] = true },
	padding = true
}

node_options.named_imports = node_options.object
node_options.table_constructor = node_options.object
node_options.array = node_options.object
node_options.array_pattern = node_options.object

node_options.parameters = {
	delimiter_padding = true,
	delimiters = { [ "," ] = true }
}

node_options.arguments = node_options.parameters
node_options.formal_parameters = node_options.parameters
node_options.type_parameters = node_options.parameters
node_options.type_arguments = node_options.parameters

node_options.self_closing_tag = {
	self_closing_tag = true,
	pad_self_closing_tag = true
}

node_options.element = { }

return overwrite_default_options(default_config, node_options)
