---
title: "LearnGuide"
date: 2026-05-02 14:48:18
tags:
  - note
---

你这份 AVL 写得已经很“能打”了：旋转、插入/删除后的再平衡逻辑都对，说明你**不是只会背概念**，你是能把不变量维护住的人——这就是做 WebServer/系统方向最需要的底子。

你现在问的关键其实只有一个：

> **WebServer 该怎么学，先看书还是先写代码？以及用哪些资源最划算？**

我给你一个“手搓型”的学习流程：**先写最小闭环 → 再读书补洞 → 立刻回到代码验证**。你这种人如果先看完一堆书再写，一定会拖延 + 失去快感。

------

## 一、学习顺序：你适合的“3段式循环”

### 循环单位：1周（或3~5天）

每个循环都遵循这三步：

1. **先清楚大概流程（prepare）**
   写程序之前必须得知道大概框图是怎么样的，可以通过ai或者网上的教程，然后找一个最小流程的代码，一步一步的敲，然后`cout`看看结果会怎么样，渐渐感受每一个子流程都是怎么样的
2. **造一个可运行的小部件（1-2天）**
   例：先写 TCP echo server（accept/recv/send）
3. **用工具把它测崩/测慢（0.5-1天）**
   例：并发连接、发大包、断开连接，看哪里坏
4. **带着问题去读书/看视频（1-2天）**
   只查你刚刚踩到的坑：粘包/半包、阻塞、TIME_WAIT、epoll ET/LT…

> 你不用“学完再做”，你要“做出问题再学”。
> 因为系统知识难度就是非线性的，靠问题牵引最稳。

------

## 二、WebServer需要的知识地图（按你写代码的顺序）

你只需要按这条线补：

1. **TCP socket 基本 API + 连接生命周期**
2. **I/O模型：阻塞 → 非阻塞 → IO复用（epoll）**
3. **并发：线程池/任务队列/锁/条件变量**
4. **HTTP 解析与状态机（请求行/headers/body）**
5. **工程化：日志、超时、连接管理、压测、定位瓶颈**

这 5 块就是你“系统味道”的来源。

------

## 三、资源怎么选：我给你最少但够用的“组合拳”

你时间紧，别收集癖。我建议你只用下面这套（按用途分）：

### A. 写 WebServer 的“代码级路线”（最适合你）

**《Linux高性能服务器编程》（游双）**

- 优点：几乎就是“按章节教你写服务器”的路线，epoll、定时器、线程池这些都贴近工程。
- 你用法：不要从头精读。你每做到一个模块，就读对应章节。

### B. 把网络理解补扎实（面试/调bug都靠它）

**《TCP/IP 详解 卷1》**（不用全读）

- 你只啃：TCP连接/关闭、重传、窗口、TIME_WAIT
- 用法：当字典，遇到现象再查，不要硬啃全书。

### C. 并发与线程（够用即可）

**《C++ Concurrency in Action》**（选读）

- 你目标：会写线程池、知道竞态/死锁/条件变量正确用法
- 不要钻进内存模型深渊（时间不允许）

### D. 操作系统背景（让你讲得更像系统人）

**《Operating Systems: Three Easy Pieces (OSTEP)》**（强推）

- 免费，章节短，适合“用到哪读到哪”
- 你重点：进程/线程、虚拟内存、并发

### E. 看一套“epoll/网络编程”视频补手感（可选）

视频的作用：让你快速建立直觉。
但**不要用视频当主食**，它替代不了写代码和踩坑。

------

## 四、详细学习过程（你照着做就行）

我给你一个“8周开局版”，你先跑通这一段，后面再扩展。
（每周只要交付物，不要求你每天都严格执行）

### 第1周：TCP 最小闭环

- 写：TCP echo server/client
- 学：socket/bind/listen/accept/recv/send，errno
- 测：并发开 100 个连接（脚本/简单循环）
- 读：游双书里对应 socket + 基础章节

**交付物**：能跑 + README + 一个测试脚本

------

### 第2周：把“坑”踩出来

