return {
  'robitx/gp.nvim',
  config = function()
    require('gp').setup {
      providers = {
        openai = {},
        azure = {},
        copilot = {},
        googleai = {},
        ollama = {
          endpoint = 'http://localhost:11434/api/chat',
        },
      },
      agents = {
        {
          name = 'CodeOllamaLlama3.1-8B',
          disable = true,
        },
        {
          name = 'DeepSeekCopderV2',
          chat = true,
          command = true,
          provider = 'ollama',
          model = 'deepseek-coder-v2',
          system_prompt = require('gp.defaults').chat_system_prompt,
        },
      },
    }

    -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
  end,
}
