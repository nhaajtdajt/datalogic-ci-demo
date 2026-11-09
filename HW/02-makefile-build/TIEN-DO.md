# Bài 2 — Em đã hiểu gì về Makefile?

Em đã dùng GCC trong Ubuntu trên WSL để biên dịch riêng `main.c` và `sensor.c` thành hai file `.o`, rồi liên kết và chạy `build/sensor-demo`. Qua đó em phân biệt được **WSL cung cấp môi trường Linux**, **GCC thực hiện việc biên dịch và liên kết**, còn **Make đọc Makefile để quyết định lệnh nào cần chạy**.

- **Mục tiêu và phụ thuộc.** Em hiểu vì sao `make` và `make all` tạo chương trình, còn `make build` trong bài chỉ tạo thư mục. Từ `all`, Make lần theo các phụ thuộc tới `sensor-demo`, rồi tới `main.o` và `sensor.o`.
- **Quy tắc dùng chung.** Khi cần `build/main.o`, Make khớp `build/%.o` với `src/%.c` và thay `%` bằng `main`. Trong lệnh GCC, `$<` là file nguồn, `$@` là file đích, còn `| build` yêu cầu có thư mục đầu ra trước.
- **Build lại theo thay đổi.** Make so sánh thời gian sửa đổi giữa file đích và các phụ thuộc. Vì vậy `touch src/sensor.c` khiến Make biên dịch lại `sensor.o` rồi liên kết lại chương trình. Khi `sensor.h` mới hơn, Make đọc phụ thuộc trong các file `.d` và biên dịch lại cả hai object.
- **Các lệnh kiểm tra.** Em đã tìm hiểu `make -n` để xem lệnh dự kiến, `make test` để kiểm tra đầu ra và `make install` với `DESTDIR` để cài thử vào thư mục `staging`.
