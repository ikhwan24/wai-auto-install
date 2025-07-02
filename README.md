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
  <li>✅ Jalankan <code>wai.sh</code> sekali untuk download model & generate token</li>
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

<h2>🔧 Cara Pakai</h2>
<h3>1. Download dan Jalankan</h3>
<pre><code>wget https://yourdomain.com/install-wai.sh
chmod +x install-wai.sh
./install-wai.sh</code></pre>

<p><strong>Atau langsung via CURL:</strong></p>
<pre><code>curl -fsSL https://yourdomain.com/install-wai.sh | bash</code></pre>

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
      <td><code>wai.sh</code></td>
      <td>Script untuk menjalankan <code>wai run w.ai</code></td>
    </tr>
    <tr>
      <td><code>rolling-restart.sh</code></td>
      <td>Restart worker satu per satu tiap 10 menit</td>
    </tr>
    <tr>
      <td>PM2 Process</td>
      <td>Worker: <code>wai0</code>, <code>wai1</code>, ... <code>waiN</code><br>Roller: <code>pm2-roller</code></td>
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

<p>Untuk menghidupkan ulang:</p>
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

</body>
</html>
