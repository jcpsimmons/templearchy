-- ============================================================================
-- DASHBOARD
-- ============================================================================
-- Don't load dashboard in VSCode - VSCode has its own welcome screen
if vim.g.vscode then
    return {}
end

return {{
    "goolord/alpha-nvim",
    dependencies = {"nvim-tree/nvim-web-devicons", "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        local logo = [[
                                ...----....
                         ..-:"''         ''"-..
                      .-'                      '-.
                    .'              .     .       '.
                  .'   .          .    .      .    .''.
                .'  .    .       .   .   .     .   . ..:.
              .' .   . .  .       .   .   ..  .   . ....::.
             ..   .   .      .  .    .     .  ..  . ....:IA.
            .:  .   .    .    .  .  .    .. .  .. .. ....:IA.
           .: .   .   ..   .    .     . . .. . ... ....:.:VHA.
           '..  .  .. .   .       .  . .. . .. . .....:.::IHHB.
          .:. .  . .  . .   .  .  . . . ...:.:... .......:HIHMM.
         .:.... .   . ."::"'.. .   .  . .:.:.:II;,. .. ..:IHIMMA
         ':.:..  ..::IHHHHHI::. . .  ...:.::::.,,,. . ....VIMMHM
        .:::I. .AHHHHHHHHHHAI::. .:...,:IIHHHHHHMMMHHL:. . VMMMM
       .:.:V.:IVHHHHHHHMHMHHH::..:" .:HIHHHHHHHHHHHHHMHHA. .VMMM.
       :..V.:IVHHHHHMMHHHHHHHB... . .:VPHHMHHHMMHHHHHHHHHAI.:VMMI
       ::V..:VIHHHHHHMMMHHHHHH. .   .I":IIMHHMMHHHHHHHHHHHAPI:WMM
       ::". .:.HHHHHHHHMMHHHHHI.  . .:..I:MHMMHHHHHHHHHMHV:':H:WM
       :: . :.::IIHHHHHHMMHHHHV  .ABA.:.:IMHMHMMMHMHHHHV:'. .IHWW
       '.  ..:..:.:IHHHHHMMHV" .AVMHMA.:. "VMMHHHP.:... .. :IVAI
       .:.   '... .:"'   .   ..HMMMHMMMA::. ."VHHI:::....  .:IHW'
       ...  .  . ..:IIPPIH: ..HMMMI.MMMV:I:.  .:ILLH:.. ...:I:IM
     : .   .'"' .:.V". .. .  :HMMM:IMMMI::I. ..:HHIIPPHI::'.P:HM.
     :.  .  .  .. ..:.. .    :AMMM IMMMM..:...:IV":T::I::.".:IHIMA
     'V:.. .. . .. .  .  .   'VMMV..VMMV :....:V:.:..:....::IHHHMH
       "IHH:.II:.. .:. .  . . . " :HB"" . . ..PI:.::.:::..:IHHMMV"
      ]]

        dashboard.section.header.val = vim.split(logo, "\n")

        -- Split logo into lines
        local logoLines = {}
        for line in logo:gmatch("[^\r\n]+") do
            table.insert(logoLines, line)
        end

        local builtin = require("telescope.builtin")
        dashboard.section.buttons.val = {dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
                                         dashboard.button("r", " Search Recent Files", builtin.oldfiles),
                                         dashboard.button("q", "󰅚  Quit", ":qa<CR>"), {
            type = "padding",
            val = 2
        }}

        -- Set footer
        local footer = [[
     
      [...] begin every action with the following question:
      "Who am I, that I choose to prefer my own will and desires to the will of God and His command?"
      In addition, strictly follow the commandment of Christ to never judge anyone.
      - St. Pitirm
    ]]

        dashboard.section.footer.val = footer
        dashboard.section.footer.type = "text"
        dashboard.section.footer.opts = {
            position = "center",
            hl = "Number"
        }

        -- Keymaps
        vim.keymap.set("n", "<leader>a", ":Alpha<CR>", {
            desc = "Goto Greeter Screen"
        })
        alpha.setup(dashboard.opts)
    end
}}
