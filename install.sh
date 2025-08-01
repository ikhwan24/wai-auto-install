#!/bin/bash

generate_wai_script() {
  cat <<'EOF' > wai.sh
#!/bin/bash
set -a
source .env
set +a

wai run w.ai
EOF
  chmod +x wai.sh
}

generate_rolling_restart_script() {
  local COUNT=$1
  local LAST_INDEX=$((COUNT - 1))

  cat > rolling-restart.sh <<EOF
#!/bin/bash

# Rolling restart loop untuk semua worker
while true; do
  for i in \$(seq 0 $LAST_INDEX); do
    echo "[INFO] Restarting PM2 process wai\$i"
    pm2 restart wai\$i
    sleep 600
  done
done
EOF

  chmod +x rolling-restart.sh
}

install_dependencies() {
  echo "📦 Menginstall Node.js dan PM2..."
  sudo apt update
  sudo apt install jq
  sudo apt install nodejs npm -y
  npm install -g pm2
}

setup_workers() {
  local COUNT=$1
  for ((i=0; i<COUNT; i++)); do
    pm2 start ./wai.sh --name "wai$i"
  done
  pm2 stop all
}

save_pm2_config() {
  pm2 start rolling-restart.sh --interpreter bash --name pm2-roller
  pm2 save
  pm2 startup
}

# =================== MENU ===================

if [[ -z "$1" ]]; then
  echo "Pilih opsi:"
  echo "1) Instalasi"
  echo "2) Clean Uninstall"
  echo "3) Reinit Worker"
  read -p "Masukkan pilihan [1-3]: " MENU_CHOICE

  case $MENU_CHOICE in
    1) ;;
    2) exec bash "$0" uninstall ;;
    3) exec bash "$0" reinit ;;
    *) echo "Pilihan tidak valid."; exit 1 ;;
  esac
fi

# =================== UNINSTALL ===================

if [[ "$1" == "uninstall" ]]; then
  echo "🧹 Melakukan clean uninstall w.ai..."
  pm2 stop all
  pm2 delete all
  rm -f .env wai.sh rolling-restart.sh
  rm -rf ../.wombo
  echo "✅ Uninstall selesai. Semua file dan proses w.ai sudah dihapus."
  exit 0
fi

# =================== REINIT ===================

if [[ "$1" == "reinit" ]]; then
  echo "🔄 Re-inisialisasi worker w.ai..."
  pm2 stop all
  pm2 delete all
  rm -f rolling-restart.sh

  echo ""
  echo "👷 Masukkan jumlah worker baru:"
  read -p "Jumlah Worker: " WORKER_COUNT

  if ! [[ "$WORKER_COUNT" =~ ^[0-9]+$ ]]; then
    echo "❌ Jumlah worker harus angka."
    exit 1
  fi

  if [[ ! -f .env ]]; then
    echo "🔑 Masukkan API key w.ai kamu:"
    read -p "API_KEY: " API_KEY
    if [[ -z "$API_KEY" ]]; then echo "❌ API Key tidak boleh kosong."; exit 1; fi
    echo "W_AI_API_KEY=$API_KEY" > .env
  fi

  generate_wai_script
  setup_workers "$WORKER_COUNT"
  generate_rolling_restart_script "$WORKER_COUNT"
  save_pm2_config

  echo "✅ Worker berhasil di-reinisialisasi ($WORKER_COUNT worker aktif + rolling restart)."
  exit 0
fi

# =================== INSTALL ===================

echo "🔧 Menginstall w.ai CLI..."
curl -fsSL https://app.w.ai/install.sh | bash

echo ""
echo "🔑 Masukkan API key w.ai kamu:"
read -p "API_KEY: " API_KEY
if [[ -z "$API_KEY" ]]; then echo "❌ API Key tidak boleh kosong."; exit 1; fi

echo ""
echo "👷 Masukkan jumlah worker:"
read -p "Jumlah Worker: " WORKER_COUNT
if ! [[ "$WORKER_COUNT" =~ ^[0-9]+$ ]]; then echo "❌ Jumlah worker harus angka."; exit 1; fi

echo "W_AI_API_KEY=$API_KEY" > .env

install_dependencies
generate_wai_script

echo ""
echo "🚀 Jalankan proses download model (CTRL + C setelah token keluar)"
read -p "▶️ Tekan ENTER untuk menjalankan './wai.sh'..."
bash ./wai.sh

echo ""
read -p "➡️ Tekan ENTER untuk lanjut ke setup worker..."

setup_workers "$WORKER_COUNT"
generate_rolling_restart_script "$WORKER_COUNT"
save_pm2_config

echo ""
echo "🎉 SETUP SELESAI!"
echo "$WORKER_COUNT worker aktif + rolling restart otomatis setiap 10 menit."
echo "Jika server direstart, jalankan 'pm2 resurrect' untuk restore proses."
