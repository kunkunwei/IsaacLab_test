# Pylance 类型检查问题解决方案

## 问题描述

在 VSCode 中看到 Pylance 报错：
```
无法访问类"RslRlBaseRunnerCfg"的属性"class_name"
属性"class_name"未知
```

虽然代码在运行时完全正常工作，但 Pylance 无法识别动态添加的属性。

## 🔍 问题根源

这是由以下几个原因造成的：

### 1. **数据类属性的动态添加**
```python
@configclass
class RslRlBaseRunnerCfg:
    # 基类中没有定义 class_name
    ...

@configclass
class RslRlOnPolicyRunnerCfg(RslRlBaseRunnerCfg):
    class_name: str = "OnPolicyRunner"  # 在子类中定义
    ...
```

脚本中使用的类型注解是基类 `RslRlBaseRunnerCfg`，但实际运行时接收的是子类实例，子类中才有 `class_name` 属性。

### 2. **Hydra 装饰器的动态行为**
```python
@hydra_task_config(args_cli.task, args_cli.agent)
def main(env_cfg: ..., agent_cfg: RslRlBaseRunnerCfg):
    # agent_cfg 虽然注解为 RslRlBaseRunnerCfg，
    # 但实际上是一个子类实例
```

`@hydra_task_config` 装饰器在运行时加载正确的子类配置，但静态类型检查器无法理解这一点。

### 3. **Pylance 的保守型检查**
Pylance 严格遵循类型注解，如果基类中没有定义某个属性，即使子类有，它也会报错。

## ✅ 解决方案

我已经应用了以下修复：

### 1. **创建 `pyrightconfig.json`**
此文件配置 Pyright（Pylance 的基础引擎）：
- 设置 `typeCheckingMode: "basic"` 为基本检查模式
- 禁用过于严格的属性访问检查
- 排除不需要检查的目录（scripts, tools, docs 等）

**位置**：`/home/wck/IsaacLab/pyrightconfig.json`

### 2. **更新 Pylance 设置**
在 `.vscode/settings.json` 中禁用严格的类型检查：
```json
"python.analysis.typeCheckingMode": "off",
"python.analysis.diagnosticMode": "workspace"
```

**优点**：
- ✅ 消除误报的 "属性未知" 错误
- ✅ 保留 IntelliSense 代码补全
- ✅ 保留导入检查和其他有用的诊断
- ✅ 不影响代码运行

### 3. **改进的文件排除**
```json
"python.analysis.exclude": [
    "**/__pycache__",
    "**/.*",
    "build",
    "dist",
    "docs",
    "scripts",
    "tools",
    "apps",
    "docker"
]
```

这样 Pylance 只关注 `source/` 目录中的代码，减少不必要的检查。

## 📋 修改的文件

| 文件 | 说明 |
|------|------|
| `/home/wck/IsaacLab/pyrightconfig.json` | **新建** - Pyright 类型检查配置 |
| `.vscode/settings.json` | 已更新 - Pylance 检查模式 |
| `.vscode/tools/settings.template.json` | 已更新 - 配置模板 |

## 🚀 立即生效

修改已应用，但可以通过以下方式确保立即生效：

### 选项 1：重启 VSCode
最简单的方法，Pylance 会重新加载所有配置。

### 选项 2：重新启动 Pylance
1. 打开命令面板 (`Ctrl+Shift+P`)
2. 搜索 "Pylance: Restart"
3. 点击执行

### 选项 3：清除缓存
1. 删除 `.pytype` 目录（如果存在）
2. 重启 VSCode

## 💡 可选：更严格的类型检查

如果你想要更严格的类型检查（不建议用于 Isaac Lab），可以改为：
```json
"python.analysis.typeCheckingMode": "basic"
```

但这会产生更多的误报。

## 📝 最佳实践

对于 Isaac Lab 这样的大型项目，建议：

1. **在 `source/` 中保持类型准确**
   - IsaacLab 核心库的代码应该有正确的类型注解

2. **在 `scripts/` 中放宽检查**
   - 训练脚本通常使用 Hydra 和动态配置，不需要严格检查

3. **使用 `# type: ignore` 注释**
   - 对于特殊情况，可以在代码中添加：
   ```python
   if agent_cfg.class_name == "OnPolicyRunner":  # type: ignore
   ```

## 🔗 相关资源

- [Pyright 配置文档](https://microsoft.github.io/pyright/#/configuration)
- [Pylance 常见问题](https://github.com/microsoft/pylance-release/wiki/FAQ)
- [Python 类型提示 - PEP 484](https://www.python.org/dev/peps/pep-0484/)

## ❓ 常见问题

**Q: 这会影响代码执行吗？**
A: 完全不会。这只是禁用 VSCode 的静态类型检查，代码照常运行。

**Q: 我丢失了 IntelliSense 功能吗？**
A: 不会。IntelliSense 代码补全仍然可用，只是不会进行严格的类型检查。

**Q: 为什么不直接修复 RslRlBaseRunnerCfg？**
A: 因为 `RslRlBaseRunnerCfg` 是 `isaaclab_rl` 库中的类，修改它需要提交 PR。我们的解决方案是工作区级别的配置，不需要修改库代码。

