将lua文件放在autorun文件夹下，重启Cheat engine使用.

## timer 在脚本中简单的使用计时器

每隔100毫秒执行一次:
```
{$lua}
if syntaxcheck then return end

[ENABLE]
local addr = 0x2001DCD8
id = setInterval(function()
  writeInteger(addr , readInteger(addr)+1)
end, 100)

[DISABLE]
clearInterval(id)
```

延迟100毫秒，然后只执行一次:
```
{$lua}
if syntaxcheck then return end

[ENABLE]
local addr = 0x2001DCD8
id = setTimeout(function()
  writeInteger(addr , 999999)
end, 100)

[DISABLE]
```

## movbe 对应asm的`movbe`指令

在地址列表上添加右键菜单movbe选项，在新的视图中查看转换后的值

通常这个值的类型为4字节

![](./images/2020-06-25-18-01-36.png)


## autorunMonoMethod
激活mono，并自动编译jit函数
```
{$lua}
  if syntaxcheck then return end
  _checkMonoMethod('PlayerAttribute', 'set_currentEnergy')
{$asm}
```