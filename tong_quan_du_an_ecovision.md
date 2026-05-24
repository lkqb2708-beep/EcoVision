# 🌿 Báo Cáo Dự Án: EcoVision – Ứng Dụng Nhận Diện và Phân Loại Rác Thải Thông Minh

> **Tên dự án:** EcoVision (hay còn gọi nội bộ là "Trashy AI")
> **Người thực hiện:** Học sinh THCS, có sự hỗ trợ và hướng dẫn của người lớn
> **Thời gian thực hiện:** Tháng 4 – Tháng 5 năm 2026
> **Lĩnh vực:** Công nghệ – Môi trường

---

## 1. 💡 Tại Sao Em Làm Dự Án Này?

Gần nhà em có một con hẻm nhỏ, và mỗi ngày đi học về em đều thấy rác vứt bừa bãi — nào là chai nhựa, bọc nilon, thậm chí cả pin cũ. Em thấy rất khó chịu nhưng cũng không biết phải làm gì.

Sau khi nghe thầy/cô giáo nói về **quy định phân loại rác mới tại TP. Hồ Chí Minh (áp dụng từ năm 2025–2026)**, em mới biết là rác thải phải được chia thành từng loại khác nhau trước khi bỏ vào thùng. Nhưng thật ra, ngay cả người lớn cũng hay nhầm lẫn, ví dụ không biết hộp sữa đã uống hết thuộc loại rác gì, hay pin cũ thì bỏ ở đâu.

Vì vậy, **em muốn làm một ứng dụng điện thoại** mà người dùng chỉ cần **chụp ảnh món rác** là ứng dụng sẽ tự động nhận biết và hướng dẫn cách bỏ rác đúng chỗ. Đơn giản, nhanh chóng, và ai cũng dùng được!

---

## 2. 🎯 Mục Tiêu Của Dự Án

- ✅ Nhận biết xem trong ảnh có rác hay không
- ✅ Nếu có rác, xác định đó là loại rác gì theo quy định TP.HCM
- ✅ Hướng dẫn người dùng bỏ rác vào đúng thùng (xanh, cam, hoặc thùng riêng biệt)
- ✅ Ghi lại lịch sử các lần quét để theo dõi

---

## 3. 📱 Ứng Dụng Hoạt Động Như Thế Nào?

Hãy tưởng tượng bạn đang cầm một chai nhựa rỗng và không biết bỏ vào thùng nào. Bạn chỉ cần làm 3 bước:

```
📸 Bước 1: Mở ứng dụng và chụp ảnh món rác đó
   ↓
🤖 Bước 2: Ứng dụng gửi ảnh lên máy chủ, AI phân tích trong vài giây
   ↓
✅ Bước 3: Kết quả hiện ra ngay trên màn hình:
           - Đây là "Rác Tái Chế" (chai nhựa)
           - Thu gom riêng để bán hoặc cho ve chai
           - Tin tưởng: 95%
```

Rất dễ phải không? Em không cần phải nhớ quy định — ứng dụng sẽ nhắc cho mình!

---

## 4. 🗂️ Các Loại Rác Mà Ứng Dụng Có Thể Phân Biệt

Theo quy định mới nhất của TP. Hồ Chí Minh, rác được chia thành **4 nhóm chính**:

| 🏷️ Loại Rác | 📦 Ví Dụ | 🗑️ Thùng | 🎨 Màu trong App |
|---|---|---|---|
| **Rác Tái Chế** | Chai nhựa, lon nhôm, giấy cũ, thủy tinh | Thu gom riêng / bán ve chai | 🔵 Xanh dương |
| **Rác Hữu Cơ** | Cơm thiu, vỏ trái cây, rau củ thừa | Thùng màu **xanh lá** | 🟢 Xanh lá |
| **Rác Vô Cơ** | Túi nilon bẩn, hộp xốp, tã lót, gốm vỡ | Thùng màu **cam** | 🟠 Cam |
| **Rác Nguy Hại** | Pin, bóng đèn, chai thuốc trừ sâu | Điểm thu gom **riêng biệt** | 🔴 Đỏ |

> ⚠️ **Lưu ý quan trọng:** Rác nguy hại *không được* bỏ lẫn với rác sinh hoạt thông thường vì có thể gây ô nhiễm đất và nước ngầm!

---

## 5. 🔧 Em Đã Dùng Những Công Nghệ Gì?

Đây là phần em cần nhờ người lớn hỗ trợ nhiều nhất, vì một số thứ khá phức tạp. Nhưng em đã cố gắng hiểu từng phần:

### 📱 Phần Ứng Dụng Di Động (Frontend)
- **Flutter** — Đây là công cụ giúp tạo ra giao diện ứng dụng điện thoại. Em dùng nó để thiết kế màn hình camera, nút chụp ảnh, và trang hiển thị kết quả.
- Ngôn ngữ lập trình: **Dart**

### 🖥️ Phần Máy Chủ Xử Lý (Backend)
- **FastAPI (Python)** — Đây là "bộ não" của ứng dụng. Khi ảnh được gửi lên, máy chủ nhận ảnh, gửi cho AI phân tích, rồi trả kết quả về cho điện thoại.
- Ngôn ngữ lập trình: **Python**

### 🤖 Phần Trí Tuệ Nhân Tạo (AI)
- **Google Gemini Flash (qua OpenRouter)** — Đây là mô hình AI có khả năng "nhìn" và hiểu ảnh. Em gửi ảnh lên, nó phân tích và trả lời theo đúng quy định phân loại rác của TP.HCM.
- Em đã viết một đoạn "hướng dẫn" (gọi là *prompt*) bằng tiếng Anh và tiếng Việt để dạy AI biết rác nào thuộc nhóm nào.

