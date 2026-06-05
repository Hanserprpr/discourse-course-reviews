# 课程评价插件计划与进度

更新时间：2026-06-05

## 目标

完成一个可安装的 Discourse 原生插件 `discourse-course-reviews`，让用户在课程评价分类发帖时直接通过结构化表单选择课程、老师、学期、推荐倾向、工作量、难度、点名、考核方式、适合人群等字段。插件不提供数字评分，不做老师排名，结构化数据必须写入插件数据表，同时同步生成 Discourse topic/post 作为论坛讨论层。

## 已完成

- 插件骨架：`plugin.rb`、`about.json`、settings、server/client locale。
- 数据库迁移：
  - `course_review_courses`
  - `course_review_teachers`
  - `course_review_course_teachers`
  - `course_reviews`
  - `course_review_summaries`
- 后端模型：
  - 课程、老师、课程-老师关联、评价、聚合摘要。
  - 枚举校验：推荐倾向、工作量、难度、点名、考核方式、适合人群、状态。
  - 中文标签映射：`CourseReviews::Labels`。
  - 发布评价时自动生成 Discourse topic/post 正文。
- 后端 API：
  - `GET /course-reviews.json`
  - `GET /course-reviews/courses/search.json`
  - `GET /course-reviews/courses/:id.json`
  - `GET /course-reviews/reviews/pending.json`
  - `POST /course-reviews/reviews.json`
  - `PUT /course-reviews/reviews/:id.json`
  - `POST /course-reviews/courses/:id/merge.json`
- Discourse 前端 HTML 入口：
  - `GET /course-reviews`
  - `GET /course-reviews/new`
  - `GET /course-reviews/admin`
  - `GET /course-reviews/courses/:id`
  - 这些路由返回 Discourse application shell，由 Ember 前端接管，支持直接打开或刷新插件页面。
- 权限与治理：
  - 登录用户可发布评价。
  - 用户只能编辑自己的评价。
  - 管理员可更新评价状态、查看 pending 列表、合并课程。
  - 低信任等级用户提交进入 pending。
  - Staff 用户提交默认直接 published。
  - 已发布评价被隐藏时，课程详情不再展示该结构化评价，并尝试将对应 topic 标记为不可见。
- 前端：
  - `/course-reviews` 课程列表页。
  - `/course-reviews/new` 发布评价页。
  - `/course-reviews/courses/:id` 课程详情页。
  - `/course-reviews/admin` 待审核评价管理页。
  - 课程评价分类 Composer 区域直接渲染结构化表单。
  - Composer 表单区增加说明，提醒用户通过结构化表单提交，提交后自动生成 topic/post。
  - 课程和老师字段支持搜索候选选择；未匹配时按新课程/新老师创建。
  - 课程详情页提供管理员课程合并入口。
  - Topic 顶部显示课程评价摘要块。
  - Discourse 风格样式。
  - 前端实现已去掉 optional chaining，降低目标 Discourse 构建链兼容风险。
  - 初始化器路径调整为 `assets/javascripts/discourse/initializers/course-reviews.js`，贴近当前 Discourse 插件结构。
- 文档与测试：
  - README 安装和 API 说明。
  - 模型 spec 覆盖枚举、无数字评分字段、topic 标题/正文生成。
  - request spec 覆盖创建评价和管理员 pending 列表。
  - README 记录本地安装、页面入口、API 和完整 Discourse 环境验证步骤。
  - `ADMIN_CHECKLIST.md` 记录部署、站点设置、验收和回滚步骤。
  - `scripts/validate-plugin.rb` 提供本地静态验证：必需文件、JSON/YAML、Ruby 语法、关键路由、表单字段、禁止数字评分字段、禁止 optional chaining。
  - 补充 `LICENSE`，与 `about.json` 的 license 链接保持一致。

## 当前验证结果

