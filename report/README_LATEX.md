# Hướng Dẫn Hoàn Thiện Báo Cáo LaTeX (`report/main.tex`)

File `main.tex` đã được thiết kế sẵn theo chuẩn báo cáo HCMUT (**tự căn gọn dưới 15 trang**), vẽ sẵn toàn bộ **sơ đồ khối Datapath, sơ đồ hệ thống Lab 4/Lab 5 và sơ đồ FSM (`T0..T3`, `T0..T5`) bằng TikZ** siêu nét, đồng thời điền sẵn toàn bộ bảng mã lệnh, bảng chân DE10-Standard và số liệu Fitter/Timing Analyzer thực tế.

---

## 1. Các chỗ cần bạn tự điền chữ (tìm từ khóa `\todo` trong `main.tex`)

Mở `report/main.tex` và nhấn `Ctrl+F` tìm `\todo`:
1. **Trang bìa:** Họ tên sinh viên, MSSV, Lớp/Nhóm, Tháng năm nộp bài, Link/ghi chú Video demo.
2. **Mục 3.4 (cuối phần Lab 5):** Thay khung `\todobox{NHẬN XÉT THỰC NGHIỆM...}` bằng 3–4 dòng mô tả quan sát thực tế sau khi nạp file `.sof` lên kit DE10-Standard.
3. **Mục 4 (Kết luận):** Cập nhật trạng thái hoàn thành ở dòng 4–5 của Bảng kiểm tra, và điền (hoặc xóa) khung `\todobox{BÀI HỌC RÚT RA...}`.

---

## 2. Danh sách ảnh cần bỏ vào thư mục `report/figures/`

`main.tex` đã cài macro tự động kiểm tra ảnh: **bạn KHÔNG cần sửa code LaTeX** — chỉ cần lưu ảnh chụp đúng tên dưới đây vào thư mục `report/figures/` rồi biên dịch lại, khung trống sẽ tự đổi thành ảnh thật!

| Tên file trong `report/figures/` | Nội dung ảnh |
| :--- | :--- |
| `logo_hcmut.png` *(tùy chọn)* | Logo trường ĐH Bách Khoa TP.HCM (nếu muốn hiện ở trang bìa) |
| `lab4_exp1_rtl.png` | RTL Viewer của `lab4_exp1_proc` (Quartus 18.1) |
| `lab4_exp1_wave.png` | Waveform ModelSim của `lab4_exp1_proc` |
| `lab4_exp2_rtl.png` | RTL Viewer của `lab4_exp2_proc_rom` (Quartus 18.1) |
| `lab4_exp2_wave.png` | Waveform ModelSim của `lab4_exp2_proc_rom` *(nhớ gõ `configure wave -signalnamewidth 1`)* |
| `lab5_p1_rtl.png` | RTL Viewer của `lab5_exp1_proc_enhanced` (Quartus 18.1) |
| `lab5_p1_wave.png` | Waveform ModelSim của `lab5_exp1_proc_enhanced` *(nhớ `signalnamewidth 1`)* |
| `lab5_p2_rtl.png` | RTL Viewer mức top-level `lab5_system_top` (Quartus 18.1) |
| `lab5_p2_wave_overview.png` | Waveform tổng quan `tb_lab5_system` (`0..15500 ns`, thấy LEDR đếm `0..4`, Pause, `5`, Reset) |
| `lab5_p2_wave_zoom.png` | Waveform zoom cận cảnh `tb_lab5_system` (`wave zoom range 9650ns 10200ns` hoặc `2750ns 3050ns`) |
| `lab5_timing.png` | Ảnh chụp TimeQuest Timing Analyzer (`Fmax`, `Setup/Hold`, `Metastability`) |
| `lab5_de10_demo.jpg` | Ảnh chụp kit DE10-Standard đang chạy bộ đếm trên `LEDR[8:0]` |

---

## 3. Cách biên dịch ra PDF

- **Cách 1 — Dùng Overleaf (khuyên dùng, cực nhanh):**
  Nén cả thư mục `report/` thành file `.zip` → vào Overleaf chọn **New Project → Upload Project** → bấm **Recompile** (mặc định Compiler = `pdfLaTeX` là chạy ngay).
- **Cách 2 — Biên dịch trực tiếp trên máy (MiKTeX đã cài sẵn):**
  Mở PowerShell tại `D:\MyData\Study\HK261\KTS\HPMR\report` và chạy 2 lần (để cập nhật Mục lục & số thứ tự hình/bảng):
  ```powershell
  pdflatex -interaction=nonstopmode main.tex
  pdflatex -interaction=nonstopmode main.tex
  ```
  *(Hoặc dùng `xelatex` nếu muốn đổi font chữ hệ thống như Times New Roman.)*