- 加：处理断连（recv=0）、SIGPIPE、短写(short write)
- 学：阻塞调用的返回语义、半包/粘包的概念（先理解，不一定解决）
- 工具：学会 `ss -lntp`、`lsof -i`、`tcpdump` 之一

**交付物**：你写一份《我遇到的3个bug以及怎么修》

------

### 第3周：线程池

- 写：线程池 + 任务队列 + 优雅退出
- 学：mutex/condition_variable，生产者消费者
- 测：高并发下线程池是否会卡死/丢任务

**交付物**：线程池模块独立可复用（像库一样）

------

### 第4周：HTTP 最小实现

- 写：只支持 GET 的 HTTP server（返回固定页面/静态文件）
- 学：HTTP 报文格式、Content-Length、Connection
- 测：curl/浏览器访问

**交付物**：能用浏览器访问到页面

------

### 第5周：压测与数据

- 学工具：`wrk`（优先）或 `ab`
- 输出：QPS/延迟（哪怕先写 avg）+ CPU/内存占用
- 复盘：瓶颈猜测（锁？系统调用？日志？）

**交付物**：一页 benchmark 报告（写在 README 里）

------

### 第6周：epoll + 非阻塞（系统味核心）

- 写：把 accept/read/write 改成 non-blocking
- 写：epoll 事件循环（先 LT，再考虑 ET）
- 学：ET/LT区别，边缘触发为什么容易漏读
- 测：连接数上去后是否稳定

**交付物**：epoll 版本能跑 + 压测对比

------

### 第7周：超时与连接管理

- 写：连接超时关闭（最小堆/时间轮选一个，先做最简单的）
- 学：为什么需要 timeout（防止 fd 泄漏、半开连接）
- 测：客户端连上不发数据，看是否能清掉

**交付物**：timeout 生效的演示

------

### 第8周：调试与定位能力（决定你能不能面试赢）

- 学：gdb + 一种 profiling（perf 或 strace）
- 做：故障注入（比如随机断连/大包/慢客户端）
- 复盘：你怎么定位、怎么修

**交付物**：一篇《一次性能/崩溃定位复盘》

------

## 五、你最关心的：到底是先看书还是先写？

你的情况我给硬结论：

- **先写**（必须先写出能跑的最小服务器）
- **书/视频只负责“补洞”和“纠错”**
- 学习节奏是：**写 70% + 查/读 30%**
  （你是手搓型，这个比例最舒服也最高效）

------

## 六、基于你现在的AVL代码，我给你“下一步升级建议”（更像库代码）

你现在已经在追求“像库”，那 WebServer 也建议你按这种风格来做：

- 把 Node/资源用 **RAII** 管起来（避免到处 new/delete）
- 所有模块都有清晰接口（Logger / ThreadPool / Reactor / Timer）
- 写一个 tiny 的单元测试或自测入口（main 不要越来越臃肿）
- 养成：每次提交都能跑、能测、能复现

------

如果你愿意，我下一条直接给你一个**WebServer项目的“库式目录结构 + 每个模块的接口草图”**（ThreadPool/Logger/Reactor/Buffer/HttpParser），你按接口去手搓实现，既满足你“造轮子”的爽感，也能保证不跑偏。你用 C++17/20 都行。你更想走 **Reactor单线程 + 线程池**，还是 **多Reactor**？（不需要纠结，我也可以默认先给你单Reactor版本，最稳。）



# 1.29



你的 server/client 已经跑通“最小闭环”了，而且代码写得很干净。现在要从 echo 走到 webserver，你的想法“测崩→补洞→改→再测”完全正确——**但要按层次走**，否则你会被无意义的崩溃/卡死拖着跑。

我给你一条**6–8 周路线**（每一步都有：目标/你要刻意把它测崩的点/你该查什么/产出物）。你就照着循环推进。

------

## 你现在这份 echo 代码，最先要“刻意测崩”的 5 个点（立刻能做）

先别急着上 HTTP，先把 TCP 层做“可靠”。

### 1）短写（你现在 `send` 没处理短写）

