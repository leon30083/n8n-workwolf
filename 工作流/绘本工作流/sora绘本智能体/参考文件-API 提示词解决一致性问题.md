

# **Sora 2 API 一致性问题深度解析：提示词架构、API 机制与高级工作流**

## **I. 引言：解构 Sora 2 API 的一致性挑战**

在评估 Sora 2 这一先进的媒体生成模型时，“一致性” (Consistency) 是衡量其从技术演示转变为专业生产工具的核心标准。用户的查询聚焦于如何通过 API 解决这一问题，但这并非一个单一的挑战。深入分析表明，“一致性”涵盖了至少三个独立但相互关联的技术层面：

1. **物理与时间一致性 (Physical & Temporal Consistency)**：这是指模型在单个视频帧序列中维持对象恒常性、空间感知和现实物理规律的能力。研究表明，Sora 2 在这方面表现出色，能够确保“对象不会随意改变大小，阴影表现正确，水流自然” 1。这被认为是模型基础架构的核心优势，使其区别于早期的视频生成模型。  
2. **风格一致性 (Stylistic Consistency)**：这是指在多个镜头（甚至是跨多个 API 调用生成的镜头）中，保持统一的电影美学、色彩配置、光照特性、相机动态和整体氛围的能力 2。这种一致性主要通过精确的、技术性的语言提示词 (Prompt Engineering) 来控制 3。  
3. **主题与角色一致性 (Subject & Character Consistency)**：这是实践中最严峻的挑战。它要求模型在不同的动作、场景和镜头角度下，保持一个特定主体——尤其是人类角色的面部特征、体型、服装和身份——的恒定 4。研究表明，这恰恰是当前 API 工作流中最薄弱、限制最多的一环 5。

本报告的**核心论点**是：在 Sora 2 API 中实现一致性并非依赖单一命令或参数，而是一个**混合架构方法 (Hybrid Architectural Approach)** 的结果。此方法是分层的，它战略性地结合了：

1. **固定的 API 参数** (如分辨率和模型选择，作为“硬性”约束) 3。  
2. **视觉锚点** (即 input\_reference 参数，用于锁定非人类主体的视觉特性) 3。  
3. **语言脚手架** (即结构化的提示词，用于定义“风格化脊柱”和多镜头故事板) 6。  
4. **外部后期制作工作流** (作为规避 API 固有局限性的必要补充手段) 8。

对研究材料的分析揭示了一个关键的非对称性：Sora 2 模型在技术上*设计*用于实现物理一致性 1，并能通过提示词*响应*风格一致性 3。然而，对于需求最高的一致性形式——**逼真的人类角色一致性**——API 却通过其最合乎逻辑的机制（图像输入）施加了*政策性限制* 5。

这种矛盾是理解 Sora 2 API 限制的核心。1 的文档赞扬了模型“在多个镜头间保持事物一致”的能力，特别是“角色的外观和服装”。3 和 3 进一步解释了实现这一目标的机制：使用 input\_reference 图像输入来“锁定”诸如“角色设计”之类的元素。然而，5 和 5 的开发者社区报告和文档片段却给出了直接的矛盾信息：“目前拒绝包含人类面部的输入图像 (Input images with faces of humans are currently rejected)”。

因此，“一致性问题”并非模型的*技术缺陷*，而是 API 交付层面的*政策与安全约束*。本报告将深入剖析 API *允许*的机制，以及它*有意阻止*的机制，并为开发者提供在这些约束下实现最大化一致性的战略指南和提示词范例。

## **II. 基础 API 控制：硬性生产约束**

在构建任何提示词架构之前，开发者必须首先通过 API 调用中的特定参数来设置“画布”。这些参数是视频生成的“硬性约束”或“生产指令”，它们无法通过自然语言提示词（例如，在提示词中说“让视频更长”）来覆盖 3。

### **API 端点与异步特性**

所有视频生成任务都通过向 POST /videos 端点发出请求来启动 9。Sora 2 的视频生成是一个**异步 (asynchronous)** 过程 9。这意味着 POST 请求不会立即返回视频文件，而是返回一个任务 ID。开发者必须随后轮询 Get video status 端点以监控渲染作业的进度，并在作业完成后通过 Download video 端点获取 MP4 文件 9。

### **关键 API 参数**

1. **model** 3  
   * sora-2：此模型专为“速度和灵活性”而设计。它非常适用于“探索阶段”，例如当开发者需要快速迭代、测试不同风格或概念，而不需要完美的保真度时。它能快速生成质量良好的结果，适用于社交媒体内容或原型设计 9。  
   * sora-2-pro：此模型产生“更高质量”的“生产级”输出。它的渲染时间更长，运行成本更高，但能生成“更精致、更稳定”的结果 9。它是高分辨率电影镜头和营销素材的最佳选择。  
2. **size** 3  
   * 这是一个定义分辨率和宽高比的字符串，格式为 {width}x{height}，例如 "1280x720" (16:9) 或 "720x1280" (9:16) 3。  
   * 支持的分辨率取决于所选的 model。sora-2-pro 支持比 sora-2 更多、更高清的选项（例如 1024x1792） 3。  
3. **seconds** 3  
   * 定义剪辑时长的参数，通常支持的值为 "4", "8", "12" 等 3。  
   * **关键限制**：这是一个必须在 API 调用中明确设置的固定参数。提示词中的“制作一个 30 秒的视频”之类的描述将被忽略。Sora 2（Pro 版）的最大生成时长（例如 90 秒 14）是硬性上限。任何需要超过此最大时长的叙事一致性，都*必须*通过生成多个剪辑并在后期制作中将它们拼接在一起来实现 6。

### **战略性工作流：两阶段迭代**

model 参数的设计本身就为实现一致性提供了战略指导。专业的工作流应该是一个**两阶段过程**：

1. 第一阶段：低保真探索 (Low-res Exploration) 7  
   使用 sora-2 模型进行快速、低成本的迭代。此阶段的目标不是实现完美的视觉一致性，而是验证概念和叙事一致性。开发者应在此阶段测试：“我的多镜头提示词结构是否被正确理解？”“模型能否跟踪我的基本动作指令？”  
2. 第二阶段：高保真精炼 (High-fidelity Refinement)  
   一旦提示词架构（见第四、五、六节）被 sora-2 验证为有效，开发者再切换到 sora-2-pro 模型。此阶段使用相同的、经过验证的提示词结构来生成最终的、具有生产质量和高稳定性（即物理和风格一致性）的剪辑。

跳过第一阶段而直接使用 sora-2-pro 进行调试，是一种在财务和时间上都极其低效的做法。API 的分层设计明确鼓励通过迭代来实现一致性 3，而模型层级（sora-2 vs sora-2-pro）正是为这种迭代工作流而构建的。

## **III. input\_reference 锚点：图像到视频的 API 核心一致性机制**