### 🗄️ Phần Lưu Trữ Dữ Liệu (Database)
- **PostgreSQL** — Đây là nơi lưu lại mọi lần quét ảnh: ảnh đó là rác gì, độ tin cậy bao nhiêu, và quét lúc mấy giờ. Giống như một cuốn sổ tay điện tử vậy!

---

## 6. 🗺️ Sơ Đồ Hoạt Động Của Toàn Bộ Hệ Thống

```
[Điện Thoại Android]
        |
        | 1. Chụp ảnh + gửi ảnh (dạng mã hóa)
        ↓
[Máy Chủ FastAPI - Python]
        |
        | 2. Nhận ảnh, gửi đến AI để phân tích
        ↓
[Google Gemini AI - OpenRouter]
        |
        | 3. AI "nhìn" ảnh, phân loại rác, viết hướng dẫn tiếng Việt
        ↓
[Máy Chủ FastAPI - Python]
        |
        | 4. Lưu kết quả vào cơ sở dữ liệu PostgreSQL
        | 5. Gửi kết quả về điện thoại
        ↓
[Điện Thoại Android]
        |
        | 6. Hiển thị kết quả cho người dùng
        ↓
✅ Người dùng biết cách bỏ rác đúng chỗ!
```

---

## 7. 😅 Những Khó Khăn Em Gặp Phải

Làm dự án này không phải lúc nào cũng suôn sẻ. Có những lúc em muốn bỏ cuộc vì:

- **Kết nối mạng giữa điện thoại và máy tính hay bị lỗi** — Em phải học cách tìm địa chỉ IP của máy tính trong mạng nội bộ để điện thoại có thể "nói chuyện" được với máy chủ.
- **AI đôi khi trả lời sai định dạng** — Lúc đầu, AI hay thêm dấu ``` hoặc chữ "json" vào kết quả, làm ứng dụng không đọc được. Em phải viết thêm code để "làm sạch" dữ liệu trước khi dùng.
- **Cơ sở dữ liệu không tự cập nhật** — Khi em thêm các cột mới (như loại rác, màu thùng), bảng dữ liệu cũ không có các cột đó. Em phải học cách viết lệnh tự động thêm cột vào bảng cũ mà không xóa dữ liệu đã có.
- **Viết prompt bằng tiếng Việt cho AI** — Em phải thử đi thử lại nhiều lần để AI hiểu đúng 4 loại rác theo quy định TP.HCM, không bị nhầm lẫn giữa "rác vô cơ" và "rác nguy hại".

> 💬 *"Lần đầu tiên kết quả hiện ra đúng trên điện thoại, em vui lắm! Mấy tuần mày mò cuối cùng cũng có kết quả."*

---

## 8. 🎉 Kết Quả Đạt Được

- ✅ Ứng dụng có thể nhận diện rác trong ảnh chụp thực tế
- ✅ Phân loại chính xác theo **4 nhóm rác** của TP.HCM
- ✅ Hiển thị **hướng dẫn tiếng Việt** cho từng loại rác
- ✅ Giao diện thân thiện, màu sắc khác nhau cho từng loại rác
- ✅ Lưu lịch sử quét vào cơ sở dữ liệu

---

## 9. 🚀 Em Muốn Phát Triển Thêm Gì?

Nếu có thêm thời gian và sự hỗ trợ, em muốn:

1. **Thêm bản đồ điểm thu gom rác nguy hại** — Để người dùng biết mang pin/bóng đèn cũ đến đâu
2. **Tính năng thống kê** — Xem mình đã phân loại bao nhiêu kg rác mỗi tuần
3. **Chế độ quét liên tục** — Không cần nhấn nút, cứ hướng camera vào rác là tự động nhận biết
4. **Thêm tiếng địa phương** — Các tỉnh thành khác có thể có quy định khác, muốn mở rộng ra toàn quốc
5. **Điểm thưởng** — Ai phân loại rác đúng nhiều lần sẽ được điểm thưởng, như một trò chơi!

---

## 10. 🙏 Lời Cảm Ơn

Em xin chân thành cảm ơn:
- **Người hướng dẫn** đã giúp em hiểu các khái niệm lập trình khó và kiên nhẫn giải thích lại khi em không hiểu
- **Google Gemini AI** — mô hình AI mà em đã sử dụng để nhận diện hình ảnh
- **Quy định của TP. Hồ Chí Minh về phân loại rác 2025–2026** — nguồn tài liệu chính để em xây dựng hệ thống phân loại

---

## 📌 Tóm Tắt Nhanh

| Hạng mục | Chi tiết |
|---|---|
| **Tên dự án** | EcoVision / Trashy AI |
| **Mục đích** | Nhận diện và phân loại rác thải đúng quy định TP.HCM |
| **Nền tảng** | Ứng dụng Android |
| **Công nghệ chính** | Flutter, Python FastAPI, Google Gemini AI, PostgreSQL |
| **Số loại rác nhận biết** | 4 nhóm (tái chế, hữu cơ, vô cơ, nguy hại) |
| **Ngôn ngữ hướng dẫn** | Tiếng Việt |
| **Trạng thái** | Hoạt động được ✅ |

---

*📝 Báo cáo được viết bởi học sinh thực hiện dự án, có sự hỗ trợ chỉnh sửa của người hướng dẫn. Tháng 5/2026.*