**测崩方式：**发 2MB 随机数据，对比回显是否一致（我之前给过脚本）
**修复：**写 `send_all()` 循环直到写完
**产出：**`send_all()` + 一个 `big_payload_test.py` 能自动验证

### 2）SIGPIPE（对端关了你 `send` 可能把进程打死）

你现在 server 没忽略 SIGPIPE（有些情况下会直接退出）。
**测崩方式：**客户端发一半就强制 kill（或关掉读端），让 server 在写时触发
**修复：**`signal(SIGPIPE, SIG_IGN)` 或 `send(..., MSG_NOSIGNAL)`
**产出：**一条复现命令 + 修复说明

### 3）慢客户端导致阻塞（单线程阻塞版会被拖死）

**测崩方式：**写个客户端只连不读，再并发其他连接，看 server 卡住
**修复方向：**后续的 epoll/非阻塞/或线程池就是为这个问题服务的
**产出：**一份“为什么需要并发模型”的证据（日志+现象）

### 4）连接只能 accept 一次（你现在只 accept 一次，后续应该循环 accept）

这不是崩溃问题，但会让你误判“webserver 不行”。
**修复：**accept 放进循环（至少能服务多个连接）

### 5）`sockaddr_in serv_addr` 未清零（client）

虽然通常不崩，但严格来说要 `memset` 或 `{}`。
**修复：**`sockaddr_in serv_addr{};`

------

## WebServer 学习路线（从 echo → 最小 HTTP → 并发 → 工程化）

下面这条路线你就当成“迭代闭环”，每一阶段都是：
**做出最小版本 → 用测试把它打出问题 → 查资料补洞 → 修复 → 记录复盘**

### Phase 0（1–2 天）：Echo 可靠化（把 TCP 层打扎实）

**目标：**你的 echo 在下面测试下“不崩、不丢、不死锁、不泄漏 fd”。
**测试清单：**

- 并发 500 次连接（短连接）
- 2MB 大包回显一致
- 连接立刻断开
- 慢客户端（只连不读）
  **你需要查的权威点：**
- `man 2 recv` / `man 2 send`：返回值语义、短写短读、errno
- `man 7 socket`：SIGPIPE/关闭语义
  **产出：**
- `send_all()`
- 一份 `tests.md`（写下你用的测崩命令）

> 做完 Phase 0，你才算“掌握 TCP echo”，否则后面 HTTP 的 bug 你会分不清是协议问题还是 I/O 问题。

------

### Phase 1（2–4 天）：最小 HTTP Server（阻塞 + 单连接/短连接）

**目标：**浏览器访问 `http://127.0.0.1:8080/` 能看到一段文本。
**实现只要：**

- 读到 `\r\n\r\n`（请求头结束）
- 解析第一行：`GET /path HTTP/1.1`
- 返回固定响应（Content-Length 正确）
  **测崩点：**
- 用浏览器/`curl -v` 访问
- 请求头很长（你要能处理分段 recv）
- 请求分多次到达（粘包/半包：你必须用 buffer 累积）
  **查什么：**
- RFC 9112（HTTP/1.1）你只看：请求行/头部格式、CRLF 规则、Content-Length/Connection
  **产出：**
- `http_server_blocking.cpp`
- `curl_test.md`（几条 curl 命令）

------

### Phase 2（1 周）：多连接能力（两个路线选一个都行）

你要在这里做选择：**线程池（简单）** or **epoll（更系统味）**。
我建议：**先线程池，再 epoll**（难度更线性）。

#### 2A 线程池版（推荐先做）

**目标：**accept 一个连接就丢到线程池处理（短连接），能并发。
**测崩点：**

- 1000 并发短连接
- 慢客户端拖不死整个 server（至少还能 accept 新连接）
  **查什么：**
- `pthread`/`std::thread` 基本用法、互斥/条件变量（或你自己实现一个任务队列）
  **产出：**
- `ThreadPool` + `BlockingQueue`
- 线程池优雅退出（stop/join）

#### 2B epoll Reactor（更像“系统开发”）

