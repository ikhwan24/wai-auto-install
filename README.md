<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
</head>
<body>

<h1>🚀 Auto Installer W.AI di Vast.ai</h1>
<p>Script ini akan meng-<strong>otomatisasi semua proses setup</strong> W.AI di VPS atau container seperti Vast.ai — hanya dengan satu kali jalan!</p>

<h2>✨ Fitur Utama</h2>
<ul>
  <li>✅ Install W.AI CLI otomatis (<code>curl -fsSL ...</code>)</li>
  <li>✅ Input API Key dari pengguna</li>
  <li>✅ Input jumlah worker fleksibel (misal: 5, 10, dll)</li>
  <li>✅ Jalankan <code>install.sh</code> sekali untuk download model & generate token</li>
  <li>✅ Start semua worker pakai PM2</li>
  <li>✅ Rolling restart otomatis setiap 10 menit</li>
  <li>✅ PM2 save dan setup agar bertahan setelah reboot (di luar Vast.ai)</li>
</ul>

<h2>📦 Persyaratan</h2>
<ul>
  <li>Sistem operasi: <strong>Ubuntu</strong></li>
  <li>Akses root (<code>sudo</code>)</li>
  <li>Sudah memiliki API key dari <a href="https://app.w.ai" target="_blank">https://app.w.ai</a></li>
</ul>

<h2>🔧 Cara Instalasi</h2>

<h3>1. Clone dari GitHub</h3>
<pre><code>git clone https://github.com/ikhwan24/wai-auto-install.git
cd wai-auto-install
chmod +x install.sh
./install.sh</code></pre>

<h3>2. Ikuti Instruksi</h3>
<ul>
  <li>Masukkan API Key kamu saat diminta</li>
  <li>Tentukan jumlah worker (misal: <code>10</code>)</li>
  <li>Script akan otomatis:
    <ul>
      <li>Install dependensi</li>
      <li>Download W.AI model</li>
      <li>Setup PM2 dan rolling restart</li>
    </ul>
  </li>
</ul>

<h2>📁 Struktur File yang Dibuat</h2>
<table>
  <thead>
    <tr>
      <th>File</th>
      <th>Fungsi</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>.env</code></td>
      <td>Simpan API key (<code>W_AI_API_KEY</code>)</td>
    </tr>
    <tr>
      <td><code>install.sh</code></td>
      <td>Script utama untuk setup W.AI + worker + rolling restart</td>
    </tr>
    <tr>
      <td><code>wai.sh</code></td>
      <td>Script untuk menjalankan <code>wai run w.ai</code></td>
    </tr>
    <tr>
      <td><code>rolling-restart.sh</code></td>
      <td>Loop restart worker satu per satu tiap 10 menit</td>
    </tr>
    <tr>
      <td>PM2 Process</td>
      <td>Worker: <code>wai0</code> s/d <code>waiN</code><br>Roller: <code>pm2-roller</code></td>
    </tr>
  </tbody>
</table>

<h2>🔄 Tentang Rolling Restart</h2>
<p>Worker akan direstart satu per satu setiap 10 menit untuk <strong>menghindari crash saat loading model</strong>.</p>
<pre><code>pm2 restart wai0
sleep 600
pm2 restart wai1
sleep 600
...</code></pre>

<h2>🔁 PM2 Otomatis Saat Reboot</h2>
<pre><code>pm2 save
pm2 startup</code></pre>
<p>⚠️ Di <strong>Vast.ai</strong>, proses startup tidak otomatis persist. Gunakan VPS biasa jika ingin ini aktif.</p>

<p>Untuk menghidupkan ulang secara manual:</p>
<pre><code>pm2 resurrect</code></pre>

<h2>💡 Tips Tambahan</h2>
<p><strong>Cek status:</strong></p>
<pre><code>pm2 ls</code></pre>

<p><strong>Cek log:</strong></p>
<pre><code>pm2 logs</code></pre>

<h2>🙋 Kontak Bantuan</h2>
<ul>
  <li><a href="https://x.com/IamBitcoiner" target="_blank">https://x.com/IamBitcoiner</a></li>
</ul>

<h2>🆕 Fitur Baru</h2>
<ul>
  <li><strong>Menu Interaktif:</strong> Saat menjalankan <code>./install.sh</code> tanpa argumen, akan muncul menu pilihan:
    <ul>
      <li>1) Instalasi</li>
      <li>2) Clean Uninstall</li>
      <li>3) Reinit Worker</li>
    </ul>
  </li>
  <li><strong>Clean Uninstall:</strong> Menghapus semua proses PM2, file konfigurasi (<code>.env</code>, <code>wai.sh</code>, <code>rolling-restart.sh</code>), dan folder <code>.wombo</code> (di parent directory).<br>
    <em>Cara pakai:</em> <code>./install.sh uninstall</code> <br>atau pilih opsi 2 di menu.</li>
  <li><strong>Reinit Worker:</strong> Menghapus semua worker & rolling restart, lalu membuat ulang sesuai jumlah baru yang diinput user. File <code>wai.sh</code>, <code>rolling-restart.sh</code>, dan <code>.env</code> (jika belum ada) akan dibuat ulang.<br>
    <em>Cara pakai:</em> <code>./install.sh reinit</code> <br>atau pilih opsi 3 di menu.</li>
</ul>

<h2>📝 Panduan Menu Interaktif</h2>
<ol>
  <li>Jalankan <code>./install.sh</code> (atau <code>bash install.sh</code>).</li>
  <li>Pilih salah satu opsi:
    <ul>
      <li><strong>1) Instalasi</strong>: Proses setup seperti biasa.</li>
      <li><strong>2) Clean Uninstall</strong>: Menghapus semua worker, rolling restart, file konfigurasi, dan folder <code>.wombo</code> di parent directory.</li>
      <li><strong>3) Reinit Worker</strong>: Menghapus semua worker & rolling restart, lalu membuat ulang worker sesuai jumlah baru yang diinput user. Jika <code>.env</code> tidak ada, akan diminta input API key lagi.</li>
    </ul>
  </li>
</ol>

<h2>❓ FAQ Ringkas</h2>
<ul>
  <li><strong>Setelah uninstall, apakah file <code>.env</code>, <code>wai.sh</code>, dan <code>rolling-restart.sh</code> dihapus?</strong><br>Ya, semua file tersebut dihapus, termasuk folder <code>.wombo</code> di parent directory.</li>
  <li><strong>Setelah reinit, apakah file <code>.env</code>, <code>wai.sh</code>, dan <code>rolling-restart.sh</code> dibuat ulang?</strong><br>Ya, semuanya dibuat ulang secara otomatis. Jika <code>.env</code> belum ada, akan diminta input API key.</li>
  <li><strong>Folder <code>.wombo</code> dihapus dari mana?</strong><br>Dari satu level di atas folder installer (<code>../.wombo</code>).</li>
  <li><strong>Bagaimana jika ingin ganti jumlah worker?</strong><br>Gunakan menu <strong>Reinit Worker</strong> atau jalankan <code>./install.sh reinit</code>.</li>
</ul>

</body>
</html>
