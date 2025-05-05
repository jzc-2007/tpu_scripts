# Auto Ka Manager

## Setting up `secret.json`

当然，以下是详细的步骤，教你如何在 Google Cloud Project 的服务器上通过 Google Sheets API 访问 Google Sheets（包括读取和修改）。

---

#### **步骤 1：启用 Google Sheets API**
1. 进入 [Google Cloud Console](https://console.cloud.google.com/)。
2. 选择你的 Google Cloud 项目（或者创建一个新项目）。
3. 在左侧导航栏中，点击 **"API 和服务"** → **"启用 API 和服务"**。
4. 搜索 **"Google Sheets API"**，然后点击 **"启用"**。

---

#### **步骤 2：创建服务账号**
1. 在 Google Cloud Console 中，进入 **"API 和服务"** → **"凭据"** 页面。
2. 点击 **"创建凭据"** → **"服务账号"**。
3. 填写 **服务账号名称**，然后点击 **"创建"**。
4. 在 **"服务账号权限"** 步骤，可以暂时跳过（默认不需要分配额外权限）。
5. 完成创建后，在服务账号列表中，点击新创建的服务账号。
6. 进入 **"密钥"** 选项卡，点击 **"添加密钥"** → **"创建新的密钥"**，选择 **JSON 格式**，然后点击 **"创建"**。
7. 一个 JSON 文件将自动下载到你的本地机器，稍后会在代码中使用它。

---

#### **步骤 3：授权服务账号访问 Google Sheets**
1. 打开你的 Google Sheets 文档（或者创建一个新的）。
2. 点击右上角的 **"共享"** 按钮。
3. 在 "添加用户" 输入框中，输入 **你的服务账号的 email 地址**（格式一般是 `your-service-account@your-project-id.iam.gserviceaccount.com`）。
4. 选择权限（**查看** 或 **编辑**），然后点击 **"发送"**。

---

## Run

```shell
bash run_manager.sh
```