**目标：**单线程 epoll 管理很多连接（非阻塞）
**测崩点：**

- ET/LT 模式差异（建议先 LT）
- EAGAIN/EWOULDBLOCK 处理正确
  **查什么：**
- `man 7 epoll` / `man 2 epoll_wait`
- 非阻塞 I/O 的正确循环
  **产出：**
- `EventLoop` + `Connection` + `Buffer`

------

### Phase 3（1–2 周）：把它变成“像个 web server”

**目标：**不是能跑，而是“能被用”。
你按需求加功能，每加一个都要配测试：

- 静态文件：`GET /index.html` 返回文件内容
  - 测：大文件、二进制文件、404
- Keep-Alive：同一连接多个请求
  - 测：curl `--http1.1` 多次请求、连接复用
- 超时关闭：空连接 30s 关掉
  - 测：只连不发数据
- 日志：访问日志/错误日志
  - 测：并发下日志不乱

------

### Phase 4（持续）：压测 + 复盘（这一步会让你“像工程师”）

**目标：**你能用数据说话：QPS、延迟、CPU、连接数。
工具：

- `wrk` 压测 HTTP
- `ss` 看连接
- `strace` 定位卡住点
  **产出：**
- `bench.md`：每次优化前后数据对比
- `postmortem.md`：一次 bug 的复盘模板

------

## 你问“是不是就按测崩→看书→思考→改→循环？”

是的，但给你一句更工程化的版本：

> **先用测试把问题“证据化”，再去查资料定位“语义”，最后用代码修复并用同一个测试验证。**

不推荐：遇到问题就先看大段书。
推荐：先把问题复现出来，书只当“查字典”。

------

## 你现在最该走的下一步（我替你拍板）

**下一步就做 Phase 0：Echo 可靠化**，按下面顺序：

1. 把 server 的 `accept` 放进循环（能服务多个连接）
2. 写 `send_all`（修短写）
3. 忽略 SIGPIPE（防止被打死）
4. 跑 4 个测崩测试（并发、断连、大包、慢客户端）
5. 记录 `tests.md`

你做完这 5 步，再上 HTTP，你会非常顺。

------

如果你愿意，我可以直接帮你把你的 server 代码改成 **“可多连接 + send_all + SIGPIPE 防护 + 更稳的错误处理”** 的版本（保持你现在的写法风格），然后给你一份“测崩脚本/命令集合”。你贴一下你想用的端口（仍然 8080 可以）以及你希望是“短连接（每次请求就关）”还是“先短连接，后面再做 keep-alive”。

# 2.5

可以，**把 `send_all`（以及对应的“按需 recv”）做对之后，你就有资格进入 HTTP** 了——但你列的那三条里，**只有“短写”是 `send_all` 直接解决的**，另外两个不是。

我把你列的每一项拆开说清楚：它是什么、是不是 send_all 能解决、你要做到什么程度才够进入 HTTP。

------

## 1) 处理断连（`recv = 0`）是什么？

**含义：**
`recv()` 返回 0 表示：**对端已经“正常关闭写端”**（发了 FIN），也就是“连接结束/对端不再发数据”。

**你要做的事：**

- 把它当作“读到了 EOF”，退出连接处理循环，`close(fd)` 回收资源。
- 不要把 0 当成错误，也不要继续 recv（会一直 0）。

**这不是 send_all 能解决的。**
send_all 解决的是“我想发 N 字节，确保发完”，而 `recv=0` 是“对端不再发了”。

> 在 HTTP/1.1 里：如果你做 keep-alive，你需要能识别 `recv=0` 并正确关闭连接；否则会出现死循环或 fd 泄漏。

------

## 2) SIGPIPE 是什么？

**现象：**
你对一个已经被对端关闭的连接调用 `send()`，默认情况下内核可能发 `SIGPIPE`，**直接把你的进程干掉**（程序莫名其妙退出）。

**怎么处理：**

- 最常见：程序启动时忽略它
  `signal(SIGPIPE, SIG_IGN);`
