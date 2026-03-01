return {
  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
      },
      keys = {
        { "<leader><leader>",  group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c",         group = "[c]ode" },
        { "<leader>c_",        hidden = true },
        { "<leader>d",         group = "[d]ocument" },
        { "<leader>d_",        hidden = true },
        { "<leader>g",         group = "[g]it" },
        { "<leader>g_",        hidden = true },
        { "<leader>m",         group = "[m]arkdown" },
        { "<leader>m_",        hidden = true },
        { "<leader>r",         group = "[r]ename" },
        { "<leader>r_",        hidden = true },
        { "<leader>s",         group = "[s]earch" },
        { "<leader>s_",        hidden = true },
        { "<leader>t",         group = "[t]oggles" },
        { "<leader>t_",        hidden = true },
        { "<leader>w",         group = "[w]orkspace" },
        { "<leader>w_",        hidden = true },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
      wk.add(opts.keys)
    end,
  },
}
