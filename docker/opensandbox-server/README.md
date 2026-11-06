# OpenSandbox Server：direct

节点使用容器内独立的 Docker daemon，Cluster 通过节点管理端口直连。需要 Docker Engine、Compose v2，以及特权容器和 `cgroup: host` 支持。

## 启动

在本目录执行：

```bash
cp .env.example .env
cp sandbox.toml.example sandbox.toml
mkdir -p data/docker data/opensandbox workspace offline
```

编辑 `sandbox.toml`：

- `server.api_key`：节点密钥，注册到 Cluster 时使用相同值。
- `docker.host_ip`：Cluster 可达的节点 IP。
- `docker.port_range_min/max`：与 `.env` 中的沙盒端口段一致。

```bash
docker compose up -d
docker compose ps
curl -fsS http://127.0.0.1:8090/health
```

默认开放管理端口 `8090` 和沙盒端口段 `10000–10100`。在 Cluster 管理页注册节点：连接方式选 `direct`，`base_url` 填 `http://<节点地址>:8090`，`workspace_root` 填 `/workspace`，容量按所属池的调度模式填写。

Cluster 使用独立 Compose 网络时，不能通过容器服务名访问节点；请填写从 Cluster 可达的宿主机地址。

## 镜像

默认使用现有发布镜像。两种连接模式共用本目录的 Dockerfile 和入口脚本；在项目根目录可自行构建：

```bash
docker build -t opensandbox-server:local docker/opensandbox-server
```

在节点目录的 `.env` 中设置 `OPENSANDBOX_SERVER_IMAGE=opensandbox-server:local` 后执行 `docker compose up -d`。

## 数据与运维

- `data/docker`：节点内 Docker 的镜像、容器和卷；`data/opensandbox`：Server 状态。
- `workspace`：沙盒工作数据。挂载根目录、`sandbox.toml` 的 `allowed_host_paths` 和 Cluster 的 `workspace_root` 必须一致。
- Cluster 将调用方提供的相对挂载路径拼到工作根目录，不会自动添加业务 ID；例如 `job-123/ws` 映射为 `/workspace/job-123/ws`。
- 离线镜像包放入 `offline/`，然后执行 `docker compose exec opensandbox-server docker load -i /offline/<镜像包>.tar`。
- 查看日志：`docker compose logs -f opensandbox-server`；停止：`docker compose stop`。

不要挂载宿主机 `/var/run/docker.sock`。GPU 节点还需配置设备透传和 DinD 的 GPU runtime，模板未默认启用。

无需入站端口时使用 [tunnel 部署](../opensandbox-server-tunnel/README.md)。