- 或者 send 时加 `MSG_NOSIGNAL`（Linux）
  `send(fd, buf, len, MSG_NOSIGNAL);`

**这也不是 send_all 能解决的。**
send_all 只是循环 send，但如果不处理 SIGPIPE，你循环里的第一次 send 就可能把进程打死。

> WebServer 必做：忽略 SIGPIPE 或 MSG_NOSIGNAL，否则压测时会“随机崩”。

------

## 3) 短写（short write）是什么？是不是 send_all 能解决？

**短写：**
`send(fd, buf, n)` 返回值可能是 `m`，其中 `0 < m < n`，表示只发出了一部分。

**原因：**

- 内核发送缓冲区满了
- 对端接收慢
- 网络拥塞等

✅ **这个就是 send_all 解决的核心问题。**
send_all 的意义就是：短写就继续发剩下的，直到发完或者遇到错误。

> 注意：阻塞 socket 下短写较少，但并不是不会；非阻塞下短写非常常见。

------

## 4) “阻塞调用的返回语义”是什么意思？

就是你得清楚这些系统调用**每一种返回值代表什么**，以及应该怎么做：

以 `recv()` 为例：

- `> 0`：读到了这么多字节
- `= 0`：对端关闭（EOF）
- `< 0`：
  - `errno == EINTR`：被信号打断，**重试**
  - `errno == EAGAIN/EWOULDBLOCK`：非阻塞下“现在没数据”，**等下次事件**
  - 其他：真正错误，处理并关闭连接

以 `send()` 为例：

- `> 0`：发出这么多字节（可能短写）
- `< 0`：
  - `EINTR`：重试
  - `EPIPE/ECONNRESET`：对端断了
  - `EAGAIN`：非阻塞下“现在发不出去”，等 EPOLLOUT

这套语义是你进入 HTTP / epoll 的入场券。

------

## 5) 半包/粘包是啥？和 send_all 的关系？

**半包/粘包**是 TCP 字节流导致的现象：

- 半包：一个 HTTP 请求被拆成多次 recv 才到齐
- 粘包：一次 recv 读到了两个 HTTP 请求甚至更多

**send_all 解决不了半包/粘包。**
send_all 解决的是“写出去完整”，但 TCP 仍可能把你写出去的字节拆成任意段给对方。

半包/粘包的解决方案是：

- **InputBuffer（输入缓冲）**：把多次 recv 的数据累积起来
- **增量解析（状态机）**：能在数据不完整时“先不解析完，等下一批”

> 做 HTTP 必须面对半包/粘包，因为 HTTP 的边界不是“读一次就结束”，而是：`\r\n\r\n` 结束头部，body 由 Content-Length 决定长度。

------

# 结论：你现在到 HTTP 的“最低门槛”是什么？

你做到下面这些，就可以开始 HTTP（先做最小 GET）：

✅ **写方向**

- `send_all`（处理短写 + EINTR）
- 处理 SIGPIPE（忽略或 MSG_NOSIGNAL）

✅ **读方向**

- `recv`：正确处理 `>0 / =0 / <0(EINTR)`
- （暂时不用处理 EAGAIN，因为你还是阻塞模式）

✅ **概念理解**

- 明白“TCP 是字节流 → 会半包/粘包”，并接受你需要 InputBuffer

------

# 给你一个“先做 HTTP 不会翻车”的最小路线（不需要 epoll）

1. 保持阻塞模型
2. 引入 `InputBuffer`：每次 recv append 进去
3. 在 buffer 里找 `\r\n\r\n`：找到了就说明 headers 齐了
4. 解析请求行 + headers（先只支持 GET、忽略 body）
5. 生成响应：固定 Hello 或静态文件 + `Content-Length`

这条路线不会把你一下拖进 reactor/epoll 的复杂度。

------

如果你愿意，把你现在的 `send_all` 和 `recv` 处理（你自己写的那版）贴出来，我可以快速帮你检查：

- 有没有遗漏 EINTR
- SIGPIPE 是否会杀进程
- 逻辑是否会在对端关闭时卡住
  检查完你就能非常稳地进入 HTTP。

