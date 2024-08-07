app逆向的一般流程

### `返回数据加密`

> QZJjgNVI09gS0qpKpHlh9K9bETc8nNIRhJMqP7xPLz/1cfpktgGj2feDE9hCwDo5cxj3aHpvrxI=

### `请求参数加密`

> token：784fedc9cd37912a3a4cf7eb1795048e

### `查壳、脱壳、反编译`

这一步我们要拿到反编译后的`app源码`，在源码中查找加密方法，如果熟悉安卓开发的可以去`安卓编辑器`中的进行调试，这样方便得多。

- 使用查壳软件进行 `app查壳`，一般来说`腾讯加固`和`360加固`是比较常见的

- 使用`Xposed+FDex2`进行`砸壳`、提取出 `.dex` 源文件

- 使用`jadx`工具进行源码查看(直接打开砸出来的 `.dex` 文件即可)，自带`反混淆`功能，还是比较好用的

出来的`java层`代码大概是这样的

---
![](images/QQ图片20210701093258.png)

### 查找加密方法调用

有了反编译出来的源码，下面就要进行逻辑代码的调试了，目的就是为了搞清楚它是如何加密的

- 搜索关键字和方法名
  比如你的加密参数是 `token` 那就尝试直接在jadx中搜索 `token` 然后定位到可疑之处具体查看

一般的搜索关键词:

- `api路径`，比如 `/user/login`
- `token、key、md5、base64、DES、AES等`

### 复写它

用 `Python` 复写前面抠出来的`加密流程代码`、集成到自己的项目中