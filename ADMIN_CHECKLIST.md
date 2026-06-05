# 课程评价插件部署检查清单

## 安装前

- 确认目标站点允许安装自定义 Discourse 插件。
- 确认 Discourse 版本满足插件声明的 `required_version: 3.4.0`。
- 准备一个课程评价分类，建议名称：`课程评价`。
- 确认分类 slug，默认建议：`course-reviews`。

## 安装

本地开发：

```bash
ln -s /absolute/path/discourse-course-reviews /path/to/discourse/plugins/discourse-course-reviews
```

生产环境：

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/your-org/discourse-course-reviews.git
```

然后 rebuild：

```bash
./launcher rebuild app
```

## 站点设置

- `course_reviews_enabled`: `true`
- `course_reviews_category_slug`: 设置为课程评价分类 slug，例如 `course-reviews`
- `course_reviews_allowed_groups`: 选择允许查看和发布课程评价的用户组；管理员始终可访问，留空则只有管理员可访问
- `course_reviews_low_trust_level_requires_review`: 建议初始值 `1`
- 如果课程评价生成的话题也要仅组内可见，请在 Discourse 分类权限里把课程评价分类限制给同一用户组

## 验收流程

1. 打开 `/course-reviews`，确认课程列表页可以访问。
2. 打开 `/course-reviews/new`，确认结构化发布表单可以填写。
3. 在课程评价分类点击新建话题，确认 Composer 内直接出现课程评价表单。
4. 使用普通测试账号提交评价。
5. 确认插件表 `course_reviews` 有结构化记录。
6. 确认 Discourse 自动生成 `[课程评价] 课程名 - 老师 - 学期` topic。
7. 使用低信任账号提交，确认评价进入 pending。
8. 使用管理员访问 `/course-reviews/admin`，确认可以发布或隐藏 pending 评价。
9. 打开课程详情页，确认聚合标签和结构化评价展示正常。
10. 使用管理员合并重复课程，确认旧课程提示已合并，新课程保留评价。

## 回滚

- 在 `app.yml` 中移除插件 clone 配置。
- rebuild Discourse。
- 如果需要保留历史数据，不要删除插件表。
- 如果确认要清理数据，再手动 drop `course_review_*` 和 `course_reviews` 表。