# 2.8

下面按你要“手搓 Reactor / epoll，并且每一步都清楚”的标准来讲（偏 Linux C/C++ 服务端，ET/LT、非阻塞、边界条件都点到）。

## 1) 是什么、解决什么问题（≤5句话）

- **Reactor** 是一种事件驱动架构：主线程（或事件循环线程）只负责**监听事件、分发事件**，真正的业务处理由回调/处理器完成。
- **epoll** 是 Linux 下高性能 I/O 多路复用机制，用来在单/少量线程里同时管理大量 socket 的可读/可写/异常事件。
- 解决的问题：传统“一个连接一个线程/进程”在高并发下线程切换和内存成本巨大；阻塞 I/O 会导致线程空等。
- Reactor + epoll 通过“**事件就绪才处理**”，把 CPU 用在真正有 I/O 的连接上。
- 最常见组合：**非阻塞 socket + epoll + 事件循环 + 回调分发**（可选线程池做业务）。

------

## 2) 流程图 / 步骤序列（从开始到结束）

我用“你手搓 WebServer 的最小可跑版本”来写：**单线程 Reactor（一个 event loop）**，支持 accept + read/write 回显/HTTP 都能套。

### 总流程（文字流程图）

1. **初始化监听 socket**
2. **创建 epoll 实例**
3. **把 listen_fd 加入 epoll（关心 EPOLLIN）**
4. **进入事件循环 while(running)**
   1. `epoll_wait()` 拿到就绪事件数组
   2. 遍历每个事件：
      - 如果是 `listen_fd` 可读 → **accept 循环**接入新连接 → 设非阻塞 → 加入 epoll
      - 否则是 `conn_fd`：
        - 可读 → **读循环**把数据读到应用缓冲区 → 业务处理 → 决定是否关注可写
        - 可写 → **写循环**把待发送缓冲刷出去 → 刷完后取消可写关注
        - 异常/挂断 → close + 从 epoll 移除
5. **退出时清理：close 所有 fd，close epoll_fd**

> 你要“精确到每一步”，下面第 3 部分我把每一步拆到 API、返回值、失败含义和关键术语。

------

## 3) 每一步关键 API/术语 + 返回值/失败含义（只列最重要的）

> 你手搓时最容易翻车的点：**非阻塞 + 读写循环 + epoll 事件语义（EPOLLRDHUP/EPOLLHUP/EPOLLERR）+ ET/LT 区别 + 修改关注事件**。我按真实工程顺序列。

### Step A：创建监听 socket（listen_fd）

**关键 API**

- `socket(AF_INET, SOCK_STREAM, 0)`
  - 返回：`>=0` 为 fd；`-1` 失败（看 `errno`）。
- `setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, ...)`
  - 返回：`0` 成功；`-1` 失败。
  - 含义：避免“端口占用/ TIME_WAIT 影响重启”（不等于解决一切占用问题）。
- `bind(listen_fd, ...)`
  - `0` 成功；`-1` 失败（常见：权限、端口占用、地址不合法）。
- `listen(listen_fd, backlog)`
  - `0` 成功；`-1` 失败。

**关键术语**

- backlog：半连接/全连接队列相关（实现相关，但你只要知道太小会丢连接/排队）。

------

### Step B：把 fd 设为非阻塞（非常关键）

**关键 API**

- `fcntl(fd, F_GETFL)` / `fcntl(fd, F_SETFL, flags | O_NONBLOCK)`
  - `F_GETFL` 返回 flags；失败 `-1`。
  - `F_SETFL` 成功返回 `0`；失败 `-1`。

**失败意味着什么**

- 你如果不用非阻塞：在 Reactor 里一旦 `read/write/accept` 阻塞，就会卡死整个事件循环。

**关键术语**

- Non-blocking I/O：配合 epoll 才能做到“就绪才处理 + 不空等”。

> 实战建议：**listen_fd** 和 **conn_fd** 都设非阻塞（尤其是你用 ET 模式时，accept/读写必须循环直到 EAGAIN）。

