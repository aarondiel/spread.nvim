local spread = {}
local ts_utils = require("nvim-treesitter.ts_utils")
local ts_indent = require("nvim-treesitter.indent")

local containing_nodes = {
	table_constructor = true,
	parameters = true
}

local function get_containing_node(node)
	if node == nil then
		return nil
	end

	if containing_nodes[node:type()] then
		return node
	end

	return get_containing_node(node:parent())
end

local function get_fields(node)
	local fields = {}

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

local function parse_fields(fields, indent_count, result)
	if #fields == 0 then
		return result
	end

	local field = table.remove(fields, 1)

	if field == "{" then
		table.insert(result, field)
	elseif field == "}" then
		table.insert(result, indent(field, indent_count))
	elseif field == "," then
		result[#result] = result[#result] .. ","
	else
		table.insert(result, indent(field, indent_count + 1))
	end

	return parse_fields(fields, indent_count, result)
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
	local replace_text = parse_fields(fields, indent_count, {})

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
end

return spread
