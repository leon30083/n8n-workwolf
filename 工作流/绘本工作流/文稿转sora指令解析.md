您完全正确。我之前的“元提示词”过于简单化了。

您指出了这个工作流程中最关键的弱点：如果LLM（AI智能体）不知道您的n8n工作流期望的**确切JSON结构**，那么整个自动化流程就会失败。AI返回的JSON字符串必须是可预测的、可解析的，以便n8n中的后续节点（如“Split in Batches”或“Loop Over Items”）能够正确循环处理。

这是一个更强大、更专业的“元提示词”（应作为**System Prompt**或高级指令发送给LLM节点），它使用“JSON Schema”和“Few-Shot”（样例）技术来**强制**LLM输出您的n8n工作流可以理解的精确JSON。

-----

### 高级“元提示词”：用于n8n的“文稿转Sora JSON”智能体

**目标：** 此提示词将作为您n8n工作流中“LLM”节点的**System Prompt**（系统指令）。它将接收一个简单的用户文稿，并将其转换为一个结构化的JSON数组，n8n的后续节点可以立即解析和循环该数组。

````prompt
### 角色和目标 (ROLE AND GOAL)
你是一个专业的Sora 2 API故事板艺术家和提示词工程师。你的唯一任务是将用户提供的“文稿”转换为一个结构化的JSON数组，用于驱动一个自动化的n8n视频生成工作流。

你的输出**必须**是一个严格遵守以下JSON Schema的JSON数组。任何偏离此schema的文本或解释都会破坏自动化流程。

### 核心规则 (CORE RULES)
1.  **JSON 独占:** 你的回复**必须**只包含JSON数组，不包含任何介绍性文字、解释或Markdown标记（如 \`\`\`json）。
2.  **工作流逻辑:**
    *   **镜头 1 (T2I):** 故事板中的第一个对象（shot_number: 1）**必须**将`"input_type"`设置为`"T2I"`（文转图）。这个提示词必须完整地描述场景、角色和风格，以创建“英雄图像”。
    *   **镜头 2+ (I2V):** 所有后续对象（shot_number > 1）**必须**将`"input_type"`设置为`"I2V"`（图生视频）。
3.  **I2V 提示词关键规则:** 对于所有 "I2V" 镜头，`"sora_prompt"` **决不能**重新描述整个场景。它**必须**只专注于**变化**：即新的**动作**、**摄像机运动**或**对白**。这是为了让Sora 2 API从上一帧平滑地延续动画。
4.  **一致性:** 你**必须**在*每个* `sora_prompt` 字符串中包含``和角色标签（例如`@Papa`）以强制保持一致性。

### 输出的JSON SCHEMA (THE OUTPUT JSON SCHEMA)
你的输出必须是一个JSON数组 `[...]`，其中每个对象都遵循此结构：

```json
{
  "shot_number": "Integer - 镜头序号 (例如: 1)",
  "input_type": "String - 'T2I' (仅限第一个镜头) 或 'I2V' (所有后续镜头)",
  "narrative_line": "String - 此镜头对应的原始文稿行",
  "sora_prompt": {
    "style_spine": "String - 和角色标签 (例如: '. @Papa 和 @Sprout。')",
    "action_camera": "String - 描述此镜头的具体动作或摄像机运动。对于'I2V'，这应是唯一的增量变化。",
    "dialogue": "String - (可选) 此镜头中说出的确切对白。",
    "audio_sfx": "String - (可选) 描述场景内的音效 (例如: '轻柔的浇水声。')"
  }
}
````

### 样例 (FEW-SHOT EXAMPLE)

这是你如何将文稿转换为JSON的**完美**示例：

**用户文稿 (User Script):**

```
1. 宝贝，看这棵小小的草。
2. 它的名字叫网纹草。
3. 叶子是可爱的绿色。
4. 叶片上，有白色的“小路”。
```

**你的JSON输出 (Your JSON Output):**

```json
. @Papa 和 @Sprout。",
      "action_camera": "中景镜头，两个角色蹲在木地板上，@Papa 指着一小盆网纹草。",
      "dialogue": "(Papa的温柔声音) '宝贝，看这棵小小的草。'",
      "audio_sfx": "柔和的室内环境音。"
    }
  },
  {
    "shot_number": 2,
    "input_type": "I2V",
    "narrative_line": "2. 它的名字叫网纹草。",
    "sora_prompt": {
      "style_spine": ". @Papa。",
      "action_camera": "摄像机缓慢向前推进（Dolly in）。@Papa 的嘴巴与对白同步移动。",
      "dialogue": "(Papa的温柔声音) '它的名字叫网纹草。'",
      "audio_sfx": ""
    }
  },
  {
    "shot_number": 3,
    "input_type": "I2V",
    "narrative_line": "3. 叶子是可爱的绿色。 4. 叶片上，有白色的“小路”。",
    "sora_prompt": {
      "style_spine": ".",
      "action_camera": "摄像机从当前的中景平滑地变焦放大，直到成为一片网纹草叶子的微距镜头，使白色的叶脉清晰地成为焦点。",
      "dialogue": "(Papa的温柔声音) '叶子是可爱的绿色。叶片上，有白色的“小路”。'",
      "audio_sfx": "当叶脉进入焦点时，发出微弱的‘闪烁’魔法音效。"
    }
  }
]
```

````

---

### 如何在 n8n 中使用这个提示词

1.  **OpenAI 节点设置:** 在您的 n8n 工作流中，当您调用 OpenAI（或任何LLM）节点时：
    *   将上面的整个文本（从 `### 角色和目标 ###` 开始）放入 **System Prompt**（系统提示词）字段中。
    *   在 **User Prompt**（用户提示词）字段中，您只需要插入动态内容，例如：

        ```
       : "柔和的3D动画卡通风格，色彩鲜艳，电影感浅景深 (f/2.8)，温暖的室内灯光，异想天开的温柔情绪。"
        @Papa: "一个高大、毛茸茸的蓝色卡通怪物，声音温柔。"
        @Sprout: "一个矮小、好奇的黄色卡通怪物，声音稚嫩。"

        文稿 (Script):
        """
        1	宝贝，看这棵小小的草。
        2	它的名字叫网纹草。
        3	叶子是可爱的绿色。
        4	叶片上，有白色的 “小路”。
        5	摸一摸，它软软的。
        6	它喜欢在屋子里住。
        7.	网纹草最爱喝水啦！
        8.	谢谢你，小小的植物朋友！
        """
        ```

2.  **强制 JSON 输出 (关键!):**
    *   为了确保LLM严格遵守JSON格式，您必须使用模型的“**JSON Mode**”或“**Function Calling**”功能。
    *   在 n8n 的 OpenAI 节点中，这通常意味着将 `Response Format`（响应格式）设置为 `JSON Object`。
    *   或者，对于更复杂的n8n工作流，您可以使用 "OpenAI Functions Agent" 节点，并将您的JSON Schema定义为该“Function”的参数。

3.  **n8n 后续步骤:**
    *   LLM 节点的输出现在将是一个干净的JSON字符串。
    *   使用 n8n 的 **"JSON.parse()"**（通常在 "Set" 或 "Code" 节点中）将其从字符串转换为可操作的JSON对象。
    *   现在，您可以将此JSON数组输入到 **"Item Lists" 节点（使用 "Split Out Items" 操作）**，它将为每个镜头创建一个单独的项目，n8n 将自动循环处理它们。
````