- 已在本地运行 Ruby 语法检查：所有 `.rb` 文件 `ruby -c` 通过。
- 已新增并运行本地插件静态验证脚本：`ruby scripts/validate-plugin.rb`，输出 `course reviews plugin validation passed`。
- 已检查没有实现层面的 `TODO` / `FIXME`，没有实现层面的 `rating` 数据库字段。
- 当前插件文件数：48。
- 已浅克隆官方 Discourse 到 `/tmp/discourse-course-reviews-validation`，并将本插件 symlink 到 `plugins/discourse-course-reviews`。
- 已安装测试所需 Ruby 3.4、Bundler 4.0.11、Node 24、pnpm 依赖和临时 PostgreSQL 17 + pgvector 测试环境。
- 已在真实 Discourse checkout 中运行插件迁移：`LOAD_PLUGINS=1 bundle _4.0.11_ exec rails db:migrate RAILS_ENV=test`，插件表创建成功。
- 已在真实 Discourse checkout 中运行插件后端 specs：`LOAD_PLUGINS=1 bundle _4.0.11_ exec rspec plugins/discourse-course-reviews/spec`，结果 `4 examples, 0 failures`。
- 已在真实 Discourse checkout 中运行前端 lint：`pnpm eslint plugins/discourse-course-reviews/assets/javascripts`，结果通过。
- 已启动真实 Discourse development server：`LOAD_PLUGINS=1 bin/rails server -p 4200 -b 127.0.0.1`，插件成功编译加载。
- 已确认 Rails 路由表包含全部 JSON API 和前端 HTML fallback 路由。
- 已完成 HTTP smoke：
  - `/course-reviews` 返回 `200 text/html`
  - `/course-reviews/new` 返回 `200 text/html`
  - `/course-reviews/admin` 返回 `200 text/html`
  - `/course-reviews/courses/1` 返回 `200 text/html`
  - `/course-reviews.json` 在 `Accept: application/json` 下返回可解析 JSON。
- 已用 ChatGPT Atlas 做浏览器验证：
  - 初次打开 `/course-reviews` 时发现 Rails HTML shell 返回 `EmberCli::BuildError`，原因是本地只启动了 Rails server，没有启动 Discourse 前端 manifest dev server。
  - 启动 `pnpm --dir frontend/discourse start` 后，Atlas 重载 `/course-reviews`，标签标题从 `Action Controller: Exception caught` 恢复为 `Discourse`。
  - macOS 屏幕录制权限弹窗阻挡了截图级视觉确认，因此当前确认范围是 Atlas 真实浏览器可打开 app shell，不再是 500 exception。
- 本地浏览器验证 Discourse HTML 页面时，需要同时启动：
  - Rails：`LOAD_PLUGINS=1 DISCOURSE_SKIP_CSS_WATCHER=1 bin/rails server -p 4200 -b 127.0.0.1`
  - 前端：`pnpm --dir frontend/discourse start`

## 待在真实 Discourse 环境验证

- 打开 `course_reviews_category_slug` 对应分类的新建话题 Composer，确认结构化表单直接出现。
- 在授予截图/浏览器自动化权限后，用真实浏览器截图验证 `/course-reviews`、`/course-reviews/new`、`/course-reviews/courses/:id` 和 `/course-reviews/admin` 页面视觉和移动端布局。
- 通过浏览器提交一次评价，确认 topic/post 创建、结构化数据写入、pending 审核和隐藏/合并流程的 UI 体验。
- 根据目标站点导航体系确认顶部导航入口是否需要额外配置。
- 如果目标版本没有 `api.addNavigationBarItem`，插件不会因此初始化失败，但需要用站点导航设置或主题组件补一个显式入口。

## 已知风险

- Discourse 前端插件 API 和 outlet 名称会随版本变化；当前实现使用现代 `apiInitializer`、route-map、connector/component 结构，但仍需在目标站点版本中构建验证。
- 顶部导航入口当前使用插件 API 添加导航项；如果目标站点使用新版 sidebar/header 导航，可能需要按站点导航体系调整入口挂载。
