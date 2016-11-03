get,post区别

|      | get                    | post          |
| ---- | ---------------------- | ------------- |
| 来源   | 地址栏，超链接，form表单，ajax    | form表单，ajax   |
| 传递类型 | 通过URL传递参数，明文传递         | 不是明文传递        |
| 携带   | 携带信息量不大，2048个字节        | 携带信息量很大，无限制   |
| 幂等性  | 幂等请求，多次请求的状态(server)一致 | 非幂等请求，后端状态不一致 |
|      |                        |               |



servlet context

用来做什么？

如何获取？

- servlet.getServletContext()  该方法属于GenericServlet类
- ServletConfig
- FilterConfig
- HttpSession

为什么需要context？



返回页面历史



web.xml中path和servlet的关系不能1:n，而Filter中可以1:n。



WEB-INF目录

WEB-INF目录是Web应用程序的标志，客户端无法通过url访问，只有服务器才可以访问



doGet()和doPost()的上级是service()



client请求的是资源(html，图片，声音，视频)，server返回的是内容(同请求)。