------

### Step C：创建 epoll 实例（epoll_fd）

**关键 API**

- `epoll_create1(EPOLL_CLOEXEC)`
  - 返回：`>=0` epoll_fd；`-1` 失败。
  - 术语：CLOEXEC 防止 fd 泄漏到 exec 出去的子进程。

------

### Step D：把 listen_fd 注册到 epoll（关注可读）

**关键 API**

- `epoll_ctl(epoll_fd, EPOLL_CTL_ADD, listen_fd, &ev)`
  - 成功 `0`；失败 `-1`。
- `struct epoll_event ev; ev.events = EPOLLIN; ev.data.fd = listen_fd;`

**失败意味着什么**

- `EEXIST`：重复 ADD（你应该用 MOD）。
- `EBADF`：fd 无效/已关。
- `EINVAL`：参数/epoll_fd 不对。

**关键术语**

- interest list：epoll 里你“关心的事件集合”（你注册的 fd+事件）。
- ready list：就绪事件集合（epoll_wait 返回的）。

------

### Step E：事件循环：epoll_wait

**关键 API**

- `n = epoll_wait(epoll_fd, events, maxevents, timeout)`
  - 返回：
    - `n > 0`：有 n 个事件
    - `n == 0`：超时（timeout=0 轮询；timeout=-1 永久等）
    - `n == -1`：失败（常见 `errno=EINTR` 被信号打断 → 继续循环）

**失败意味着什么**

- EINTR：不是致命错误，通常 `continue`。

**关键术语**

- Event loop：整个 Reactor 的“心跳”，所有 fd 都靠它驱动。

------

### Step F：处理 listen_fd 事件 → accept 新连接（必须讲清楚）

**关键 API**

- `accept4(listen_fd, &addr, &len, SOCK_NONBLOCK | SOCK_CLOEXEC)`（推荐）
  - 返回：`>=0` conn_fd；`-1` 失败。
- 或 `accept()` + `fcntl(O_NONBLOCK)` 分两步。

**最关键的“精确步骤”**

1. 收到 `listen_fd` 的 `EPOLLIN`
2. **循环 accept**（尤其 ET 模式必须循环）：
   - `while ((conn_fd = accept4(...)) >= 0) { ... }`
3. 循环退出时：
   - 如果 `errno == EAGAIN || errno == EWOULDBLOCK`：说明**已把队列里的连接接空**（正常）
   - 其他 errno：说明 accept 真失败（记录日志）

**把 conn_fd 注册进 epoll**

- `epoll_ctl(ADD, conn_fd, EPOLLIN | EPOLLRDHUP | EPOLLERR | EPOLLHUP | (可选EPOLLET))`

**关键术语**

- EPOLLRDHUP：对端关闭写端（半关闭），很常用来更快感知断开。
- 惊群：epoll 本身不自动解决所有 accept 惊群，多进程/多线程 accept 需要额外策略（你先做单 Reactor 版本可忽略）。

------

### Step G：处理 conn_fd 的可读事件（读到“读空”为止）

**关键 API**

- `recv(conn_fd, buf, size, 0)` 或 `read(conn_fd, ...)`
  - 返回：
    - `>0`：读到 n 字节
    - `==0`：对端关闭连接（FIN）→ close
    - `-1`：失败
      - `errno == EAGAIN/EWOULDBLOCK`：**当前没数据了**（非阻塞正常结束）
      - `errno == EINTR`：被信号打断 → 重试
      - 其他：连接错误 → close

**精确的读循环**

- 收到 EPOLLIN 后：`while (true) { n = recv(); if(n>0) append; else if(n==0) close; else if(EAGAIN) break; else if(EINTR) continue; else close; }`

**关键术语**

- 应用层输入缓冲区（input buffer）：你不能假设一次 read 就拿到完整 HTTP 请求；必须缓冲+解析。
- 半包/粘包：TCP 流式，没有消息边界。

------

### Step H：业务处理（Reactor 的“分发”）