Sora 2 API 提供的最强大的*原生*一致性工具是 input\_reference 参数。该参数允许开发者提供一个参考图像，作为视频生成的视觉起点。

### **功能与优势**

input\_reference 的核心功能是作为\*\*“第一帧的锚点” (anchor for the first frame)\*\* 3。Sora 2 模型将使用此图像作为起点，然后根据文本提示词来定义*接下来发生的事情* 3。

这种方法的主要优势在于它能“锁定” (locks in) 关键的视觉元素，提供比纯文本提示词更强的控制力 3。它可以锚定的元素包括：

* **美学风格**：例如，锁定一种特定的插画风格或赛博朋克美学。  
* **场景布局 (Set Dressing)**：锁定房间的家具摆放、光照氛围或背景环境 3。  
* **非人类角色设计**：锁定特定角色的外观，例如吉祥物、动物或生物 3。  
* **服装与道具**：确保视频中的角色从一开始就穿着特定的服装。

**官方示例** 3 清楚地展示了这一点：

1. 输入：一张（由 AI 生成的）女性图像。  
   提示词：“She turns around and smiles, then slowly walks out of the frame.” (她转过身来微笑，然后慢慢走出画面。)  
2. 输入：一张（由 AI 生成的）紫色怪物图像。  
   提示词：“The fridge door opens. A cute, chubby purple monster comes out of it.” (冰箱门打开了。一个可爱的、胖乎乎的紫色怪物从里面走了出来。)

### **技术实现要求**

在 API 调用中实现 input\_reference 时，必须满足严格的技术规范：

* **参数名称**：input\_reference 3。  
* **输入格式**：输入*必须*是一个可通过 HTTPS 访问的 URL 13。API 不接受 Base64 编码的图像 13。  
* **文件类型**：支持的格式为 image/jpeg, image/png, 和 image/webp 3。  
* **关键失败点**：参考图像的*分辨率*（尺寸）*必须*与 API 调用中 size 参数定义的*目标视频分辨率*（例如 "1280x720"）**精确匹配** 3。任何不匹配都将导致 API 请求失败。

### **关键限制：人类面部的“断层”**

尽管 input\_reference 在理论上是实现角色一致性的完美工具，但它在实践中遇到了一个巨大的障碍：OpenAI 的安全与审核策略。

**开发者社区和文档明确证实：“目前拒绝包含（逼真）人类面部的输入图像”** 5。

这一限制制造了一个巨大的“断层”：API 中用于确保“角色设计” 3 的核心功能，却被*禁用*于最需要它的用例——逼真的人类角色。

下表（表 1）总结了 input\_reference 的应用范式及其限制，为开发者提供了清晰的决策指南。

**表 1：input\_reference 应用范式与 API 限制**

| 应用场景 | input\_reference 描述 | prompt 示例 | 预期一致性结果 | 关键限制 / 失败点 |
| :---- | :---- | :---- | :---- | :---- |
| **美学锁定** | 一张宫崎骏风格的风景画图像。 | “一个女孩骑着自行车穿过田野。” | 视频将以参考图像的“吉卜力”风格进行渲染。 | 较低。只要图像风格清晰即可。 |
| **场景锁定** | 一张AI生成的、光线昏暗的赛博朋克酒吧内部图像。 | “一个机器人酒保擦拭着吧台。” | 视频的第一帧将与参考图像的场景布局和光照高度匹配。 | 图像必须与 size 参数精确匹配 3。 |
| **非人类角色** | 3 中的紫色怪物图像。 | “冰箱门打开了。一个可爱的、胖乎乎的紫色怪物从里面走了出来。”3 | 视频中的怪物在外观、颜色和体型上与参考图像高度一致。 | 图像必须与 size 参数精确匹配 3。 |
| **逼真人类角色** | 一张（AI生成的或真实照片）女性演员的面部特写。 | “她转过身来微笑。” | **N/A (不适用)** | **API 拒绝**。请求将因内容审核策略而失败 5。 |

### **战略含义：二元工作流决策**

input\_reference 的这一核心限制迫使开发者进入一个基于其主题的**二元工作流决策 (Binary Workflow Decision)**：

* **如果你的主题是*非人类*的**（例如产品、动物、车辆、动画角色、奇幻生物）：input\_reference 是实现高度视觉一致性的“黄金路径”。  
* **如果你的主题是*逼真的人类***：这条路径被关闭了。开发者*必须*放弃使用 input\_reference，转而完全依赖后续章节中详述的**语言脚手架**（第四、五、六节）和**外部后期制作**（第七节）来实现一致性。

不理解这一根本性约束，将导致开发者在尝试实现人类角色一致性时，不断遭遇 API 拒绝和挫败感。

## **IV. 架构化提示词 I：掌握电影风格（“风格化脊柱”）**

当 input\_reference 机制不可用或不足以控制场景时（尤其是在跨多个镜头保持一致性时），**提示词架构 (Prompt Architecture)** 就成为实现一致性的主要手段。

核心理念是，开发者不能使用模糊的创意词汇，而必须像“向一位从未见过你的故事板的电影摄影师做简报”那样，提供技术性的、精确的指令 3。如果开发者遗漏了细节，模型将会“即兴创作” (improvise)，导致结果不可预测 3。

### **官方提示词解剖结构**

OpenAI 的官方指南推荐使用一种结构化的方法来组织提示词，以最大化控制力 3：

1. **\[散文描述\]**：对场景、主题和核心氛围的简洁描述。  
2. **Cinematography:** (摄影)：  
   * Camera shot: \[framing and angle\] (镜头：\[取景和角度\]，例如 wide establishing shot, eye level 3)  
   * Depth of field: \[shallow/deep\] (景深：\[浅/深\]16)  
   * Lens/style cues: \[e.g. anamorphic lens, handheld\] (镜头/风格：\[例如 变形镜头, 手持\]16)  
3. **Mood:** (氛围)：\[整体基调，例如 cinematic and tense (电影感和紧张感) 3\]  
4. **Actions:** (动作)：  
   * \- \[Action 1: a clear, specific beat\] (动作1：一个清晰、具体的节拍) 3  
   * \- \[Action 2: another distinct beat\] (动作2：另一个不同的节拍) 3  
5. **Dialogue:** (对话)：\[如果需要，在此处添加简短台词\]3

### **弱提示词 vs. 强提示词**

实现风格一致性的关键在于从“弱”提示词转向“强”提示词。弱提示词是主观的和模糊的；强提示词是客观的和技术的 3。

* **弱**：“A beautiful street at night” (一条美丽的夜间街道)  
* **强**：“Wet asphalt, zebra crosswalk, neon signs reflecting in puddles” (潮湿的沥青路面，斑马线，霓虹灯标志在水坑中反射) 3  
* **弱**：“Cinematic look” (电影感)  
* **强**：“Anamorphic 2.0x lens, shallow DOF, volumetric light” (2.0x 变形镜头，浅景深，体积光) 3

