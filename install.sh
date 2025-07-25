#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Pilih opsi:"
  echo "1) Instalasi"
  echo "2) Clean Uninstall"
  echo "3) Reinit Worker"
  read -p "Masukkan pilihan [1-3]: " MENU_CHOICE

  case $MENU_CHOICE in
    1)
      echo "Melanjutkan ke proses instalasi..."
      # lanjut ke script instalasi (tidak exit)
      ;;
    2)
      exec bash "$0" uninstall
      ;;
    3)
      exec bash "$0" reinit
      ;;
    *)
      echo "Pilihan tidak valid."
      exit 1
      ;;
  esac
fi

if [[ "$1" == "uninstall" ]]; then
  echo "🧹 Melakukan clean uninstall w.ai..."

  # Stop dan hapus semua proses PM2 terkait w.ai
  pm2 stop all
  pm2 delete all

  # Hapus file konfigurasi dan script
  rm -f .env wai.sh rolling-restart.sh

  # Hapus folder .wombo di parent directory jika ada
  rm -rf ../.wombo

  echo "✅ Uninstall selesai. Semua file dan proses w.ai sudah dihapus."
  exit 0
fi

if [[ "$1" == "reinit" ]]; then
  echo "🔄 Re-inisialisasi worker w.ai..."

  # Stop & delete semua proses PM2 (termasuk roller-restart)
  pm2 stop all
  pm2 delete all

  # Hapus rolling-restart.sh agar bisa dibuat ulang jika perlu
  rm -f rolling-restart.sh

  # Minta input jumlah worker baru
  echo ""
  echo "👷 Masukkan jumlah worker baru yang ingin dijalankan:"
  read -p "Jumlah Worker (misal 10): " WORKER_COUNT

  # Cek dan buat .env jika belum ada
  if [[ ! -f .env ]]; then
    echo ""
    echo "🔑 Masukkan API key w.ai kamu:"
    read -p "API_KEY: " API_KEY
    echo "W_AI_API_KEY=$API_KEY" > .env
  fi

  # Buat ulang script wai.sh
  cat <<'EOF' > wai.sh
#!/bin/bash
set -a
source .env
set +a

wai run w.ai
EOF
  chmod +x wai.sh

  # Jalankan worker baru
  for ((i=0; i<WORKER_COUNT; i++)); do
    pm2 start ./wai.sh --name "wai$i"
  done

  # Stop semua worker agar tidak running serentak
  pm2 stop all

  # Buat ulang script rolling-restart.sh
 # 7. Buat script rolling-restart.sh
echo ""
echo "🔁 Membuat script rolling restart..."

WORKER_LAST_INDEX=$((WORKER_COUNT - 1))

cat > rolling-restart.sh <<EOF
#!/bin/bash

# Rolling restart loop untuk semua worker
while true; do
  for i in \$(seq 0 $WORKER_LAST_INDEX); do
    echo "[INFO] Restarting PM2 process wai\$i"
    pm2 restart wai\$i
    sleep 600
  done
done
EOF

chmod +x rolling-restart.sh

  # Jalankan rolling restart dengan PM2
  pm2 start rolling-restart.sh --interpreter bash --name pm2-roller

  # Simpan konfigurasi PM2
  pm2 save

  echo ""
  echo "✅ Worker berhasil di-reinisialisasi menjadi $WORKER_COUNT worker dan rolling restart aktif."
  exit 0
fi

# ----------------------------------------
# 🚀 Auto Setup w.ai di Vast.ai
# By: https://x.com/IamBitcoiner
# ----------------------------------------

echo "🔧 Menginstall w.ai CLI terlebih dahulu..."
curl -fsSL https://app.w.ai/install.sh | bash

echo ""
echo "🔑 Masukkan API key w.ai kamu:"
read -p "API_KEY: " API_KEY

echo ""
echo "👷 Masukkan jumlah worker yang ingin dijalankan:"
read -p "Jumlah Worker (misal 10): " WORKER_COUNT

# 1. Simpan API key ke .env
echo "W_AI_API_KEY=$API_KEY" > .env

# 2. Install Node.js dan PM2
echo ""
echo "📦 Menginstall Node.js dan PM2..."
sudo apt update
sudo apt install nodejs npm -y
npm install -g pm2

# 3. Buat script wai.sh
echo ""
echo "📝 Membuat script wai.sh..."
cat <<'EOF' > wai.sh
#!/bin/bash
set -a
source .env
set +a

wai run w.ai
EOF
chmod +x wai.sh

# 4. Jalankan sekali untuk download model dan generate token
echo ""
echo "🚀 Jalankan proses download model & generate token"

echo ""
echo "✅ W.AI CLI akan dijalankan satu kali sekarang."
echo "⏳ Tunggu hingga proses selesai (akan muncul token di output)."
echo "🛑 Setelah itu, TEKAN CTRL + C untuk menghentikan dan lanjut ke tahap berikutnya."
echo ""
read -p "▶️ Tekan ENTER untuk menjalankan './wai.sh'..."

bash ./wai.sh

echo ""
echo "✅ Setelah kamu menekan CTRL + C dan proses berhenti,"
read -p "➡️ Tekan ENTER untuk lanjut ke setup worker..."

# 5. Jalankan semua worker sesuai jumlah input
echo ""
echo "⚙️  Menjalankan $WORKER_COUNT worker dengan PM2..."
for ((i=0; i<WORKER_COUNT; i++)); do
  pm2 start ./wai.sh --name "wai$i"
done

# 6. Stop semua worker agar tidak crash karena load serentak
echo ""
echo "🛑 Stop semua worker sementara..."
pm2 stop all

# 7. Buat script rolling-restart.sh
echo ""
echo "🔁 Membuat script rolling restart..."
cat <<EOF > rolling-restart.sh
#!/bin/bash

while true; do
  for i in $(seq 0 $((WORKER_COUNT-1))); do
    echo "[INFO] Restarting PM2 process wai$i"
    pm2 restart wai$i
    sleep 600
  done
done
EOF
chmod +x rolling-restart.sh

# 8. Jalankan rolling restart dengan PM2
echo ""
echo "▶️ Menjalankan rolling restart loop..."
pm2 start rolling-restart.sh --interpreter bash --name pm2-roller

# 9. Simpan konfigurasi PM2
echo ""
echo "💾 Menyimpan konfigurasi PM2..."
pm2 save
pm2 startup

# DONE
echo ""
echo "🎉 SETUP SELESAI!"
echo "$WORKER_COUNT worker aktif + rolling restart otomatis setiap 10 menit."
echo "Jika server direstart, jalankan 'pm2 resurrect' untuk restore proses."
