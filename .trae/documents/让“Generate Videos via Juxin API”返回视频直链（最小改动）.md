## 调整目标
- 在当前可正常运行的工作流基础上，不改变结构与节点连线，仅最小化修改两个“Return Video URL”节点的取值逻辑，使其直接输出视频下载链接（video_url），而非任务 ID。

## 变更范围（仅2处）
- 节点：Return Video URL (Text)
- 节点：Return Video URL (Image)
- 其它节点（创建/等待/查询/判断）保持不变。

## 修改内容
- 将两个 Set 节点中 string → name=video_url 的 value 表达式替换为可兼容多种返回结构的安全取值：

```n8n
={{ (
  () => {
    try {
      // 1) 聚鑫统一风格：data.video_url
      if ($json?.data?.video_url) return $json.data.video_url;
      // 2) 直接在根上（少见）：video_url
      if ($json?.video_url) return $json.video_url;
      // 3) 一些网关回传：data.url
      if ($json?.data?.url) return $json.data.url;
      // 4) 旧模板/Kie风格：data.resultJson 里有 resultUrls[0] 或 video_url
      const raw = $json?.data?.resultJson;
      const obj = typeof raw === 'string' ? JSON.parse(raw) : raw;
      if (obj?.resultUrls?.[0]) return obj.resultUrls[0];
      if (obj?.video_url) return obj.video_url;
      if (obj?.url) return obj.url;
      return '';
    } catch (e) {
      return $json?.data?.url || $json?.video_url || '';
    }
  }
)() }}
```

- 上述同一表达式分别应用于：
  - Return Video URL (Text) 的 `values.string[0].value`
  - Return Video URL (Image) 的 `values.string[0].value`

## 说明与依据
- 你提供的“聚鑫任务返回信息.md”样例中，视频直链位于 `data.video_url`（形如 `https://...mp4`）。
- 现有工作流的两个 Set 节点使用的是 `JSON.parse($json.data.resultJson).resultUrls[0]` 之类旧模板逻辑，不覆盖 `data.video_url`。
- 该表达式对以下四类结构做了兼容：
  1) `data.video_url`
  2) `video_url`
  3) `data.url`
  4) `data.resultJson`（内含 `resultUrls[0]` 或 `video_url`/`url`）

## 验证方式
- 触发一次文本/图片生成，等待状态查询节点返回包含 `data.video_url` 的结构。
- 查看两个 Set 节点的输出，应出现字段 `video_url` 且为可下载的 MP4 URL。
- 若工作流有 Webhook 响应节点，可将该 `video_url` 一并返回（可选，不在本次改动范围）。

## 备选（仅在当前查询接口不含 video_url 时考虑）
- 保持本次最小改动不触及查询节点；若后续你发现查询节点返回的字段名不一致，我再按你提供的结构额外做一次微调（仅更新判断条件或字段名，不改连线）。

## 预期输出
- 字段：`video_url`
- 值：可直接下载的视频直链（例如 `https://...mp4`），与“聚鑫任务返回信息.md”相符。

## 风险控制
- 不改变任何结构与连线；仅编辑两个 Set 节点的表达式。
- 表达式使用 try/catch 与多级回退，避免后端字段波动导致空值。