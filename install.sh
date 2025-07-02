#!/bin/bash

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
echo "🚀 Jalankan ./wai.sh sekali untuk download model & token..."
./wai.sh

echo ""
echo "✅ Setelah token muncul dan model selesai terdownload,"
echo "➡️  Tekan CTRL + C untuk lanjut setup worker."
read -p "Tekan ENTER setelah kamu tekan CTRL + C..."

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
  for i in \$(seq 0 $((WORKER_COUNT-1))); do
    echo "[INFO] Restarting PM2 process \$i"
    pm2 restart \$i
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
