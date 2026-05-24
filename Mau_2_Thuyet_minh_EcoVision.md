# BẢN THUYẾT MINH DỰ ÁN DỰ THI
## Tên dự án: EcoVision – Ứng dụng nhận diện và phân loại rác thải thông minh

### 1. Ý tưởng và lý do chọn đề tài
Hiện nay, vấn đề ô nhiễm môi trường do rác thải sinh hoạt đang trở nên cấp bách. Tại TP. Hồ Chí Minh, quy định phân loại rác mới (2025-2026) yêu cầu người dân phải phân loại rác thành 4 nhóm: Tái chế, Hữu cơ, Vô cơ và Nguy hại. Tuy nhiên, thực tế nhiều người dân (kể cả người lớn và trẻ em) vẫn gặp khó khăn trong việc xác định loại rác và thùng rác tương ứng. 

Xuất phát từ tình hình đó, em mong muốn tạo ra một công cụ hỗ trợ thông minh ngay trên điện thoại di động, giúp việc phân loại rác trở nên đơn giản, nhanh chóng và chính xác hơn thông qua công nghệ trí tuệ nhân tạo.

### 2. Mục tiêu của dự án
- Xây dựng ứng dụng di động nhận diện rác qua hình ảnh.
- Phân loại rác chính xác theo 4 nhóm quy định của TP.HCM.
- Cung cấp hướng dẫn xử lý rác cụ thể (bỏ thùng màu gì, thu gom thế nào).
- Lưu trữ lịch sử phân loại để khuyến khích thói quen bảo vệ môi trường.

### 3. Quy trình thực hiện và Công nghệ sử dụng
Dự án được thực hiện trong khoảng 2 tháng (Tháng 4 - Tháng 5/2026) với các công đoạn:
- **Nghiên cứu:** Tìm hiểu quy định phân loại rác của TP.HCM.
- **Thiết kế giao diện (Frontend):** Sử dụng **Flutter (ngôn ngữ Dart)** để tạo ứng dụng Android chuyên nghiệp, có chức năng chụp ảnh và hiển thị kết quả sinh động.
- **Xây dựng hệ thống xử lý (Backend):** Sử dụng **FastAPI (Python)** để nhận và xử lý dữ liệu từ ứng dụng.
- **Tích hợp Trí tuệ nhân tạo (AI):** Sử dụng mô hình **Google Gemini 2.0 Flash** thông qua OpenRouter. Đây là mô hình AI đa phương thức (Multimodal) tiên tiến nhất, cho phép "nhìn" và hiểu hình ảnh với độ chính xác và tốc độ vượt trội.
- **Cơ sở dữ liệu:** Sử dụng **PostgreSQL** để lưu trữ lịch sử các lần quét, bao gồm nhãn rác, độ tin cậy và thời gian.

### 4. Cách thức hoạt động và Thuật toán xử lý
Ứng dụng áp dụng quy trình xử lý 2 giai đoạn (Two-step logic):
1. **Giai đoạn 1 (Trash Detection):** AI phân tích hình ảnh để xác định xem có sự xuất hiện của rác thải hay không.
2. **Giai đoạn 2 (Waste Classification):** Nếu có rác, AI sẽ đối chiếu với cơ sở tri thức về quy định của TP.HCM để phân loại vào 1 trong 4 nhóm: Tái chế, Hữu cơ, Vô cơ hoặc Nguy hại.

Dữ liệu được truyền tải dưới dạng mã hóa Base64 và phản hồi được chuẩn hóa dưới dạng JSON để đảm bảo tính chính xác tuyệt đối khi hiển thị giao diện.

### 5. Những khó khăn và cách khắc phục
Trong quá trình thực hiện, em đã gặp một số trở ngại kỹ thuật nhưng đã tìm cách giải quyết:
- **Kết nối mạng:** Gặp khó khăn khi kết nối điện thoại với máy chủ trong mạng nội bộ. Em đã học cách xác định địa chỉ IP tĩnh để các thiết bị có thể "nói chuyện" với nhau ổn định.
- **Xử lý dữ liệu AI:** Đôi khi AI trả về dữ liệu dư thừa (như các ký tự markdown). Em đã viết thêm mã nguồn để "làm sạch" dữ liệu trước khi hiển thị lên ứng dụng.
- **Cấu trúc dữ liệu:** Khi nâng cấp tính năng, em phải học cách cập nhật cơ sở dữ liệu (migration) mà không làm mất dữ liệu cũ.
- **Tối ưu hóa Prompt:** Em đã thử nghiệm nhiều lần để viết bộ hướng dẫn (prompt) tiếng Việt tối ưu, giúp AI phân biệt chính xác các loại rác theo đúng tiêu chuẩn của TP.HCM.

### 6. Những kết quả đạt được
- **Ứng dụng thực tế:** Nhận diện và phân loại chính xác rác thải theo 4 nhóm quy định.
- **Trải nghiệm người dùng:** Giao diện trực quan, tốc độ xử lý nhanh, hướng dẫn tiếng Việt dễ hiểu.
- **Tính khoa học:** Hệ thống có khả năng lưu trữ và thống kê lịch sử quét, giúp theo dõi hành trình sống xanh.

### 7. Tính mới và tính sáng tạo
- So với các ứng dụng khác, EcoVision tập trung sâu vào quy định cụ thể của địa phương (TP.HCM), giúp thông tin mang tính thực tiễn cao.
- Sử dụng mô hình AI tiên tiến nhất (Gemini Flash) giúp việc nhận diện linh hoạt hơn, không bị bó hẹp trong các bộ lọc hình ảnh cứng nhắc.

### 8. Kết luận và Hướng phát triển
Dự án EcoVision đã giải quyết được bài toán khó khăn trong việc phân loại rác tại nguồn của người dân. Trong tương lai, em mong muốn:
- Tích hợp bản đồ các điểm thu gom rác nguy hại và điểm đổi rác lấy quà.
- Thêm tính năng quét liên tục (Real-time detection).
- Xây dựng hệ thống điểm thưởng (Gamification) để tạo động lực cho các bạn học sinh tham gia phân loại rác.

---
*Người thuyết minh*
**[Họ và tên của em]**
