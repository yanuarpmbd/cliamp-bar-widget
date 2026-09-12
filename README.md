# Cliamp Bar Widget for Omarchy

Widget bar untuk **Omarchy Shell** (berbasis Quickshell) yang menampilkan visualisasi spektrum audio real-time dan kontrol pemutar musik dari **cliamp**.

Widget ini secara dinamis mengadaptasi tampilan visualisasinya mengikuti **31 visualizer bawaan cliamp** secara real-time.

---

## Fitur Utama

- **Adaptive 31 Visualizers**:
  Membaca stream NDJSON dari `cliamp visstream` dan secara otomatis mengalihkan gaya render grafis sesuai mode visualizer yang sedang aktif di cliamp:
  - **Bars & Columns**: Equalizer batang solid.
  - **BarsOutline**: Batang garis tepi (outline).
  - **ClassicPeak & BarsDot**: Equalizer klasik dengan indikator peak hold yang jatuh perlahan.
  - **ClassicLED, Bricks & Mosaic**: Batang lampu bertingkat LED vintage.
  - **Wave, Scope & Heartbeat**: Garis gelombang osiloskop kontinu / denyut ECG.
  - **Binary & Matrix**: Kolom digital biner `0 1` / kode matriks.
  - **Mirror, Stereo & Butterfly**: Batang simetris atas-bawah dan kiri-kanan.
  - **Particles (Rain, Sakura, Firefly, Bubbles, Firework, Scatter, Sand, Geyser)**: Partikel titik melayang dan memantul mengikuti beat.
  - **Pulse & Flame**: Denyut amplitude dinamis dan nyala api.
  - **Ascii**: Karakter blok Unicode terminal (` ▂▃▅▆▇█`).
  - **None**: Mode minimalis hemat visual.
- **Adaptive Color Themes**:
  Menyesuaikan warna aksen visualizer secara tematik (misal: hijau matriks, merah muda sakura, api jingga, cyan cyber, phosphor green) atau menggunakan warna aksen Omarchy aktif.
- **Metadata Track**:
  Menampilkan judul lagu saat ini secara ringkas di bar dengan tooltip lengkap (judul, artis, status, dan mode visualizer).
- **Kontrol Penuh Lewat Mouse**:
  - **Klik Kiri**: Toggle Play / Pause (`cliamp toggle`). Jika cliamp belum berjalan, membuka jendela cliamp.
  - **Klik Kanan**: Berganti ke visualizer berikutnya (`cliamp vis next`), tersinkron otomatis ke TUI cliamp.
  - **Klik Tengah**: Lagu berikutnya / Next track (`cliamp next`).
  - **Scroll Wheel**: Mengatur volume naik/turun (`cliamp volume +/-2`).
- **Hemat Sumber Daya (Smart Idle)**:
  Stream audio otomatis dijeda saat musik tidak berputar atau cliamp ditutup.

---

## Instalasi ke Omarchy

### 1. Buat Symlink ke Direktori Plugin Omarchy
```bash
ln -s /home/bol/Projects/cliamp-bar-widget ~/.config/omarchy/plugins/bol.cliamp-bar
```

### 2. Rescan & Aktifkan Plugin
```bash
omarchy-shell shell rescanPlugins
omarchy plugin enable bol.cliamp-bar
```

### 3. (Opsional) Mengatur Posisi di Bar
Buka `~/.config/omarchy/shell.json` atau gunakan perintah:
```bash
omarchy bar move bol.cliamp-bar center 0
```

---

## Opsi Konfigurasi (`shell.json`)

Kamu dapat mengatur opsi widget di dalam blok konfigurasi `shell.json`:
```json
{
  "id": "bol.cliamp-bar",
  "fps": 20,
  "showTrack": true,
  "maxTitleLength": 24,
  "adaptiveColors": true
}
```

| Opsi | Tipe | Default | Keterangan |
| :--- | :--- | :--- | :--- |
| `fps` | number | `20` | Frame rate rendering spektrum (10 - 30). |
| `showTrack` | boolean | `true` | Menampilkan potongan judul lagu di sebelah visualizer. |
| `maxTitleLength` | number | `24` | Batas maksimum karakter judul lagu sebelum dipotong (`…`). |
| `adaptiveColors` | boolean | `true` | Menggunakan palet warna khusus sesuai visualizer aktif. |

---

## IPC Shell Integration

Widget menyediakan handler IPC `cliamp-bar` yang dapat dipanggil dari skrip atau keybinding Hyprland:
```bash
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar toggle
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar nextVis
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar next
quickshell ipc -p /usr/share/omarchy/shell call cliamp-bar prev
```
