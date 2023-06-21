require("vimOption")
require("plugins")
require("remap")

function isModuleAvailable(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

if isModuleAvailable("nvim-treesitter.configs") then
    require("treesitterSetup")
end
require("lualineSetup")
require("lspzeroSetup")
require("telescopeSetup")
