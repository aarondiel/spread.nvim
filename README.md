<h1 align="center">spread.nvim</h1>

<p align="center"><img width=500 src="assets/spread.webp"/></p>

<p align="center">
	a plugin to refactor and spread out objects, arrays, parameter lists, etc
	onto multiple lines.
</p>

<p align="center">
	this plugin is still <em>work in progress</em>, so don't expect it to work
	with every language and container.
</p>

## installation

> this plugin uses [treesitter][nvim-treesitter] so be sure to also install it

using [packer][packer]:

```lua
use({
	"aarondiel/spread.nvim",
	after = "nvim-treesitter",
	config = function()
		local spread = require("spread")
		local default_options = {
			silent = true,
			noremap = true
		}

		vim.keymap.add("n", "<leader>ss", spread.out, default_options)
		vim.keymap.add("n", "<leader>ssc", spread.combine, default_options)
	end
})
```

[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[packer]: https://github.com/wbthomason/packer.nvim
