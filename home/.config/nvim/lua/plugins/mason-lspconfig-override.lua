return {
  "williamboman/mason-lspconfig.nvim",
  -- Épinglez à la version v1.4.0
  -- Vous pouvez utiliser un tag, une branche, ou un commit SHA complet
  version = "v1.4.0",
  -- Alternativement, pour utiliser le commit spécifique avant v2.0.0 de votre log :
  -- version = "a3f07c3d86b090a23509721d9976551f8140a854", -- (SHA complet est plus sûr)

  -- Assurez-vous que les dépendances sont toujours correctes
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  -- Vous pouvez aussi inclure d'autres options de configuration ici
  -- si vous en aviez pour ce plugin. Pour l'instant, on se concentre
  -- sur le versionnage.
}
