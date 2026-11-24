# Project HPMR — Kỹ Thuật Số (EE1009, HCMUT)
**Nội dung:** Lab 4 (Simple Processor & ROM) + Lab 5 (Enhanced Processor, RAM 1-PORT, LEDs trên DE10-Standard @ 50 MHz)  
**Công cụ:** Quartus Prime 18.1 Lite + ModelSim-Altera 10.5b  
**Board FPGA:** Terasic DE10-Standard (Cyclone V SX SoC `5CSXFC6D6F31C6`)

---

## 1. Cảnh Báo Cực Kỳ Quan Trọng Về Đường Dẫn Thư Mục!

> **Quartus Prime 18.1 và ModelSim 10.5b KHÔNG hỗ trợ đường dẫn chứa tiếng Việt có dấu!**  
> Nếu mở trực tiếp trong `D:\Dữ liệu cá nhân\Học tập\HK261\Kỹ Thuật Số\HPMR`, Quartus sẽ báo `Error (125086)` và ModelSim sẽ lỗi `Error 23`.

**Cách xử lý trước khi mở Quartus / ModelSim GUI:**
1. Copy toàn bộ 4 thư mục project (`lab4_exp1_proc`, `lab4_exp2_proc_rom`, `lab5_exp1_proc_enhanced`, `lab5_exp1_system_fpga`) sang một thư mục **không dấu, không khoảng trắng**, ví dụ: `D:\HPMR_EE1009\`.
2. Toàn bộ đường dẫn trong `.qsf`, `.do`, `.sv`, `.mif` đều đã được viết dưới dạng **đường dẫn tương đối**, nên khi bạn (hoặc cô giáo) giải nén file `.zip` ở bất kỳ thư mục ASCII nào đều biên dịch & mô phỏng chạy ngay lập tức.

---

## 2. Cấu Trúc Thư Mục Project

```text
HPMR/
├── README.md                     <- File hướng dẫn này
├── REPORT_DRAFT.md               <- Nội dung khung báo cáo chi tiết (căn chuẩn <= 15 trang)
├── lab4_exp1_proc/               <- Lab 4 - Exp 1: Simple Processor (proc)
│   ├── rtl/                      <- regn.sv, dec3to8.sv, addsub.sv, proc.sv
│   ├── sim/                      <- tb_proc.sv, run_sim.do
│   └── lab4_exp1_proc.qpf/.qsf
├── lab4_exp2_proc_rom/           <- Lab 4 - Exp 2: Simple Processor + 32x9 ROM + 5-bit Counter
│   ├── rtl/                      <- regn.sv, dec3to8.sv, addsub.sv, proc.sv, counter5.sv, my_rom.sv, lab4_exp2_top.sv
│   ├── mem/                      <- my_ROM.mif (Quartus), my_ROM.mem (ModelSim) [Pre-Lab 4 Ex 1]
│   ├── sim/                      <- tb_lab4_exp2.sv, run_sim.do
│   └── lab4_exp2_proc_rom.qpf/.qsf
├── lab5_exp1_proc_enhanced/      <- Lab 5 - Project 1: Enhanced Processor độc lập (proc_enhanced)
│   ├── rtl/                      <- regn.sv, dec3to8.sv, addsub.sv, pc_counter.sv, proc_enhanced.sv
│   ├── sim/                      <- tb_proc_enhanced.sv, run_sim.do
│   └── lab5_exp1_proc_enhanced.qpf/.qsf
└── lab5_exp1_system_fpga/        <- Lab 5 - Project 2: Hệ thống đầy đủ trên DE10-Standard (50 MHz)
    ├── rtl/                      <- proc_enhanced + ram128x9.sv (M10K) + run_sync.sv (2-FF) + lab5_system_top.sv
    ├── mem/                      <- program_fpga.mif (delay 511x511 cho kit), program_sim.mif/.mem (delay 2x2 cho sim)
    ├── constraints/              <- lab5_system_top.sdc (ràng buộc 50 MHz)
    ├── sim/                      <- tb_lab5_system.sv, run_sim.do
    ├── output_files/             <- Đã có sẵn lab5_exp1_system_fpga.sof, .fit.summary, .sta.summary
    └── lab5_exp1_system_fpga.qpf/.qsf
