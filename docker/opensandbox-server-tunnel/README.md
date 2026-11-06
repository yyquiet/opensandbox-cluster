# OpenSandbox Server：tunnel

节点内的 frpc 主动连接 Cluster 的 frps，不发布宿主机端口。需要 Docker Engine、Compose v2，以及特权容器和 `cgroup: host` 支持；节点必须能访问 Cluster 的 FRP 登录地址，默认端口 `7000`。

## 注册与配置

1. 在 Cluster 创建池和节点，连接方式选 `tunnel`，填写节点 API Key、`workspace_root=/workspace` 和容量。
2. 在本目录准备配置，并将 `sandbox.toml` 的 `server.api_key` 改为注册时填写的值：

   ```bash
   cp ../opensandbox-server/sandbox.toml.example sandbox.toml
   mkdir -p data/docker data/opensandbox workspace offline
   ```

3. 下载该节点的隧道配置：

   ```bash
   curl -fsS "$CLUSTER_URL/api/v1/servers/$SERVER_ID/tunnel/frpc.toml" \
     -H "Authorization: Bearer $CLUSTER_SERVICE_API_KEY" -o frpc.toml
   chmod 600 frpc.toml
   ```

`frpc.toml.example` 仅供了解格式，实际配置应从 Cluster 下载。文件包含隧道凭证，不要提交到 Git。

已有 direct 节点切换为 tunnel 时，先停止节点，再调用 `PUT /api/v1/servers/{serverId}/tunnel`，然后下载配置。

## 启动与验证

```bash
docker compose up -d
docker compose ps
docker compose exec -T opensandbox-server curl -fsS http://127.0.0.1:8080/health
```

在 Cluster 执行节点健康检查，确认隧道连接和节点健康状态。节点侧运行 frpc；frps 部署在 Cluster 侧。

查看日志用 `docker compose logs -f opensandbox-server`，停止用 `docker compose stop`。数据目录、GPU 配置与自建镜像方式见 [Server 部署说明](../opensandbox-server/README.md)。自建镜像后，在本目录 `.env` 中设置 `OPENSANDBOX_SERVER_IMAGE=opensandbox-server:local`。
