RE修復系統編輯工具
===

![](img/Cover.png)

### 移除硬碟上的RE分區
移除硬碟上的分區並自動合併剩餘空間到前一個磁碟區。

```ps1
irm bit.ly/3tzM2tq|iex; EditRecovery -Remove
```

移除之後會順便關掉 RE修復系統，如果不關掉下一次更新或是進入RE系統一樣會再次產生RE分區。  
移除之後想立刻啟用可以在結尾加上啟用

```ps1
irm bit.ly/3tzM2tq|iex; EditRecovery -Remove -Enable
```

## 其他命令
```ps1
# 查看當前狀態
EditRecovery -Info

# 啟用 RE系統
EditRecovery -Enable
# 關閉 RE系統
EditRecovery -Disable

# 重設 Winre.wim 檔案
EditRecovery -SetReImg
# 重設 Winre.wim 檔案，並重新指定檔案
EditRecovery -SetReImg -ImgPath:"D:\ImgPath"
```