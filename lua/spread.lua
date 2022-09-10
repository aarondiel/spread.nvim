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

local function get_containing_node(node)
	if node == nil then
		return nil
	end

	if (
		node_options[node:type()] ~= nil and
		node_options[node:type()].enabled
	) then
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

	if node_options[type].tag_node then
		result[1] = result[1] .. table.remove(fields, 1)
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
	local result = { }

	if node_options[type].padding then
		table.insert(result, table.remove(fields, 1) .. " ")
		table.insert(result, " " .. table.remove(fields, #fields))
	else
		table.insert(result, table.remove(fields, 1))
		table.insert(result, table.remove(fields, #fields))
	end

	if node_options[type].self_closing_tag then
		result[1] = result[1] .. table.remove(fields, 1)

		if not node_options[type].pad_self_closing_tag then
			result[#result] = table.remove(fields, #fields) .. result[#result]
		end
	end

	for _, field in ipairs(fields) do
		local pad_delimiter = (
			node_options[type].delimiters[field] ~= nil and
			node_options[type].delimiter_padding
		)

		if pad_delimiter then
			table.insert(result, #result, field .. " ")
		else
			table.insert(result, #result, field)
		end
	end

	if node_options[type].space_delimiter then
		return { table.concat(result, " ") }
	end

	local concatinated_result = table.concat(result, "")

	return { vim.fn.substitute(concatinated_result, "\n", "", "g") }
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

function spread.combine()
	local starting_node = ts_utils.get_node_at_cursor()
	local node = get_containing_node(starting_node)

	if node == nil then
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

return spread
