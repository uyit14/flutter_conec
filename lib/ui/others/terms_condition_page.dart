import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zefyr/zefyr.dart';

class TermConditionPage extends StatelessWidget {
  static const ROUTE_NAME = '/term-condition';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chính sách và điều khoản"),),
      body: SingleChildScrollView(
        child: Html(
          data: """<h2>CÁC ĐIỀU KHOẢN CHÍNH SÁCH CONEC KHI SỬ DỤNG</h2> 
                    <p>
                    Bạn hiểu và đồng ý rằng bằng việc đăng ký Tài khoản trên Ứng dụng Conec – Kết nối thể thao , bạn và Conec đã thiết lập một quan hệ hợp đồng dịch vụ thương mại điện tử. Theo đó, bạn có nhu cầu sử dụng các dịch vụ đăng tin và các dịch vụ khác mà Conec cung cấp trên Ứng dụng Conec.
                </p> <h4>
                    1. ĐĂNG KÝ TÀI KHOẢN TRÊN ỨNG DỤNG CONEC.
                </h4> <p><i>&#187;  </i> Để sử dụng một số tính năng của Conec, bạn phải tạo Tài khoản trên Ứng dụng (Đăng ký tài khoản)<br> <i>&#187;  </i> Khi tạo Tài khoản bạn phải đồng ý cung cấp một cách chính xác và đầy đủ thông tin được yêu cầu (Dữ liệu tài khoản).<br> <i>&#187;  </i> Nếu bạn cung cấp thông tin của bất kỳ bên thứ ba nào cho Conec chúng tôi có quyền tin rằng bạn đã đạt được sự thỏa thuận cần thiết từ bên thứ ba đó để chia sẻ và chuyển giao thông tin của họ cho chúng tôi.
                </p> <h4>
                    2. BẢO VỆ TÀI KHOẢN
                </h4> <p><i>&#187;  </i> Để sử dụng và bảo vệ Tài khoản, bạn phải cung cấp một số điện thoại và Mật khẩu (Dữ liệu đăng ký) để bảo vệ tài khoản.<br> <i>&#187;  </i> Bạn phải có trách nhiệm bảo vệ và giữ bí mật Mật khẩu này, Conec không có bất kỳ trách nhiệm liên quan đến và/hoặc phát sinh từ việc Mật khẩu của bạn bị mất mát và/hoặc bên thứ ba nào khác biết đến Mật khẩu của bạn.<br> <i>&#187;  </i> Nếu bạn chia sẻ tài khoản của mình đối với bất kỳ bên nào khác thì bạn sẽ tự chịu mọi trách nhiệm về tất cả các hành động được thực hiện và hậu quả dưới tên Tài khoản của Bạn, chúng tôi sẽ không chịu bất kỳ trách nhiệm nào phát sinh từ hành động của bạn.<br> <i>&#187;  </i> Hành vi sử dụng dữ liệu đăng ký của người khác mà không được thực hiện dưới sự đồng ý hoặc khi có sự quan sát của người sở hữu Tài khoản được coi là trái phép.<br> <i>&#187;  </i> Conec sẽ không chịu trách nhiệm về thiệt hại bạn gây ra do việc sử dụng trái phép tài khoản của người khác, bạn có thể phải chịu trách nhiệm cho những thiệt hại của Conec hoặc của những người khác nếu sử dụng trái phép Tài khoản.<br> <i>&#187;  </i> Bạn sẽ thông báo ngay lập tức cho Conec nếu phát hiện hoặc nghi ngờ việc có người truy cập trái phép, lạm dụng, vi phạm bảo mật vào Dữ liệu tài khoản hoặc Dữ liệu đăng ký của bạn.
                    </p><h4>
                        3. CHẤM DỨT HOẠT ĐỘNG CỦA TÀI KHOẢN
                    </h4> <p><strong>Trường hợp Conec chấm dứt Tài khoản của bạn:<br><br></strong> <i>&#187;  </i> Conec bảo lưu quyền chấm dứt vĩnh viễn hoặc chấm dứt tạm thời hoạt động của Tài khoản nếu bạn được xác định đã vi phạm Quy chế tài khoản, Quy chế hoạt động, Quy định đăng tin (điều 4) và/hoặc có những hành vi ảnh hưởng đến hoạt động kinh doanh của Conec, bạn sẽ được thông báo trước 05 (năm) ngày về việc Tài khoản bị chấm dứt hoặc tạm ngưng theo quy định của Conec . <br> <i>&#187;  </i> Conec có quyền quyết định Tài khoản đó có vi phạm Quy chế tài khoản, Quy chế hoạt động, Quy định đăng tin hoặc có hành vi ảnh hưởng đến hoạt động của Conec hay không dựa trên những quy định mà chúng tôi đã công khai hoặc khi có căn cứ cho rằng Tài khoản đó có hành vi vi phạm pháp luật. Thời điểm chấm dứt Tài khoản là khi Conec gửi email cho bạn về việc chấm dứt Tài khoản.<br><br> <strong>Đối với thông tin tài khoản không liên quan đến tin đăng:<br><br></strong> <i>&#187;  </i> Conec sẽ gỡ bỏ Trang cá nhân của bạn khỏi ứng dụng Conec. Người dùng khác trên Conec sẽ không thể xem được Trang cá nhân, cũng như các thông tin liên lạc như địa chỉ, số điện thoại, ngày đăng nhập, v..v… từng được hiển thị trên Trang cá nhân của Tài khoản đã chấm dứt.<br> <i>&#187;  </i> Thông tin liên quan đến hoặc phát sinh từ Tài khoản của bạn sẽ được lưu trữ và bảo mật trong hệ thống của Conec phù hợp với quy định pháp luật về thương mại điện tử, an ninh mạng và các văn bản pháp lý liên quan đảm bảo rằng Conec thực hiện bảo mật và chỉ nhằm mục đích lưu trữ theo quy định pháp luật. <br> <i>&#187;  </i> Những thông tin bạn đã công khai trên Conec hoặc đã trao đổi, cung cấp cho người dùng khác trên Conec sẽ do Conec toàn quyền xử lý phù hợp quy định pháp luật về thương mại điện tử, an ninh mạng và các văn bản pháp lý liên quan.
                    </p> <h4>
                        4. QUY ĐỊNH ĐĂNG TIN
                    </h4> <p ><i>&#187;  </i> Không cung cấp đường dẫn đến trang thông tin điện tử có nội dung vi phạm quy định pháp luật.<br> <i>&#187;  </i> Miêu tả hành động dâm ô, chém, giết, tai nạn rùng rợn, không phù hợp thuần phong mỹ tục, truyền thống văn hóa Việt Nam.<br> <i>&#187;  </i> Có các hành động phản cảm, kích dục, gợi tình, hút thuốc, sử dụng ma túy và/hoặc chất gây nghiện, chất hướng thần và các nội dung truyền bá tệ nạn xã hội khác.<br> <i>&#187;  </i> Chứa các nội dung mê tín dị đoan.<br> <i>&#187;  </i> Cung cấp thông tin sai sự thật, vu khống, xuyên tạc, xúc phạm uy tín của cơ quan, tổ chức và danh dự, nhân phẩm của cá nhân.<br> <i>&#187;  </i> Hình ảnh phản cảm không phù hợp với thuần phong mỹ tục.<br> <i>&#187;  </i> Các nội dung khác bị cấm theo quy định của pháp luật.<br> <i>&#187;  </i> Các tin đăng - bài viết nếu phát hiện vi phạm về điều khoản trên sẽ bị Conec Gỡ bỏ trong vòng 24h, và những trường hợp vi phạm nghiêm trọng hoặc tái diễn có thể dẫn đến việc chấm dứt tài khoản.<br></p> <h4>
                        5. QUY ĐỊNH KHÁC
                    </h4> <p ><i>&#187;  </i> Bạn có thể thay đổi Dữ liệu tài khoản bất kỳ lúc nào bằng cách truy cập trang Thông tin cá nhân.<br> <i>&#187;  </i> Việc yêu cầu, sử dụng, bảo vệ dữ liệu được quy định cụ thể trong Quy chế riêng tư.<br></p> <h4>
                        6. RIÊNG TƯ VÀ BẢO VỆ THÔNG TIN CÁ NHÂN
                    </h4> <p><i>&#187;  </i> Thông tin cá nhân của bạn sẽ được bảo vệ theo các điều khoản của Quy chế riêng tư.
                    </p>
          """,
          style: {
            "i": Style(
              fontSize: FontSize(24),
              fontWeight: FontWeight.bold,
            ),
          },
        ),
      ),
    );
  }
}
