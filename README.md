** 随着 flutter 的兴起，越来越多的公司开始使用 flutter ，最近一老同事问我关于如何使用 flutter 实现一个你画我猜的小游戏，现把这个分享给大家~ **

## 已实现的功能
* 画板自由涂鸦
* 选择画笔颜色
* 选择画笔大小
* 撤销到上一步
* 反撤销
* 清空画布
* 橡皮擦
* 基于 WebSocket 实时发送到服务器
* WebSocket 服务端转发给其它连接
* 接受 WebSocket 的消息内容绘制

## 使用到的技术
* 基础组件的使用（Scaffold、AppBar、IconButton、Container、Column、Stack、Padding、Icon 等）
* 自定义 CustomPainter ，在 Canvas 上使用 Paint 绘制
* 手势识别 GestureDetector 事件的使用
* Flutter 基于 Provider 插件的状态管理实现
* 简单的实现 WebSocket 通讯（真实项目考虑的问题要更多，比如心跳，重连，网络波动处理等）

## 最终效果
三屏实时同步
![](https://user-gold-cdn.xitu.io/2020/4/30/171ca25d168fa574?w=1440&h=1080&f=png&s=2165776)
