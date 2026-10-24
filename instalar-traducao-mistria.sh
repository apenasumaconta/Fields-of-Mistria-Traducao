```bash
#!/usr/bin/env bash

set -e

L10N_URL="https://raw.githubusercontent.com/apenasumaconta/Fields-of-Mistria-Traducao/main/l10n.meta.toml"
SPA_URL="https://raw.githubusercontent.com/apenasumaconta/Fields-of-Mistria-Traducao/main/spa.meta.toml"

GAME_NAME="Fields of Mistria"

echo "========================================"
echo " Fields of Mistria - Tradução"
echo "========================================"
echo

find_game() {
    local steam_paths=(
        "/c/Program Files (x86)/Steam"
        "/c/Program Files/Steam"
        "/d/Steam"
        "/d/SteamLibrary"
        "/e/Steam"
        "/e/SteamLibrary"
        "/f/Steam"
        "/f/SteamLibrary"
    )

    for steam_path in "${steam_paths[@]}"; do
        local game_path="$steam_path/steamapps/common/$GAME_NAME"

        if [ -f "$game_path/assets.zip" ]; then
            echo "$game_path"
            return 0
        fi
    done

    return 1
}

echo "A procurar pelo Fields of Mistria..."

GAME_DIR=$(find_game || true)

if [ -z "$GAME_DIR" ]; then
    echo
    echo "Não foi possível encontrar o Fields of Mistria automaticamente."
    echo
    echo "Introduza o caminho da pasta do jogo."
    echo "Exemplo:"
    echo "D:/SteamLibrary/steamapps/common/Fields of Mistria"
    echo

    read -p "Caminho do jogo: " GAME_DIR

    GAME_DIR="${GAME_DIR%/}"
fi

if [ ! -d "$GAME_DIR" ]; then
    echo
    echo "ERRO: A pasta não existe:"
    echo "$GAME_DIR"
    exit 1
fi

if [ ! -f "$GAME_DIR/assets.zip" ]; then
    echo
    echo "ERRO: O ficheiro assets.zip não foi encontrado em:"
    echo "$GAME_DIR"
    exit 1
fi

echo
echo "Jogo encontrado:"
echo "$GAME_DIR"
echo

cd "$GAME_DIR"

TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

echo "[1/7] A transferir os ficheiros da tradução..."

curl -L --fail "$L10N_URL" \
    -o "$TEMP_DIR/l10n.meta.toml"

curl -L --fail "$SPA_URL" \
    -o "$TEMP_DIR/spa.meta.toml"

echo "[2/7] A criar uma cópia de segurança..."

if [ -f "assets.zip.backup" ]; then
    rm -f "assets.zip.backup"
fi

cp "assets.zip" "assets.zip.backup"

echo "[3/7] A extrair o assets.zip..."

rm -rf "assets"

unzip -q "assets.zip"

if [ ! -d "assets" ]; then
    echo "ERRO: Não foi possível extrair o assets.zip."
    exit 1
fi

echo "[4/7] A instalar o l10n.meta.toml..."

LOCALIZATION_DIR="assets/localization"

if [ ! -d "$LOCALIZATION_DIR" ]; then
    echo "ERRO: A pasta de localização não foi encontrada:"
    echo "$LOCALIZATION_DIR"
    exit 1
fi

cp "$TEMP_DIR/l10n.meta.toml" \
    "$LOCALIZATION_DIR/l10n.meta.toml"

echo "[5/7] A instalar o spa.meta.toml..."

TRANSLATIONS_DIR="$LOCALIZATION_DIR/translations"

if [ ! -d "$TRANSLATIONS_DIR" ]; then
    echo "ERRO: A pasta de traduções não foi encontrada:"
    echo "$TRANSLATIONS_DIR"
    exit 1
fi

cp "$TEMP_DIR/spa.meta.toml" \
    "$TRANSLATIONS_DIR/spa.meta.toml"

echo "[6/7] A criar o novo assets.zip..."

rm -f "assets.new.zip"

zip -q -0 -r "assets.new.zip" "assets"

if [ ! -f "assets.new.zip" ]; then
    echo "ERRO: Não foi possível criar o novo assets.zip."
    exit 1
fi

rm -f "assets.zip"
mv "assets.new.zip" "assets.zip"

echo "[7/7] A limpar os ficheiros temporários..."

rm -rf "assets"

echo
echo "========================================"
echo " Tradução instalada com sucesso!"
echo "========================================"
echo
echo "Abra o Fields of Mistria e selecione:"
echo
echo "Definições -> Idioma -> Espanhol"
echo
echo "Cópia de segurança criada em:"
echo "$GAME_DIR/assets.zip.backup"
echo
echo "Já pode fechar esta janela."
echo

read -p "Prima Enter para sair..."
```