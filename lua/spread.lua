local spread = { }
local ts_utils = require("nvim-treesitter.ts_utils")
local ts_indent = require("nvim-treesitter.indent")
local node_options = require("node_options")

local function flatten(array)
	if type(array) ~= "table" then
		return { array }
	end

	local result = { }

	for _, element in ipairs(array) do
		local flattened_element = flatten(element)

		for _, nested_element in ipairs(flattened_element) do
			table.insert(result, nested_element)
		end
	end

	return result
end

local function is_node_of_interest(node)
	return (
		node_options[node:type()] ~= nil and
		node_options[node:type()].enabled
	)
end

local function get_containing_node(node)
	if node == nil then
		return nil
	end

	if is_node_of_interest(node) then
		return node
	end

	return get_containing_node(node:parent())
end

local function get_fields(node)
	local fields = { }

	for child in node:iter_children() do
		table.insert(
			fields,
			vim.treesitter.query.get_node_text(child, 0)
		)
	end

	return fields
end

local function get_indent_count(line)
	return ts_indent.get_indent(line) / vim.o.tabstop
end

local function indent(str, n)
	if vim.o.expandtab then
		return string.rep(" ", n * vim.o.tabstop) .. str
	end

	return string.rep("\t", n) .. str
end

local function parse_fields_spread(fields, indent_count, type)
	local result = { }

	table.insert(result, table.remove(fields, 1))
	table.insert(
		result,
		indent(table.remove(fields, #fields), indent_count)
	)

	for _ = 1, node_options[type].combine.start do
		result[1] = result[1] .. table.remove(fields, 1)
	end

	for _ = 1, node_options[type].combine.stop do
		result[#result] = table.remove(fields, #fields) .. result[#result]
	end

	for _, field in ipairs(fields) do
		if node_options[type].delimiters[field] ~= nil then
			result[#result - 1] = result[#result - 1] .. field
		else
			table.insert(result, #result, indent(field, indent_count + 1))
		end
	end

	return result
end

local function parse_fields_combine(fields, type)
	if #fields < 2 then
		return fields
	end

	local result = { "", "" }

	for _ = 0, node_options[type].combine.start do
		result[1] = result[1] .. table.remove(fields, 1)
	end

	for _ = 0, node_options[type].combine.stop do
		result[#result] = table.remove(fields, #fields) .. result[#result]
	end

	if node_options[type].padding.start and #fields > 0 then
		result[1] = result[1] .. " "
	end

	if node_options[type].padding.stop and #fields > 0 then
		result[2] = " " .. result[2]
	end

	for _, field in ipairs(fields) do
		if node_options[type].delimiters[field] then
			result[#result - 1] = result[#result - 1] .. field
		else
			table.insert(result, #result, field)
		end
	end

	local concatinated_result = ""

	if node_options[type].delimiter_padding then
		local starting_string = table.remove(result, 1)
		local middle_string = ""
		local ending_string = table.remove(result, #result)

		if #result > 0 then
			middle_string = table.concat(result, " ")
		end

		concatinated_result = starting_string ..
			middle_string ..
			ending_string
	else
		concatinated_result = table.concat(result, "")
	end

	return vim.fn.split(concatinated_result, "\n")
end

function spread.out()
	local starting_node = ts_utils.get_node_at_cursor()
	local node = get_containing_node(starting_node)

	if node == nil then
		return
	end

	local fields = get_fields(node)
	local start_row, start_col, end_row, end_col = node:range()
	local indent_count = get_indent_count(start_row + 1)
	local replace_text = parse_fields_spread(fields, indent_count, node:type())

	for i, _ in ipairs(replace_text) do
		replace_text[i] = vim.fn.split(replace_text[i], "\n")
	end

	replace_text = flatten(replace_text)

	vim.api.nvim_buf_set_text(
		0,
		start_row,
		start_col,
		end_row,
		end_col,
		replace_text
	)
end

local function recursive_combine(node)
	local children = ts_utils.get_named_children(node)

	for _, child in ipairs(children) do
		recursive_combine(child)
	end

	if not is_node_of_interest(node) then
		return
	end

	local fields = get_fields(node)
	local start_row, start_col, end_row, end_col = node:range()
	local replace_text = parse_fields_combine(fields, node:type())

	vim.api.nvim_buf_set_text(
		0,
		start_row,
		start_col,
		end_row,
		end_col,
		replace_text
	)
end

function spread.combine()
	local starting_node = ts_utils.get_node_at_cursor()
	local node = get_containing_node(starting_node)

	if node == nil then
		return
	end

	recursive_combine(node)
end

return spread
