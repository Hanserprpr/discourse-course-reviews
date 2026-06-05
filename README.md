# discourse-course-reviews

Structured course reviews for Discourse.

This plugin adds a native course review module where users publish structured course experiences instead of numeric ratings. It is designed for course selection decisions: whether a course is worth taking, who it fits, how much work it takes, and how it is assessed.

## Features

- Course review category integration.
- Structured review form with no numeric rating fields.
- Course, teacher, review, and summary tables.
- Course list and detail JSON APIs.
- Course list, detail, and new-review Ember routes.
- Reusable structured form rendered both on `/course-reviews/new` and inside the course-review category composer area.
- Automatic Discourse topic/post creation for published reviews.
- Pending review flow for low trust-level users.
- Admin course merge support.
- Topic summary connector for course review topics.

## Installation

For local development, copy or symlink this directory into a Discourse checkout:

```bash
ln -s /absolute/path/discourse-course-reviews /path/to/discourse/plugins/discourse-course-reviews
```

For production, add the plugin repository to the Discourse container `app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/your-org/discourse-course-reviews.git
```

Rebuild Discourse:

```bash
./launcher rebuild app
```

## Required Site Settings

- `course_reviews_enabled`: enables the plugin.
- `course_reviews_category_slug`: slug for the category where the structured review composer notice appears. Default: `course-reviews`.
- `course_reviews_low_trust_level_requires_review`: users at or below this trust level submit reviews as pending.

Create a Discourse category whose slug matches `course_reviews_category_slug`.

For a deployer-facing checklist, see `ADMIN_CHECKLIST.md`.

## Pages

- `/course-reviews`: course list.
- `/course-reviews/new`: standalone structured review form.
- `/course-reviews/courses/:id`: course detail page.
- `/course-reviews/admin`: pending review moderation page for admins.

The same structured form is also rendered directly inside the composer when the active category slug matches `course_reviews_category_slug`.

## API

```text
GET  /course-reviews.json
GET  /course-reviews/courses/search.json?q=数据结构
GET  /course-reviews/courses/:id.json
GET  /course-reviews/reviews/pending.json
POST /course-reviews/reviews.json
PUT  /course-reviews/reviews/:id.json
POST /course-reviews/courses/:id/merge.json
```

`POST /course-reviews/reviews.json` accepts:

```json
{
  "course_name": "数据结构",
  "teacher_name": "张老师",
  "department": "计算机学院",
  "term": "2026春",
  "course_type": "major",
  "recommendation": "recommend",
  "workload": "heavy",
  "difficulty": "high",
  "attendance": "occasional",
  "assessment_methods": ["homework", "exam"],
  "suitable_for": ["learning", "advanced"],
  "one_line_advice": "能学到东西，但不适合只想轻松拿学分的人。",
  "detail_text": "每周都有作业，期末偏算法题。"
}
```

## Notes

The plugin intentionally does not include numeric scoring, teacher ranking pages, or anonymous attack-oriented flows. Discourse topics remain the public discussion layer; plugin tables remain the structured source of truth.

## Verification

Standalone checks from this plugin directory:

```bash
ruby scripts/validate-plugin.rb
```

Inside a full Discourse checkout:

```bash
LOAD_PLUGINS=1 bundle exec rspec plugins/discourse-course-reviews/spec
```

Then rebuild or boot Discourse and verify:

- The configured course review category composer renders the structured form.
- Publishing a review creates both a `course_reviews` row and a Discourse topic/post.
- Low trust-level users submit pending reviews.
- Admins can approve/hide pending reviews from `/course-reviews/admin`.
- Admins can merge duplicate courses from the course detail page.
