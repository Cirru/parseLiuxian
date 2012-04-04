
原因  
--

这里有篇文章阐释了很简单的`Lisp`解释器  
代码量非常小, 所以我想用`CoffeeScript`照着做一遍看看  
<http://www.googies.info/articles/lispy.html>
我的目标是能定义函数和运行函数  

探索  
--

后来我借鉴`S-expression`语法, 特别是`Scheme`缩进版本, 开始玩  
`SibilantJS`这个项目对我的触动很大, 我开始做前搜索找到的  
<http://sibilantjs.info/>
这个项目对我的触动很大, 只是代码大部分我还看不懂  
还有个搭上边, 我关注, 但完全看不懂的, 目标大概类似  
<https://github.com/jlongster/outlet>
当然这这些到底是`Lisp`系的语言, 而不是`JS`  

我大概的想法是创建一种`Lisp`语法语言, 但可以缩进替代部分括号  
然后宏还有符号类型都是假的, 也就是本身其实是`JS`, 只是加语法糖  
总之, 我尝试了, 对`Lisp`当初的设计随着自己动手越发佩服  
特别一点是代码和数据的转换, 猜想未来这是我突破的重点  
最后为了可读性用了一个类库, 对`JS`格式进行转换  
<https://github.com/einars/js-beautify>

目标  
--

假如未来我能够完成, 目前我有若干个期待:

* 语法是括号和缩进配合的, 另外当前有个`\`用来控制行
* 但行注释定格写, 代码在行首有不少于两个空格, 为了`Markdown`和`Docco`
* 用`http`模块和`XMLHttpRequest`对象请求网上的脚本`eval`到代码
* 特别是浏览器环境, 也许`ES`新的`import`出来了就有的玩了
* 发现了变量的类型区分, 还有作用域控制是极为重要的, 需要去学
* 有可能的话, 未来学习靠拢`Lisp`和`Haskell`, 现在只能羡慕
* 完成的话我再去学`Sublime Text`写语法高亮玩

状态  
--

尝试了, 代码量很低级, 也许看`commit`能看懂一些意思吧  
我大概实现了一些语法的转换, 最后发现细节有无法控制的参差  
目前**放弃**继续尝试, 以后有能力再来, 因此留些笔记, 具体看`commit`  
这段时间也因此开始不喜欢`coffee`, 宿主语言`JS`弱爆了, 对比`Lisp`系  
即便`Python`处理列表之类也更理智一些, 不知道`Ruby`怎样  
总之有机会的话, 等待大神们用各种语言攻占浏览器, 还有`SourceMap`  

原理  
--

目前比较幼稚, 我的步骤大概是这样的  

* 读取文件, 过滤注释, 增添括号, 给出满足圆括号的代码数组
* 大致有个遮罩字符串中某些符号的过程, 解析完成后恢复
* 拼接数组为字符串, 将字符串解析到多维数组
* 运行多维数组, 适当这个判断, 不出开头引文的想法
* `fetch`部分用了回调, 创建作用域, 但没有成功

因为没有正当的学习, 正经的此发分析我还不会, 工具比较弱  
学会之后再回来看下, 我倾向于`Lisp`语法的原因是对符号的宽松  

例子  
--

赋值`var a = 2;`

    var a 2
改变变量`a = 3;`

    let a 3
创建数组`[1, 2, 3, 4, 5]`

    arr 1 2 3 4 5
`cut`用来对数组和字符串进行切片`a.splice(1,2);`

    cut a 1 2
创建对象`{a: 1, b: 2}`

    obj (a 1) (b 2)
缩进和括号的转换`{a: 1, b: 2}`

    obj
      a 1
      b 2
`\`在行首用来标记合并的上一行`[1, 2, 3, 4, 5]`

    arr 1 2 3
    \ 4 5
`\`在行中转化为'(': `var a = [1, 2, 3]`

    var a \ arr 1 2 3
`new`建立对象`new Date()`

    new Date
`fn`用来创建函数`function f(a){return 0;}`  
这个有不少漏洞...

    fn (f a)
      return 0
`if`语句实际上是`cond`: `if(2>1){return 0;}else{return 1;}`

    if \ (> 2 1)
        return 0
      else
        return 1
`while`语句`while(a>1){console.log(a);a-=1;}`

    while (> a 1)
      console/log a
      var a (- a 1)
调用属性 / 方法之类的`obj['attr']['index'](arg,arg)`

    obj/attr/index arg arg
有时对象不方便直接写在前边`[1, 2, 3].map(handler);`

    /map (arr 1 2 3) handler
级联用单独的函数了`str.replace('2', '4').indexOf('2');`

    chain str
      replace '2' '4'
      indexOf '2'
至于`fetch`.. 比较长, 我尝试用`http.request`求, 有那个意思, 不实用