**这里 Reactor 的本质是：事件循环不做重活，只做“调度”**

- 简单回显：把 input buffer 直接放到 output buffer
- HTTP：解析请求行/头/体 → 生成响应 → 放 output buffer

**关键术语**

- Handler/Callback：事件对应的处理函数（比如 onReadable/onWritable/onClose）。
- 分离 I/O 与业务：I/O 驱动缓冲，业务只读写缓冲。

> 你后面要上线程池时：通常做法是 **I/O 线程负责读写缓冲 + 投递任务**，工作线程只处理业务并产出输出缓冲，再由 I/O 线程发送（避免多线程直接写 socket）。

------

### Step I：处理 conn_fd 的可写事件（把 output buffer 写空）

**关键 API**

- `send(conn_fd, buf, len, 0)` 或 `write()`
  - 返回：
    - `>0`：写出 n 字节（从 output buffer 消费掉 n）
    - `-1`：
      - `EAGAIN/EWOULDBLOCK`：发送缓冲满了，等下次 EPOLLOUT
      - `EINTR`：重试
      - 其他：错误 close

**精确的写策略**

1. 只有当 output buffer 非空时，才需要关注 `EPOLLOUT`
2. 收到 `EPOLLOUT`：循环 send，直到
   - 写空 output buffer → **立刻取消 EPOLLOUT 关注**（epoll_ctl MOD）
   - 或遇到 EAGAIN → 保持关注 EPOLLOUT，等待下次就绪

**为什么要“写空就取消 EPOLLOUT”**

- `EPOLLOUT` 通常非常“容易就绪”（大部分时间都可写），不取消会让 event loop 空转。

------

### Step J：异常/断开处理（你必须处理这几个 flag）

**你在遍历 epoll 返回事件时，优先检查：**

- `EPOLLERR`：fd 出错（用 `getsockopt(fd, SOL_SOCKET, SO_ERROR, ...)` 获取具体错误），通常 close
- `EPOLLHUP`：挂断，通常 close
- `EPOLLRDHUP`：对端关闭写，通常 close（或按你的协议处理半关闭）

**关键 API**

- `close(fd)`
- `epoll_ctl(EPOLL_CTL_DEL, fd, nullptr)`（close 也会让内核清理，但显式 DEL 更清晰）

------

### Step K：ET vs LT（你手搓时最关键的模式选择）

**LT（Level-Triggered，默认）**

- 只要“还有数据没读/还有空间可写”，事件会反复通知
- 容错高，适合新手先跑通

**ET（Edge-Triggered，需要 `EPOLLET`）**

- 状态从“无→有”才通知一次；如果你没在一次回调里把数据读空（直到 EAGAIN），可能就**再也收不到通知**（假死）
- 必须：fd 非阻塞 + read/accept/write 都“循环到 EAGAIN”

> 建议你：**先 LT 跑通，再切 ET**。因为你要手搓理解过程，LT 更直观。

------

## 4) 5 个权威入口（用于校准）

1. `man 7 epoll`（epoll 语义、LT/ET、典型用法说明）
2. `man 2 epoll_wait` / `man 2 epoll_ctl`（返回值、errno、事件 flag）
3. `man 2 accept4`（推荐的非阻塞+cloexec 一步到位）
4. `man 2 fcntl`（O_NONBLOCK 设置、踩坑点）
5. RFC 9293（TCP 规范，理解 FIN/半关闭/粘包本质；旧版可参考 RFC 793，但以 9293 为现行整合版）

------

如果你下一步要继续“手搓到能写代码”的层面，我建议你按这个顺序推进（不需要你问我，我直接给你最优学习路线）：

1. 单线程 Reactor + LT + 回显（只管 read→write）
2. 加入 input/output buffer（解决半包）
3. 支持 HTTP 解析（最小 GET）
4. 改 ET（所有循环到 EAGAIN）
5. I/O 线程 + 线程池（业务 offload）

你要我把上面的步骤进一步压成“你可以照着写代码的伪代码骨架（不贴完整代码，但每个函数签名+核心循环）”，我也能给。
