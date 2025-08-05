# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.
# 📖 Récapitulatif des commandes Neovim

## ✂️ Édition de texte
| Commande | Description |
|----------|------------|
| `ci)`    | Supprime et édite à l'intérieur des `()` |
| `ca)`    | Supprime et édite avec les `()` |
| `ci"`    | Supprime et édite à l'intérieur des `""` |
| `ca"`    | Supprime et édite avec les `""` |
| `cw`     | Supprime et édite le mot à partir du curseur |
| `ciw`    | Supprime et édite le mot |
| `g U`    | Passer du texte en uppercase |
| `g u`    | Passer du texte en lowercase |
| `J`      | Pour joindre 2 lignes |
| `<<`     | indent left |
| `>>`     | indent right |
| `%s/search/replace/g` | Pour sed un fichier |
| `<leader>r`| Met la ligne entre `{}` et indent |

## 📌 Navigation
| Commande | Description |
|----------|------------|
| `<leader>e`| Ouvre le navigateur de fichier |
| `vs <filename>`| Ouvre filename (ou le même fichier si vide) dans un split vertical |
| `sp <filename>`| Ouvre filename (ou le même fichier si vide) dans un split horizontal |
| `*`      | Highlight un mot |
| `n`      | Prochaine iteration du mot |
| `N`      | Précédente iteration du mot |
| `.`      | Répète la dernière action |
| `gg`     | Aller en haut du fichier |
| `G`      | Aller en bas du fichier |
| `Ctrl f` | Descend d'un écran |
| `Ctrl b` | Monte d'un écran |
| `w`      | Aller au mot suivant |
| `b`      | Aller au mot précédent |
| `K`      | Ouvre la page du manuel du mot sous le curseur |

## 📜 Macros
| Commande | Description |
|----------|------------|
| `q<reg><commands>q` | Reccord macro with the register reg |
| `:reg` | display registers |
| `:reg <reg>` | display reg |
| `@<reg>` | replay reg |
| `@@` | repeat last macro |
| `<x>@<reg>` | replay x times reg |
| `<x>@@` | repeat x times last macro |

## 🔧 Manipulation avancée
```vim
:sort        	" Trier les lignes
:!ls         	" Exécuter une commande shell
:!r<filename>	" Importe filename dans le document actuel
