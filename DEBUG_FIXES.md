# VSCode F5 调试运行问题修复指南

## 📋 问题总结

按 F5 运行 Isaac Lab RL 脚本时的常见问题及解决方案。

## 🔴 发现的主要问题

### 1. **缺少工作目录配置 (`cwd`)**
   - **问题**：脚本需要从工作区根目录运行以找到相对路径
   - **症状**：
     - 无法找到任务配置文件
     - 日志目录创建失败
     - 检查点加载失败
   - **解决**：添加 `"cwd": "${workspaceFolder}"`

### 2. **缺少 Python 路径配置**
   - **问题**：Isaac Lab 的源代码包在 `source/` 目录下
   - **症状**：
     - `ModuleNotFoundError: No module named 'isaaclab_tasks'`
     - `ModuleNotFoundError: No module named 'isaaclab_rl'`
   - **解决**：添加 `"env": {"PYTHONPATH": "${workspaceFolder}/source"}`

### 3. **Debug Mode 限制 (`justMyCode`)**
   - **问题**：默认设置 `justMyCode: true` 会跳过库代码调试
   - **症状**：
     - 无法进入 isaaclab 库代码调试
     - 断点在库代码中不生效
   - **解决**：设置 `"justMyCode": false`

### 4. **不推荐使用的 Python 调试器**
   - **问题**：VSCode 正在弃用旧的 `python` 调试器类型
   - **建议**：未来应改为 `"type": "debugpy"`（但当前版本仍使用 `python`）

## ✅ 已应用的修复

所有以下配置已在以下文件中更新：
- `/home/wck/IsaacLab/.vscode/launch.json`
- `/home/wck/IsaacLab/.vscode/tools/launch.template.json`

### 更新的配置

#### 1. Python: Current File
```json
{
    "name": "Python: Current File",
    "type": "python",
    "request": "launch",
    "program": "${file}",
    "console": "integratedTerminal",
    "cwd": "${workspaceFolder}",
    "justMyCode": false
}
```

#### 2. Python: Train Environment
```json
{
    "name": "Python: Train Environment",
    "type": "python",
    "request": "launch",
    "args": ["--task", "Isaac-Reach-Franka-v0", "--headless"],
    "program": "${workspaceFolder}/scripts/reinforcement_learning/rsl_rl/train.py",
    "console": "integratedTerminal",
    "cwd": "${workspaceFolder}",
    "justMyCode": false,
    "env": {"PYTHONPATH": "${workspaceFolder}/source"}
}
```

#### 3. Python: Play Environment
```json
{
    "name": "Python: Play Environment",
    "type": "python",
    "request": "launch",
    "args": ["--task", "Isaac-Reach-Franka-v0", "--num_envs", "32"],
    "program": "${workspaceFolder}/scripts/reinforcement_learning/rsl_rl/play.py",
    "console": "integratedTerminal",
    "cwd": "${workspaceFolder}",
    "justMyCode": false,
    "env": {"PYTHONPATH": "${workspaceFolder}/source"}
}
```

## 🚀 使用方法

现在你可以：

1. **按 F5 直接运行训练脚本**
   - 选择 "Python: Train Environment" 配置
   - 点击开始或按 F5

2. **按 F5 直接运行推理脚本**
   - 选择 "Python: Play Environment" 配置
   - 点击开始或按 F5

3. **按 F5 运行当前文件**
   - 任何 Python 文件都会以正确的工作目录和路径运行

## ⚠️ 注意事项

### Isaac Sim 应用启动
虽然现在可以直接通过 VSCode 调试，但 Isaac Sim 应用的启动由 `AppLauncher` 处理。若需要使用 Isaac Sim 的完整功能（如渲染），确保：

1. Isaac Sim 已安装并可访问
2. 环境变量 `ISAAC_PATH` 已正确设置（通常由 `isaaclab.sh` 设置）
3. 首次运行时可能需要接受 Isaac Sim EULA

### 推荐使用 isaaclab.sh 运行复杂工作流
对于某些高级功能（如分布式训练、特殊渲染模式），仍推荐使用命令行：
```bash
./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task Isaac-Reach-Franka-v0 --headless
```

## 📝 修改的文件清单

- ✅ `/home/wck/IsaacLab/.vscode/launch.json` - 运行配置文件
- ✅ `/home/wck/IsaacLab/.vscode/tools/launch.template.json` - 配置模板

## 🔧 自定义建议

如需针对特定任务或参数进行调试，可以在 `launch.json` 中添加新配置：

```json
{
    "name": "Python: Custom Training (Isaac-Ant-v0)",
    "type": "python",
    "request": "launch",
    "args": ["--task", "Isaac-Ant-v0", "--num_envs", "512", "--max_iterations", "1000"],
    "program": "${workspaceFolder}/scripts/reinforcement_learning/rsl_rl/train.py",
    "console": "integratedTerminal",
    "cwd": "${workspaceFolder}",
    "justMyCode": false,
    "env": {"PYTHONPATH": "${workspaceFolder}/source"}
}
```

## 💡 故障排除

| 症状 | 可能原因 | 解决方案 |
|------|--------|--------|
| `ModuleNotFoundError: isaaclab_*` | PYTHONPATH 未配置 | 检查 `env` 变量 |
| 无法找到任务/检查点 | 工作目录错误 | 检查 `cwd` 设置 |
| 无法在库代码中设置断点 | `justMyCode: true` | 改为 `false` |
| Isaac Sim 未启动 | 应用启动器问题 | 检查 `ISAAC_PATH` 环境变量 |