```

---

## 3. Hướng Dẫn Chụp Waveform Bằng ModelSim (Cho Báo Cáo)

Sau khi copy 4 thư mục sang đường dẫn không dấu (vd `D:\HPMR_EE1009\`):

1. Mở **ModelSim - Intel FPGA Starter Edition 18.1**.
2. Trong cửa sổ **Transcript** (bên dưới), gõ lần lượt cho từng bài:

- **Lab 4 — Exp 1 (`proc`):**
  ```tcl
  cd D:/HPMR_EE1009/lab4_exp1_proc/sim
  do run_sim.do
  ```
  *Chụp màn hình cửa sổ Wave*: Thấy rõ `DIN` & `IR` (Octal), `Tstep_Q`, `R0`, `R1`, `R2`, `A`, `G`, `BusWires` (Hex), `Done` cho `mvi R0,#5`, `mv R1,R0`, `add R0,R1`, `sub R0,R0` (khớp Figure 2 Lab 4) + phép cộng số âm `5 + (-6) = -1 (0x1FF)`.

- **Lab 4 — Exp 2 (`proc + 32x9 ROM + Counter`):**
  ```tcl
  cd D:/HPMR_EE1009/lab4_exp2_proc_rom/sim
  do run_sim.do
  ```
  *Chụp màn hình cửa sổ Wave*: Thấy rõ `MClock`, `PClock`, `rom_addr` tăng `0..8`, `rom_data` xuất lần lượt các mã lệnh Pre-Lab 4 Ex 1, `R2 = 0x005`, `R4 = 0x1FA (-6)`.

- **Lab 5 — Project 1 (`proc_enhanced`):**
  ```tcl
  cd D:/HPMR_EE1009/lab5_exp1_proc_enhanced/sim
  do run_sim.do
  ```
  *Chụp màn hình cửa sổ Wave*: Thấy rõ đủ 7 lệnh (`mvi`, `mv`, `add`, `sub`, `ld`, `st`, `mvnz`), `ADDR`, `DOUT`, `W`, `R7 (PC)` nhảy vòng lặp 3 lần rồi thoát vòng lặp.

- **Lab 5 — Project 2 (Hệ thống đầy đủ RAM + LEDs):**
  ```tcl
  cd D:/HPMR_EE1009/lab5_exp1_system_fpga/sim
  do run_sim.do
  ```
  *Chụp màn hình cửa sổ Wave*: Thấy rõ `SW[9]` qua đồng bộ 2-FF `Run_sync`, `led_en` bật khi `ADDR = 0x080` và `W = 1`, `LEDR[8:0]` đếm `0 -> 1 -> 2 -> 3 -> 4`, tạm dừng khi `SW[9] = 0`, chạy tiếp lên `5`, reset bằng `KEY[0] = 0` về `0 -> 1`.

---

## 4. Hướng Dẫn Chụp RTL Viewer & Timing Analyzer Trong Quartus 18.1

