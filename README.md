# Cheat Engine Plugin

1. 下载zip文件, 将所有文件解压到`<CE-DIR>/autorun/`文件夹下
2. 下载[PL](https://github.com/lunarmodules/Penlight/tree/master/lua/pl)到`<CE-DIR>/lua/pl`
3. 重启Cheat Engine

## timer在脚本中简单的使用计时器

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

## getJmpNewBytes
获取新的跳转字节集
```
local newJmpBytes = getJmpNewBytes(0x008E05AE, 0x01350000, 5, { 0xE9 })
writeBytes(0x008E05AE, newJmpBytes)
```

- dump(table): nil  打印table
- isInjectPluginDLL(): bool 是否注入了 CE_Plugin.dll
- dumpProps(obj): void  打印一个对象的属性列表
- dumpComps(obj): void  打印子组件的名称列表
- exitWindowsEx(number val): bool  0关机 1重启 2注销 
- hexPaddingZero(number num, number? len): string 返回补零后的hex字符串
- Target模块中有一些属性和方法,具体的函数参数可以查看`Target.lua`文件
    ```
    dump(Target)

    -- print
    {
      autoClickWindow = "function: 000000000F1CC400",
      caption = "Game",
      exeDir = "C:\\Users\\ajanuw\\Desktop\\",
      exePath = "C:\\Users\\ajanuw\\Desktop\\game2.exe",
      getExeDir = "function: 000000000F1CC190",
      getExePath = "function: 000000000F1CBC80",
      getModuleName = "function: 000000000F1CBFE0",
      getParent = "function: 000000000F1CBDA0",
      getWindow = "function: 000000000F1CC5B0",
      getWindowRect = "function: 000000000F1CC5E0",
      getWindowTextW = "function: 000000000F1CC4C0",
      hide = "function: 000000000F1CC070",
      hwnd = 985586,
      moduleName = "game2.exe",
      moveWindow = "function: 000000000F1CBEF0",
      pid = 12204,
      show = "function: 000000000F1CC1C0",
      showWindow = "function: 000000000F1CC1F0",
      windowIsTop = "function: 000000000F1CC010"
    }
    ```