import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class OpenLetterPage extends StatelessWidget {
  static const ROUTE_NAME = '/open-letter';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Thư ngỏ")),
        body: SingleChildScrollView(
          child: Html(
            data: """
            <div>
            <h1>Thư ngỏ</h1>
            <h4>CONEC xin kính chào quý đối tác và khách hàng !</h4> 
            <p>Cảm ơn quý đối tác và khách hàng đã tin tưởng sử dụng Conec - một ứng dụng kết nối thể thao hàng đầu Việt Nam với sứ mệnh kết nối những người đam mê thể thao và mang thể thao đến gần hơn với cuộc sống.</p> 
            <p>Đến với Conec, khách hàng có thể thoải mái tìm hiểu các dịch vụ và sản phẩm thể thao hữu ích cũng như được tiếp cận được với hàng chục môn thể thao và hàng trăm câu lạc bộ dựa trên vị trí mà khách hàng muốn tìm kiếm.</p> 
            <p>Chúng tôi luôn tin rằng sức khỏe là yếu tố quan trọng nhất của con người và đó chính là chìa khóa tạo nên mọi thành công. Do đó, đội ngũ lãnh đạo Conec chúng tôi luôn không ngừng phấn đấu hoàn thiện, nâng cấp ứng dụng để phục vụ và mang đến sự hài lòng cho quý đối tác, khách hàng nhằm góp phần thúc đẩy ngành thể thao Việt Nam ngày càng phát triển.</p> 
            <p>Đối với Conec, quý đối tác và khách hàng là những người cộng tác tuyệt vời mang lại cho chúng tôi cơ hội được phát triển và đứng vững trên thị trường ứng dụng. Là động lực thôi thúc đội ngũ Conec phát huy khả năng sáng tạo và cố gắng vươn lên. Chúng tôi rất trân trọng điều đó và cam kết không để bất kỳ khó khăn, trở ngại nào ảnh hưởng đến niềm tin của quý đối tác và khách hàng.</p> 
            <h4>Trân trọng!</h4></div>
          """,
            style: {
              "h1": Style(
                fontSize: FontSize(32),
                fontWeight: FontWeight.w500,
                color: Colors.red,
                alignment: Alignment.center,
                textAlign: TextAlign.center
              ),
            },
          ),
        ),
      ),
    );
  }
}