下表（表 2）提供了一个实用的转换指南，展示了如何将常见的模糊创意需求转换为 Sora 2 能够一致执行的技术指令。

**表 2：弱提示词 vs. 强提示词转换：实现风格一致性**

| 创意目标 (Creative Goal) | 弱提示词 (Weak Prompt \- 模糊且不一致) | 强提示词 (Strong Prompt \- 技术性且一致) |
| :---- | :---- | :---- |
| “我想要电影感。” | Cinematic look, high quality, 4K | Shot on 35mm film stock, Anamorphic 2.0x lens, shallow DOF, teal and amber color grade. 3 |
| “我想要一个美丽的夜景。” | A beautiful street at night. | Wide establishing shot, wet asphalt zebra crosswalk, neon signs reflecting in puddles, volumetric light from streetlamps. 3 |
| “我想要聚焦在角色上。” | Close up on the character's face. | Medium close-up shot, eye level, 85mm lens, f/2 for shallow DOF, soft key light from camera right. 17 |
| “我想要温暖、怀旧的氛围。” | Warm and nostalgic mood. | Golden hour lighting, soft focus, visible dust particles (atmos), Palette anchors: amber, cream, walnut brown. 3 |

### **风格化词典：锁定美学的技术指令**

为了帮助开发者构建强大的提示词，以下是从研究材料中提取的、用于锁定特定美学风格的关键技术术语。

#### **1\. 相机与镜头词典 (Camera & Lens Lexicon)**

* **85mm lens**：常用于人像，产生美丽的背景压缩和浅景深 (shallow DOF)，使主体突出 20。  
* **35mm lens**：经典的电影镜头，提供适度的广角和自然的景深，适合纪实风格 20。  
* **200mm telephoto**：长焦镜头，极度压缩空间，常用于野生动物或体育摄影，需要平稳的摇摄 (panning shot) 20。  
* **Anamorphic 2.0x lens**：创建超宽屏电影外观、特有的椭圆形焦外 (bokeh) 和水平镜头光晕 (lens flare) 的关键指令 3。  
* **Shallow DOF (Depth of Field)**：浅景深。使主体清晰，同时模糊背景，是“电影感”的核心要素 3。  
* **Deep focus**：深景深。保持前景和背景都清晰，常用于广阔的风景镜头 16。  
* **Framing (取景)**：wide establishing shot, eye level (广角全景镜头, 人眼水平) 3, medium close-up shot (中景特写) 17, aerial wide shot (航拍广角) 17。

#### **2\. 光照与调色板词典 (Lighting & Color Lexicon)**

* **Volumetric light / God rays**：体积光/“上帝之光”。指可见的光束（例如穿过窗户或树林的灰尘），能立即营造戏剧性和氛围感 3。  
* **Backlit rim highlights**：逆光边缘高光。从主体后方打光，在头发或肩膀上形成一道明亮的轮廓光，使主体与背景分离 16。  
* **Soft shadow penumbra**：柔和的阴影半影区。描述阴影边缘的柔和度，暗示光源是扩散的（例如阴天或柔光箱），而非刺眼的直射光 7。  
* **Golden hour**：黄金时段。日出后或日落前的时段，光线温暖、柔和且呈水平方向 20。  
* **Palette Anchors (调色板锚点)**：明确定义3-5种主色调，以强制实现色彩一致性。  
  * Palette anchors: amber, cream, walnut brown (调色板锚点：琥珀色、奶油色、胡桃棕色) 3。  
  * aesthetic with cool blue and warm amber tones (具有冷蓝色和暖琥珀色调的美学) 18。  
  * clean morning sunlight with amber lift... slight teal cast in shadows (干净的晨光带有琥珀色调……阴影中带有轻微的青色) 16。

### **战略含义：“风格化脊柱”**

7 中的专业工作流提出了一个关键概念：“**风格化脊柱” (Style Spine)**。

当开发者需要制作一个由*多个*独立 API 调用（即多个剪辑）组成的较长序列时，他们不能期望模型“记住”前一个剪辑的风格。

**解决方案**：开发者必须在“前期制作” (pre-production) 中，定义一个包含所有核心美学指令（镜头、光照、调色板、氛围）的可重用文本块。这个文本块就是“风格化脊柱”。

例如，一个开发者可以定义一个字符串变量：  
STYLE\_SPINE \= "Cinematography: 85mm lens, shallow DOF, handheld camera shake. Mood: cinematic and tense. Lighting: cool blue and warm amber tones, volumetric light. Grade: teal and amber palette."  
然后，在*每个*单独的 API 调用中，将这个 STYLE\_SPINE 字符串\*\*以编程方式（Programmatically）\*\*附加到该镜头的特定动作描述之前。

**一致性是通过*程序化的冗余 (programmatic redundancy)* 来强制实现的，而不是通过模型的记忆。**

## **V. 架构化提示词 II：驾驭叙事、物理与运动**

在建立了“风格化脊柱”之后，下一个挑战是确保叙事流 (Narrative Flow) 和物理行为 (Physical Behavior) 在镜头内部和镜头之间保持一致。

### **1\. 多镜头故事板 (Multi-Shot Storyboarding)**

Sora 2 API 允许在单个提示词中描述一个包含多个镜头的短序列，这对于创建具有叙事弧线的剪辑至关重要 25。结构化方法是使用明确的镜头分隔符 6：

示例结构 21：  
Shot 1: wide establishing shot of futuristic city skyline at dusk, drones passing overhead.  
Shot 2: close-up of a neon-lit cafe window, raindrops sliding down glass.  
Shot 3: interior, young woman adjusts camera focus, reflections of city lights in her lens.  
这种结构将自然语言转换  
为模型可以执行的“故事板” 25。

### **2\. 维持连续性（镜头之间）**

当使用*多个* API 调用来创建更长的序列时，最大的挑战是连续性，尤其是角色的连续性。如第七节所述，人类面部一致性是一个瓶颈，但服装和一般外观的连续性*可以*通过提示词来强制实现。

关键在于在后续的提示词中**明确引用前一个镜头的元素**。

示例（基于 6）：

* API Call 1 (Shot 1):  
  \+ "Shot 1: Medium shot of a detective in a trench coat standing in the rain outside a noir-style apartment building. Neon signs reflect in puddles. He looks up at a lit window..."  
* API Call 2 (Shot 2):  
  \+ "Shot 2: \*\*Same detective from previous scene, now inside the building\*\* climbing dimly lit stairs. \*\*Maintaining same trench coat and appearance.\*\* Ominous ambient sound. Camera follows from behind."

6 的这个例子是实现叙事一致性的关键。"Maintaining same trench coat" (保持相同的风衣) 这一短语至关重要。它表明，API 在两次调用之间**没有记忆 (no memory)**。

