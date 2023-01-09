電腦 Line 鈴聲靜音程式
===
## Line 鈴聲靜音


部落格說明：https://charlottehong.blogspot.com/2021/01/2021-line.html  


```ps1
# 開啟靜音模式
irm bit.ly/LineMute|iex; LineRingMute -Enable

# 關閉靜音模式
irm bit.ly/LineMute|iex; LineRingMute -Disable
```

<br>

![](img/Cover.png)

<br><br><br>



## Line 自動更新
部落格說明：https://charlottehong.blogspot.com/2023/01/line.html  

```ps1
# 關閉自動更新
irm bit.ly/LineUpdate|iex; LineRingMute -Disable

# 恢復自動更新
irm bit.ly/LineUpdate|iex; LineRingMute -Enable
```