Cho mỗi project (`.qpf`) trong `D:\HPMR_EE1009\`:
1. Mở file `.qpf` bằng **Quartus Prime 18.1 Lite**.
2. Nhấn **Processing -> Start -> Start Analysis & Synthesis** (hoặc **Start Compilation** cho `lab5_exp1_system_fpga`).
3. Chụp **RTL Viewer**:
   - Vào **Tools -> Netlist Viewers -> RTL Viewer**.
   - Nhấn nút phóng to/vừa khung hình (`Fit in Window`) và chụp hình (hoặc **File -> Export** ra ảnh PNG/PDF).
   - Ở `lab5_exp1_system_fpga`, nên chụp 2 mức: mức tổng thể `lab5_system_top` (thấy `u_run_sync`, `u_proc`, cổng giải mã địa chỉ, `u_ram`, `u_leds_reg`) và mức bên trong `u_proc` (nhấp đúp vào khối `u_proc`).
4. Chụp **Timing Analyzer** (cho `lab5_exp1_system_fpga`):
   - Sau khi Compile xong, mở **Compilation Report -> TimeQuest Timing Analyzer**.
   - Chụp bảng **Slow 1100mV 85C Model -> Fmax Summary** (`101.81 MHz`), **Slow 1100mV 0C Model -> Fmax Summary** (`100.94 MHz`), **Setup Summary** (`+10.093 ns`), **Hold Summary** (`+0.121 ns`), và **Metastability Summary** (`1e+09 years`).

---

## 5. Hướng Dẫn Nạp Kit DE10-Standard & Quay Video Demo

### A. Nạp chương trình lên DE10-Standard
1. Cấp nguồn 12V cho board **DE10-Standard** và cắm cáp USB-Blaster II từ cổng **USB Blaster II** của board vào máy tính.
2. Mở **Quartus Prime 18.1 -> Tools -> Programmer**.
3. Nhấn **Hardware Setup...** -> chọn **DE-SoC [USB-1]**.
4. Nhấn **Auto Detect** -> chọn thiết bị **5CSXFC6D6** (nếu hiện danh sách lựa chọn thiết bị Cyclone V).
5. **Lưu ý quan trọng trên DE10-Standard (SoC):** chuỗi JTAG có 2 chip: `SOCVHPS` (ARM) và `5CSXFC6D6` (FPGA).
   - Nhấp đúp (hoặc chọn **Change File...**) vào dòng **`5CSXFC6D6`** -> chọn file `lab5_exp1_system_fpga/output_files/lab5_exp1_system_fpga.sof`.
   - Tick ô **Program/Configure** ở dòng `5CSXFC6D6`.
6. Nhấn **Start** (thanh Progress đạt `100% (Successful)`).

### B. Thao tác demo trên kit DE10-Standard
| Phần tử trên DE10-Standard | Chức năng | Chân FPGA |
| :--- | :--- | :---: |
| `CLOCK_50` | Xung nhịp 50 MHz | `PIN_AF14` |
| `KEY[0]` | `Resetn` (tích cực mức thấp: nhấn = Reset về 0) | `PIN_AJ4` |
| `SW[9]` | `Run` (`0` = Tạm dừng, `1` = Chạy) | `PIN_AA30` |
| `LEDR[8:0]` | Hiển thị bộ đếm nhị phân 9-bit từ thanh ghi `LEDs` | `PIN_AA24` .. `PIN_AB22` |

### C. Kịch bản quay Video Demo (gợi ý 2–3 phút)
1. **0:00 – 0:25 (Giới thiệu):** Họ tên, MSSV, môn HPMR Kỹ Thuật Số EE1009, giới thiệu đã hoàn thành Lab 4 & Lab 5, demo hệ thống Enhanced Processor + RAM 128x9 + LEDs chạy 50 MHz trên DE10-Standard.
2. **0:25 – 0:50 (Nạp file `.sof`):** Quay màn hình Quartus Programmer nhấn Start -> `100% Successful` (có thể lướt nhanh bảng Timing Analyzer đạt `Fmax > 100 MHz`).
3. **0:50 – 2:10 (Demo thực tế trên board DE10-Standard):**
   - Ban đầu gạt `SW[9] = 0`, nhấn `KEY[0]` (Reset): `LEDR[8:0]` tắt toàn bộ (`000000000`).
   - Gạt `SW[9] = 1`: `LEDR[8:0]` bắt đầu đếm nhị phân tăng đều (~19 bước/giây ở 50 MHz với vòng trễ lồng nhau `511 x 511`; bit thấp nháy nhanh, các bit `LEDR[4..8]` thấy đếm nhị phân rất rõ).
   - Gạt `SW[9] = 0`: bộ đếm **đứng yên chính xác** ở giá trị hiện tại (chứng minh tín hiệu `Run` đã đồng bộ 2-FF hoạt động ổn định).
   - Gạt lại `SW[9] = 1`: bộ đếm **tiếp tục đếm** từ giá trị vừa dừng.
   - Nhấn `KEY[0]`: bộ đếm reset về `0` và đếm lại từ đầu.
4. **2:10 – 2:30 (Kết thúc):** Tóm tắt kết quả và cảm ơn cô.

---

## 6. Checklist Đóng Gói Nộp Bài
- [ ] File PDF báo cáo (**tối đa 15 trang**) đã chèn đủ ảnh RTL Viewer, Waveform ModelSim, Timing Analyzer và ảnh chạy kit.
- [ ] File `.zip` chứa 4 thư mục project (`lab4_exp1_proc`, `lab4_exp2_proc_rom`, `lab5_exp1_proc_enhanced`, `lab5_exp1_system_fpga`) — nên xóa thư mục tạm `db/`, `incremental_db/`, `sim/work/` trước khi nén để file `.zip` nhẹ và sạch (giữ lại `rtl/`, `mem/`, `constraints/`, `sim/*.sv`, `sim/*.do`, `.qpf`, `.qsf`, và `output_files/*.sof` của Lab 5).
- [ ] File Video demo (`.mp4`) rõ nét, nghe rõ tiếng, thấy rõ `SW[9]`, `KEY[0]`, `LEDR[8:0]`.