如果不明确指示“保持相同”，模型很可能会“即兴创作” 3，并随意改变角色的服装。因此，开发者必须在每个提示词中手动扮演“**连续性指导 (Continuity Supervisor)**”的角色。一个专业的 Sora 2 应用程序后端将需要一个“提示词构建器”，该构建器不仅能附加“风格化脊柱”，还能动态插入这些“连续性线索”。

下表（表 3）展示了如何结合使用这些元素来构建一个连贯的多镜头叙事。

**表 3：多镜头叙事提示词结构（故事板技术）**

| 镜头编号 (Shot \#) | 提示词组件 (Prompt Components) |
| :---- | :---- |
| **Shot 1** | \`\`+Shot 1: 广角镜头，侦探（穿着风衣）站在雨中，抬头看公寓窗户... |
| **Shot 2** | \`\`+Shot 2: 镜头切换到公寓楼梯间。来自前一场景的同一侦探（保持相同的风衣）正在上楼。 6 |
| **Shot 3** | \`\`+Shot 3: 侦探的特写镜头，他到达门口，从风衣口袋里掏出钥匙。 |

### **3\. 编码物理真实感 (Encoding Physical Realism)**

Sora 2 的一大优势在于其改进的物理模拟能力 1。为了确保这种物理一致性始终被激活，开发者应“明确编码材料和力” (encode materials and forces explicitly) 7。

* **模糊**：“A person in the rain.” (雨中的人。)  
* **精确**：“wet nylon jacket (潮湿的尼龙夹克), 8-10 mph crosswind from camera left (从相机左侧吹来 8-10 英里/小时的侧风), footfalls splashing in shallow puddles (脚步溅起浅水坑中的水花)” 7。

其他增强物理一致性的强提示词示例：

* wet asphalt (潮湿的沥青) 3  
* water shear and droplet spray behave physically (水的剪切和液滴喷溅在物理上表现正常) 20  
* high shutter to freeze droplets (高快门速度以冻结水滴) 20

### **4\. 使用 Remix 进行迭代**

API 包含一个“Remix”功能 3，可能通过 remix\_id 参数实现 9。这是微调一致性的关键工具。开发者可以生成一个基础版本，如果某个方面（例如光照）不理想，他们可以提交一个“remix”请求来进行定向修改，同时保持其他元素不变。

**迭代工作流示例** 21：

* **Original (原始版本)**: "Slow dolly-in on subject" (缓慢推镜向主体)  
* **Remix (迭代版本)**: "Same shot, switch to 85mm lens" (相同镜头，切换到 85mm 镜头)  
* **Original**: "Soft morning light" (柔和的晨光)  
* **Remix**: "Same lighting setup, change to golden hour" (相同光照设置，改为黄金时段)

这种“一次只改一件事” (One Change at a Time) 21 的方法是实现精确创意控制的系统性途径。

## **VI. 架构化提示词 III：集成视听音景**

Sora 2 的一个革命性特点是它能够*同时*生成与视频同步的音频 28。这包括口型同步的对话、环境音效和背景音乐。实现音频一致性与视觉一致性同样重要，并且遵循相似的原则：**精确性和分层 (Precision and Layering)**。

### **1\. 对话与口型同步 (Dialogue & Lip-Sync)**

为了生成带有准确口型同步的对话，应在提示词的专用 Dialogue: 块中提供确切的台词 3。

示例 3：  
In a 90s documentary-style interview, an old Swedish man sits in a study and says, "I still remember when I was young."  
(在一个 90 年代纪录片风格的采访中，一位年长的瑞典男子坐在书房里说：“我仍然记得我年轻的时候。”)  
为了获得更好的一致性，还应指定语气和口音 (tone and accent) 30。

### **2\. 场景内声音 (Diegetic Sound)**

这是指源自屏幕上可见动作的声音。明确描述这些声音可以极大地增强真实感和物理一致性 12。

* **弱**：“Outdoor sounds” (户外声音) 31。  
* **强**：“Layer multiple audio elements—footsteps on gravel (碎石上的脚步声), distant traffic (远处交通声), wind through trees (风穿过树林的声音), ambient bird calls (环境鸟叫声)” 31。

其他强有力的场景内声音示例：

* steam hissing (蒸汽嘶嘶声) 12  
* milk steaming, cups clinking (牛奶蒸汽声，杯子碰撞声) 28  
* sound of ceramic breaking (陶瓷破碎的声音) 12  
* distant intersection signal beeping every 3 seconds (远处十字路口信号灯每 3 秒蜂鸣一次) 31

### **3\. 场景外声音 (Non-Diegetic Sound)**

这是指非来自场景本身的背景音乐 (BGM) 或音效。

* soft jazz in the background (背景中的轻柔爵士乐) 28  
* retro synth jingle (复古合成器叮当声) 34  
* melancholy piano entering at 0:04 (忧郁的钢琴声在 0:04 进入) 31  
* Heartbeat rhythm (60 BPM) underlies tense scene (心跳节奏 (60 BPM) 衬托着紧张的场景) 31

下表（表 4）展示了如何组合这三个层次来构建一个丰富的、一致的音景。

**表 4：分层音频提示词示例**

| 场景 | 提示词（展示分层音频描述） |
| :---- | :---- |
| **咖啡店场景** | 中景镜头，咖啡师制作咖啡。Sound: milk steaming, cups clinking, espresso machine hissing. (声音：牛奶蒸汽声, 杯子碰撞声, 浓缩咖啡机嘶嘶声) 28Background sound: soft jazz in the background, quiet coffee shop hum. (背景音：背景中的轻柔爵士乐, 咖啡店安静的嗡嗡声) 28 |
| **80年代广告** | 复古 80 年代风格的客厅，演员们夸张地微笑。Dialogue: Cheerful announcer voice says, “Introducing the all-new ToastKing 3000\!” (对话：欢快的播音员声音说：“隆重推出全新的 ToastKing 3000！”) 34Sound: retro synth jingle, camera crash-zooms sound effect. (声音：复古合成器叮当声, 相机快速变焦音效) 34 |
| **紧张的惊悚片** | 角色在黑暗的森林中行走。Sound: footsteps crunching on gravel, wind through trees, distant owl hoot. (声音：碎石上的脚步声, 风穿过树林的声音, 远处的猫头鹰叫声) 31Background sound: Heartbeat rhythm (60 BPM) underlies tense scene, music ducks during speech. (背景音：心跳节奏 (60 BPM) 衬托着紧张的场景, 音乐在有对话时减弱) 31 |

### **作为物理一致性增强器的音频**

Sora 2 同时生成音频和视频的特性 28 带来了一个非凡的、非显而易见的后果：**提示词中的场景内声音 (Diegetic Sound) 可以作为物理一致性的增强器。**

这个逻辑链如下：

1. 模型必须生成一个与视觉效果*同步*的音景。  
2. 如果提示词要求发出“陶瓷破碎的声音” 12 或“碎石上的脚步声” 31，模型不仅要生成这种*声音*。  
3. 模型还*必须*在视觉上渲染一个*能够*产生这种声音的物理事件（一个破碎的陶瓷物体或一只踩在碎石上的脚）。  
4. 因此，通过在提示词中详细描述场景内的声音，开发者可以利用一种“后门”机制来*强制*模型渲染和模拟相应的物理交互，从而锚定视觉动作并增强整体的物理一致性 1。

## **VII. 角色一致性的瓶颈：API 限制与战略性规避**

本报告至此已经阐述了实现*风格*、*物理*和*叙事*一致性的 API 和提示词技术。然而，开发者最迫切的需求——在多个镜头中保持**逼真的人类角色一致性**——仍然是当前 API 最大的瓶颈。

### **问题 1：缺失的“Cameo”功能**

Sora 2 的消费者应用程序 (App) 包含一个名为“Cameo”的功能，这是 OpenAI 官方提供的解决方案，允许用户录制自己的视频和音频，创建一个可重用的“数字角色”，并将其置于任何场景中 35。这是实现角色一致性的理想工具。

然而，**开发者社区和论坛（2025 年 10 月）的报告一致证实，"Cameo" 功能目前*并未*在 Sora 2 API 中提供** 5。这意味着通过 API，开发者在每次调用时都必须从零开始创建角色。

### **问题 2：被封锁的 input\_reference**

如第三节所述，合乎逻辑的 API 规避方法——使用 input\_reference 参数并提供一张所需角色的面部照片——被 OpenAI 的内容审核系统明确阻止。API 会拒绝包含逼真人类面部的参考图像 5。

这一政策（旨在防止对真实人物进行 deepfake）使得 API 原生的角色一致性变得极其困难。

### **规避策略与工作流**

面对这些限制，开发者社区已经探索出四种主要的规避策略，它们的保真度和稳定性各不相同。

#### **1\. 规避策略 1 (API 原生, 低保真)：超详细的文本描述**

这是目前唯一被“官方”支持的 API 内部方法。它依赖于极度详细和冗长的文本描述，试图在语言上“锁定”角色的每一个特征，并在*每一个*镜头的提示词中重复这些描述 2。

* **示例**：“一个 30 多岁的男人，方下巴，高颧骨，深陷的棕色眼睛，左眉上有一道小疤痕，穿着一件褪色的蓝色牛仔夹克和黑色 T 恤。”  
* **缺点**：这种方法非常不可靠。即使有详细描述，模型仍然会引入细微的变化（例如发型、肤色、面部结构） 4，导致在剪辑时出现明显的“跳跃”。

#### **2\. 规避策略 2 (后期制作, 高保真)：外部面部替换 (Face-Swapping)**

这是目前专业人士和严肃创作者中*事实上的* (de facto) 解决方案。它承认 API 在角色一致性上的失败，并将这个问题转移到后期制作中解决。

**工作流** 4：

1. **生成“英雄”图像**：首先，在 Sora 2 的图像模式或 Midjourney 等工具中，生成一个（或多个角度的）你希望保持一致的“英雄”角色面部参考图像 38。  
2. **在 Sora 2 API 中生成视频**：使用本报告第四至六节中的技术，专注于获得*除了面部之外*的一切正确要素：动作、光照、摄影和风格。使用一个*通用*的角色描述（例如，“一个 30 多岁的男人”）。  
3. **后期处理**：将生成的 Sora 2 视频剪辑导入到专业的面部替换工具中（例如开源的 DeepFaceLab 或 Roop 4，或 Adobe After Effects 插件）。  
4. **执行替换**：使用步骤 1 中的“英雄”图像，替换 Sora 2 视频中通用角色的面部。

这种混合工作流（Sora 2 \+ DeepFaceLab）是目前唯一能在保持 Sora 2 强大物理和环境渲染能力的同时，实现高保真角色一致性的方法 8。

#### **3\. 规避策略 3 (非官方, 不稳定)：绕过审核**

一些社区成员在讨论（例如 TikTok 40）和尝试“欺骗” input\_reference 的面部审核系统。这些技术可能包括对参考图像进行轻微的艺术处理、添加噪声、或将其与其他图像“渐变”混合，以欺骗 AI 使其不再将其识别为“人类面孔” 40。

* **警告**：这些是“越狱” (jailbreaks)，不是稳定的 API 工作流。它们随时可能被 OpenAI 的后续安全更新所修补，不应作为专业应用程序的基础。

#### **4\. 规避策略 4 (未来提议)：已验证的合成主题 ID**

OpenAI 开发者论坛上的一个前瞻性提议 41 指出了一个潜在的官方解决方案：“**已验证的合成主题 ID” (Verified Synthetic Subject ID)**。

* **构想**：允许开发者在平台内生成一个*可证明是 AI 合成的、非真实*的角色，并将其注册。  
* **执行**：该合成角色将被分配一个唯一的标识符（例如 @subject\_001A）。  
* **应用**：开发者可以在未来的提示词中调用此 ID（例如，"Use subject @subject\_001A walking through the city..."），模型将检索该角色的视觉数据并保持一致性。  
* **优势**：这种方法既能满足开发者对角色一致性的需求，又能遵守 OpenAI“禁止生成真实人物”的安全政策 41。

### **根本性的“哲学错位”**

Sora 2 API 的现状揭示了一个根本性的“哲学错位” (philosophical mismatch)：

1. OpenAI 的政策 5 目前优先考虑*防止滥用*（例如 deepfakes），而不是*赋能合法的创意工作流*（例如叙事电影中的虚构角色）。  
2. API 的设计初衷似乎是用于*创意性的即兴创作*（“将提示词视为愿望清单，而非合同” 3），但专业工作流需要的是*生产级的可控性* 2。  
3. 角色一致性是这种错位的核心牺牲品。

**战略结论**：对于寻求构建叙事内容的开发者来说，Sora 2 API 目前是一个*不完整的工具*。它是一个功能极其强大的“场景渲染器” (scene-renderer)，但它*迫使*开发者采用**混合工作流 (hybrid pipeline)**，将角色一致性这一关键任务外包给 DeepFaceLab 等第三方后期制作工具 38。

## **VIII. 实用提示词示例汇编**

本节提供了用户请求的“尽可能多的范例”，将前几节的理论汇总为可操作的参考表和模板。

### **表 5：电影化一致性技术词典**

此表为开发者提供了一个快速参考，用于将创意视觉转换为 Sora 2 能够理解和一致执行的技术提示词。

| 类别 | 技术提示词 (Technical Prompt Term) | 应用 / 效果 | 来源 |
| :---- | :---- | :---- | :---- |
| **镜头** | 85mm lens | “人像镜头”。压缩背景，创造柔和的焦外 (bokeh)，使主体突出。 | 20 |
| **镜头** | Anamorphic 2.0x lens | “宽屏电影感”。产生椭圆形焦外、水平光晕和超宽纵横比。 | 3 |
| **镜头** | 35mm lens | “经典电影镜头”。自然的视角和景深，适合纪实或叙事。 | 20 |
| **景深** | Shallow DOF (f/2) | 浅景深。模糊背景，将观众注意力引向主体。 | 16 |
| **光照** | Volumetric light | 体积光/“上帝之光”。可见的光束，营造戏剧性、多尘的氛围。 | 19 |
| **光照** | Golden Hour | 黄金时段。日出/日落时的光线，产生温暖、柔和、长长的阴影。 | 20 |
| **光照** | Backlit rim highlights | 逆光轮廓光。从背后照亮主体，产生“光环”效果，使其与背景分离。 | 16 |
| **色彩** | amber and teal palette | “琥珀色与青色”调色板。现代电影中非常流行的调色方案，暖肤色/冷阴影。 | 18 |
| **色彩** | Palette anchors: \[color1, color2\] | 调色板锚点。明确定义3-5种主色调，以强制实现色彩一致性。 | 3 |
| **物理** | high shutter to freeze droplets | 高快门速度。定格快速运动（如水滴），无运动模糊。 | 20 |
| **物理** | footfalls splashing in puddles | 脚步溅起水花。强制模型渲染水坑和相应的物理交互。 | 7 |

### **表 6：完整 API 请求模板（Python 与 cURL）**

此模板展示了如何将所有元素（硬性参数、风格化脊柱、多镜头故事板、音频层）组合成一个完整的、结构化的 API 请求。

#### **1\. Python (openai-python 库)**

9

Python

import OpenAI  
from openai import OpenAI

client \= OpenAI() \# 假设 OPENAI\_API\_KEY 已在环境变量中设置

\# 1\. 定义“风格化脊柱” (Style Spine)   
\# 这种风格将在所有镜头中重复使用，以确保视觉一致性  
style\_spine \= (  
    "Cinematography: 85mm lens, f/2.2 for shallow DOF. "  
    "Mood: cinematic and tense, melancholic. "  
    "Lighting: soft ambient light with cool blue and warm amber tones. "  
    "Grade: teal and amber color grade."  
) \[16, 18, 20\]

\# 2\. 定义多镜头叙事和音频层 \[21, 31\]  
prompt\_narrative \= (  
    f"Shot 1: {style\_spine} "  
    "Wide shot of a rain-slicked street at night, neon signs reflecting in puddles. "  
    "Actions: \- A lone figure in a trench coat walks quickly down the sidewalk. "  
    "Sound: distant traffic rumble, footsteps on wet pavement."  
    "\\n\\n"  
    f"Shot 2: {style\_spine} "  
    "Medium close-up shot of the \*\*same figure from the previous shot\*\*, \*\*maintaining the same trench coat\*\*. "  
    "Actions: \- The figure stops, looks up at a flickering streetlight. "  
    "Sound: footsteps stop, electric buzz from streetlight, faint rain patter."  
) \[3, 6, 31\]

try:  
    video\_job \= client.videos.create(  
        model="sora-2-pro",  \# 使用 Pro 模型以获得最高稳定性和质量   
        prompt=prompt\_narrative,  
        size="1280x720",     \# 16:9 宽高比   
        seconds="8",         \# 8秒时长   
          
        \# \--- 可选：用于非人类主题 \---  
        \# input\_reference="https://path.to/my/non-human-character.png"   
    )  
      
    print(f"Video generation started: {video\_job}")  
    \# 此处需要添加轮询 Get video status 的逻辑 

except openai.RateLimitError:  
    print("Rate limit exceeded.")  
except openai.BadRequestError as e:  
    print(f"Bad request (check prompt or params): {e}") \# 可能是因为 input\_reference 包含人脸 

#### **2\. cURL (用于 shell 或后端)**

10

Bash

\# 注意：在实际应用中，prompt 字段中的换行符应正确转义  
\# 这里为了可读性而分行  
PROMPT\_STRING="Shot 1: Cinematography: 85mm lens, f/2.2 for shallow DOF. Mood: cinematic and tense. Lighting: cool blue and warm amber tones. Grade: teal and amber color grade. Wide shot of a rain-slicked street at night, neon signs reflecting in puddles. Actions: \- A lone figure in a trench coat walks quickly down the sidewalk. Sound: distant traffic rumble, footsteps on wet pavement. \\n\\n Shot 2: Cinematography: 85mm lens, f/2.2 for shallow DOF. Mood: cinematic and tense. Lighting: cool blue and warm amber tones. Grade: teal and amber color grade. Medium close-up shot of the same figure from the previous shot, maintaining the same trench coat. Actions: \- The figure stops, looks up at a flickering streetlight. Sound: footsteps stop, electric buzz from streetlight, faint rain patter."

curl \--request POST \\  
     \--url https://api.openai.com/v1/videos \\  
     \--header 'Content-Type: application/json' \\  
     \--header 'Authorization: Bearer $OPENAI\_API\_KEY' \\  
     \--data '{  
       "model": "sora-2-pro",  
       "prompt": "'"$PROMPT\_STRING"'",  
       "size": "1280x720",  
       "seconds": "8"  
     }'

## **IX. 结论性综合与未来展望**

本报告的深度研究证实，通过 Sora 2 API 实现一致性并非依赖单一技巧，而是一个需要纪律和架构化思维的工作流。我们的分析得出了关于当前 API 能力和局限性的明确结论。

### **核心结论**

1. 物理与风格一致性是已解决的问题：  
   Sora 2 的基础模型在物理和时间一致性方面表现卓越 1。开发者可以通过结合使用 sora-2-pro 模型的稳定性 9、一个在所有镜头中重复使用的“风格化脊柱” 7（包含技术性的电影指令 3）以及明确的物理和音频提示词 7，高度可靠地实现风格和物理一致性。  
2. 角色一致性是 API 层面未解决的问题：  
   对于逼真的人类角色，API 的功能是不完整的。OpenAI 出于安全政策的考虑 5，有意地禁用了 API 的两个关键功能：(1) 应用程序中的“Cameo”功能未在 API 中提供 5；(2) input\_reference 参数拒绝人类面部图像 5。  
3. **API 的当前角色：混合工作流的必需品**：  
   * 对于**非人类主题**（产品、动画、奇幻生物），API 是一个端到端的强大工具，使用 input\_reference 即可锁定一致性 3。  
   * 对于**逼真的人类叙事**，API 目前只能作为一个强大的“场景渲染器”。它*迫使*开发者采用一种**混合工作流 (Hybrid Workflow)**：使用 Sora 2 API 渲染场景、动作和光照，然后使用 DeepFaceLab 38 等外部后期制作工具来解决角色一致性问题。

### **未来展望**

API 功能（无 "Cameo" 5）与专业开发者需求（需要角色一致性 2）之间的当前差距，对于创意产业来说是不可持续的。

最可能的发展路径*不是* OpenAI 放松对其面部阻止政策的限制（因为 deepfake 的风险太高），而是实施一种既能满足政策要求又能解决开发者需求的方案。

在 OpenAI 开发者论坛上提议的“**已验证的合成主题 ID” (Verified Synthetic Subject ID)** 41 系统似乎是合乎逻辑的下一步。这种机制将允许开发者注册一个*可证明是 AI 生成的*角色，并在 API 调用中安全地重用它，从而在不违反安全护栏的情况下，最终解决 API 上的角色一致性瓶颈。

在此类功能实装之前，开发者必须接受 Sora 2 API 的双重特性：通过提示词工程实现卓越的风格控制，并通过后期制作实现必要的角色控制。

#### **引用的著作**

1. Sora 2 API Explained: What Developers Can Do Now & What's Next \- Synergy Labs, 访问时间为 十一月 16, 2025， [https://www.synergylabs.co/blog/sora-2-api-explained-what-developers-can-do-now-whats-next](https://www.synergylabs.co/blog/sora-2-api-explained-what-developers-can-do-now-whats-next)  
2. Need for Character Consistency and Style Locking in Image Generation \- ChatGPT, 访问时间为 十一月 16, 2025， [https://community.openai.com/t/need-for-character-consistency-and-style-locking-in-image-generation/1232362](https://community.openai.com/t/need-for-character-consistency-and-style-locking-in-image-generation/1232362)  
3. Sora 2 Prompting Guide | OpenAI Cookbook, 访问时间为 十一月 16, 2025， [https://cookbook.openai.com/examples/sora/sora2\_prompting\_guide](https://cookbook.openai.com/examples/sora/sora2_prompting_guide)  
4. Sora finally allowing consistent characters to be used without the need of cameos \- Reddit, 访问时间为 十一月 16, 2025， [https://www.reddit.com/r/SoraAi/comments/1ok79d4/sora\_finally\_allowing\_consistent\_characters\_to\_be/](https://www.reddit.com/r/SoraAi/comments/1ok79d4/sora_finally_allowing_consistent_characters_to_be/)  
5. Sora 2 API \- Are the cameo features coming to the API? \- OpenAI Developer Community, 访问时间为 十一月 16, 2025， [https://community.openai.com/t/sora-2-api-are-the-cameo-features-coming-to-the-api/1361267](https://community.openai.com/t/sora-2-api-are-the-cameo-features-coming-to-the-api/1361267)  
6. OpenAI Sora 2: Complete Guide \+ Prompts \+ Cameos \+ Physics (October 2025), 访问时间为 十一月 16, 2025， [https://superprompt.com/blog/openai-sora-2-complete-guide](https://superprompt.com/blog/openai-sora-2-complete-guide)  
7. Sora 2 Prompt Authoring Best Practices (2025): Proven Workflow Guide \- Skywork.ai, 访问时间为 十一月 16, 2025， [https://skywork.ai/blog/sora-2-prompt-authoring-best-practices-2025/](https://skywork.ai/blog/sora-2-prompt-authoring-best-practices-2025/)  
8. How to Get Consistent Characters with OpenAI Sora 2: The Ultimate Post-Production Guide, 访问时间为 十一月 16, 2025， [https://blog.republiclabs.ai/2025/10/how-to-get-consistent-characters-with.html](https://blog.republiclabs.ai/2025/10/how-to-get-consistent-characters-with.html)  
9. Video generation with Sora \- OpenAI API, 访问时间为 十一月 16, 2025， [https://platform.openai.com/docs/guides/video-generation](https://platform.openai.com/docs/guides/video-generation)  
10. Sora 2 Mini Product Commercial Workflow (generate 12 second product promo video) : r/n8n \- Reddit, 访问时间为 十一月 16, 2025， [https://www.reddit.com/r/n8n/comments/1o300gc/sora\_2\_mini\_product\_commercial\_workflow\_generate/](https://www.reddit.com/r/n8n/comments/1o300gc/sora_2_mini_product_commercial_workflow_generate/)  
11. Sora 2 Prompting Guide Released: OpenAI Official Best Practices, 访问时间为 十一月 16, 2025， [https://soratoai.com/en/blog/sora-2-prompting-guide/](https://soratoai.com/en/blog/sora-2-prompting-guide/)  
12. Sora 2 API | OpenAI \- Replicate, 访问时间为 十一月 16, 2025， [https://replicate.com/openai/sora-2](https://replicate.com/openai/sora-2)  
13. Sora 2 API Documentation, 访问时间为 十一月 16, 2025， [https://docs.pollo.ai/m/sora/sora-2](https://docs.pollo.ai/m/sora/sora-2)  
14. Sora 2 API Tutorial: Complete Guide to OpenAI Video Generation API (2025) \- Cursor IDE, 访问时间为 十一月 16, 2025， [https://www.cursor-ide.com/blog/sora-2-api-tutorial](https://www.cursor-ide.com/blog/sora-2-api-tutorial)  
15. Sora 2 API With Python: A Complete Guide With Examples \- DataCamp, 访问时间为 十一月 16, 2025， [https://www.datacamp.com/tutorial/sora-2-api-guide](https://www.datacamp.com/tutorial/sora-2-api-guide)  
16. Sora 2 Prompting Guide, 访问时间为 十一月 16, 2025， [https://soratoai.com/en/docs/guides/sora-2-prompting-guide/](https://soratoai.com/en/docs/guides/sora-2-prompting-guide/)  
17. Ultimate Sora 2 Prompt Guide: Craft Perfect AI Video Instructions for Cinematic Results, 访问时间为 十一月 16, 2025， [https://www.glbgpt.com/th/hub/ultimate-sora-2-prompt-guide/](https://www.glbgpt.com/th/hub/ultimate-sora-2-prompt-guide/)  
18. OpenAI Sora \- Bookerfly, 访问时间为 十一月 16, 2025， [https://bookerfly.de/wp-content/uploads/Sora-2-Guide-Janet-Zentel-Final.pdf](https://bookerfly.de/wp-content/uploads/Sora-2-Guide-Janet-Zentel-Final.pdf)  
19. Image Generation Prompt Structure for OpenAI's Sora \- Cyber Raiden, 访问时间为 十一月 16, 2025， [https://cyberraiden.wordpress.com/2025/08/10/image-generation-prompt-structure-for-openais-sora/](https://cyberraiden.wordpress.com/2025/08/10/image-generation-prompt-structure-for-openais-sora/)  
20. Can Sora 2 Fool Your Eyes? 10 Hyper‑Real Wildlife Prompts (That Don't Look AI-ish) \- Sider, 访问时间为 十一月 16, 2025， [https://sider.ai/blog/ai-videos/can-sora-2-fool-your-eyes-10-hyper-real-wildlife-prompts-that-don-t-look-ai-ish](https://sider.ai/blog/ai-videos/can-sora-2-fool-your-eyes-10-hyper-real-wildlife-prompts-that-don-t-look-ai-ish)  
21. Exploring Higgsfield Sora 2 Trends: The Instant Ad Guide, 访问时间为 十一月 16, 2025， [https://higgsfield.ai/blog/Exploring-Higgsfield-Sora-2-Trends-The-Instant-Ad-Guide](https://higgsfield.ai/blog/Exploring-Higgsfield-Sora-2-Trends-The-Instant-Ad-Guide)  
22. Sora 2 Prompt Engineering Best Practices: Complete Guide to Professional AI Video (2025), 访问时间为 十一月 16, 2025， [https://vatsalshah.in/blog/sora-2-prompt-engineering-guide](https://vatsalshah.in/blog/sora-2-prompt-engineering-guide)  
23. Create Hollywood-Quality AI Videos In 30 ... \- Sora Prompt Generator, 访问时间为 十一月 16, 2025， [https://promptsgenerators.com/sora-prompt-generator/](https://promptsgenerators.com/sora-prompt-generator/)  
24. Prompt Strategy for Sora 2: The Top 10 Prompts and the Business Logic Behind Them, 访问时间为 十一月 16, 2025， [https://sider.ai/blog/ai-tools/prompt-strategy-for-sora-2-the-top-10-prompts-and-the-business-logic-behind-them](https://sider.ai/blog/ai-tools/prompt-strategy-for-sora-2-the-top-10-prompts-and-the-business-logic-behind-them)  
25. sora2 video generation \+ prompt words for automatically creating video storyboards \- Reddit, 访问时间为 十一月 16, 2025， [https://www.reddit.com/r/SoraAi/comments/1ogolqa/sora2\_video\_generation\_prompt\_words\_for/](https://www.reddit.com/r/SoraAi/comments/1ogolqa/sora2_video_generation_prompt_words_for/)  
26. How to Use Sora AI: A Guide With 10 Practical Examples \- DataCamp, 访问时间为 十一月 16, 2025， [https://www.datacamp.com/tutorial/sora-ai](https://www.datacamp.com/tutorial/sora-ai)  
27. Sora 2 API is Here \- What You Need to Know \- YouTube, 访问时间为 十一月 16, 2025， [https://www.youtube.com/watch?v=YWvN7EvVQQU](https://www.youtube.com/watch?v=YWvN7EvVQQU)  
28. Sora 2: Key Features You Need to Know \- Skywork.ai, 访问时间为 十一月 16, 2025， [https://skywork.ai/blog/sora-2-key-features-you-need-to-know/](https://skywork.ai/blog/sora-2-key-features-you-need-to-know/)  
29. Model \- OpenAI API, 访问时间为 十一月 16, 2025， [https://platform.openai.com/docs/models/sora-2](https://platform.openai.com/docs/models/sora-2)  
30. 7 Stunning Prompt Examples for OpenAI's Sora 2 to Make Video \- CometAPI \- All AI Models in One API, 访问时间为 十一月 16, 2025， [https://www.cometapi.com/7-stunning-prompt-examples-for-openais-sora-2-to-make-video/](https://www.cometapi.com/7-stunning-prompt-examples-for-openais-sora-2-to-make-video/)  
31. Sora 2 Best Prompts: Complete Guide to AI Video Generation in 2025 \- Cursor IDE, 访问时间为 十一月 16, 2025， [https://www.cursor-ide.com/blog/sora-2-best-prompts](https://www.cursor-ide.com/blog/sora-2-best-prompts)  
32. How To – Leonardo AI, 访问时间为 十一月 16, 2025， [https://leonardo.ai/news/category/how-to/feed/](https://leonardo.ai/news/category/how-to/feed/)  
33. A comprehensive guide to Google's Veo 3 \- CometAPI \- All AI Models in One API, 访问时间为 十一月 16, 2025， [https://www.cometapi.com/what-is-veo-3-how-to-use-it-cometapi/](https://www.cometapi.com/what-is-veo-3-how-to-use-it-cometapi/)  
34. 8 Stunning Prompt Examples for OpenAI's Sora 2 AI Video Gene | Eachlabs, 访问时间为 十一月 16, 2025， [https://www.eachlabs.ai/blog/8-stunning-prompt-examples-for-openais-sora-2-ai-video-generator-api-access-soon-via-eachlabs](https://www.eachlabs.ai/blog/8-stunning-prompt-examples-for-openais-sora-2-ai-video-generator-api-access-soon-via-eachlabs)  
35. Generating content with Cameos | OpenAI Help Center, 访问时间为 十一月 16, 2025， [https://help.openai.com/en/articles/12435986-generating-content-with-cameos](https://help.openai.com/en/articles/12435986-generating-content-with-cameos)  
36. Is it somehow possible to use Cameos with the Sora 2 API? : r/n8n \- Reddit, 访问时间为 十一月 16, 2025， [https://www.reddit.com/r/n8n/comments/1ovwwpj/is\_it\_somehow\_possible\_to\_use\_cameos\_with\_the/](https://www.reddit.com/r/n8n/comments/1ovwwpj/is_it_somehow_possible_to_use_cameos_with_the/)  
37. How to not alter faces : r/SoraAi \- Reddit, 访问时间为 十一月 16, 2025， [https://www.reddit.com/r/SoraAi/comments/1m3nwvo/how\_to\_not\_alter\_faces/](https://www.reddit.com/r/SoraAi/comments/1m3nwvo/how_to_not_alter_faces/)  
38. You Won't Believe The SECRET to Consistent Characters in Sora2 \- YouTube, 访问时间为 十一月 16, 2025， [https://www.youtube.com/watch?v=lwHR8ENb120](https://www.youtube.com/watch?v=lwHR8ENb120)  
39. I Built the Ultimate Consistent Character UGC Ad Machine (Sora 2 API \+ n8n) \- YouTube, 访问时间为 十一月 16, 2025， [https://www.youtube.com/watch?v=I87fCGIbgpg](https://www.youtube.com/watch?v=I87fCGIbgpg)  
40. Someone managed to upload a face of a person without Sora 2 detecting it \- Reddit, 访问时间为 十一月 16, 2025， [https://www.reddit.com/r/SoraAi/comments/1ob7317/someone\_managed\_to\_upload\_a\_face\_of\_a\_person/](https://www.reddit.com/r/SoraAi/comments/1ob7317/someone_managed_to_upload_a_face_of_a_person/)  
41. Feature Request: Verified Synthetic Subject IDs for Sora-2 \- OpenAI Developer Community, 访问时间为 十一月 16, 2025， [https://community.openai.com/t/feature-request-verified-synthetic-subject-ids-for-sora-2/1364267](https://community.openai.com/t/feature-request-verified-synthetic-subject-ids-for-sora-2/1364267)