# 开发者

## 先睹为快

```bash
# 配置token
gt.token <Your token>

# 保存本地，持久化token
gt.config.save
```

然后，你就可以畅享gitee的能力。

## 创建仓库

## 列举仓库


## 多用户支持

```bash
gt.make lisa
O=lisa gt.token <Lisa's token>
O=lisa gt.config.save
O=lisa gt.repo.create lisa/x-bash

gt.make tom
O=tom gt.token <Tom's token>
O=tom gt.config.save
O=tom gt.repo.create tom/x-bash
```


更OO的用法

```bash
gt.new lisa
lisa.token <Lisa's token>
lisa.config.save
lisa.repo.create lisa/x-bash

gt.new tom
tom.token <Tom's token>
tom.config.save
tom.repo.create tom/x-bash
```


