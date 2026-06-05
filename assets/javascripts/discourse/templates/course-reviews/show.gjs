import { on } from "@ember/modifier";

export default <template>
  <div>
    {{#if @controller.model.merged_into_id}}
      <p>该课程已合并到新的课程条目。</p>
      <a class="btn btn-primary" href="/course-reviews/courses/{{@controller.model.merged_into_id}}">查看合并后的课程</a>
    {{else}}
      <div class="course-review-detail-header">
        <h2>{{@controller.model.course.name}}</h2>
        <div class="course-review-muted">
          {{@controller.model.course.department}} · {{@controller.model.course.course_type_label}}
        </div>
      </div>

      {{#if @controller.model.course.summary}}
        <section class="course-review-summary">
          <h3>大家通常认为</h3>
          <div class="course-review-summary-grid">
            <span>建议：{{@controller.model.course.summary_labels.top_recommendation}}</span>
            <span>工作量：{{@controller.model.course.summary_labels.top_workload}}</span>
            <span>难度：{{@controller.model.course.summary_labels.top_difficulty}}</span>
            <span>点名：{{@controller.model.course.summary_labels.top_attendance}}</span>
          </div>
        </section>
      {{/if}}

      <section class="course-review-review-list">
        <h3>结构化评价</h3>
        {{#each @controller.model.reviews as |review|}}
          <article class="course-review-card">
            <div class="course-review-card-meta">
              <strong>{{review.teacher_name}}</strong>
              <span>{{review.term}}</span>
              <span>{{review.username}}</span>
            </div>
            <p class="course-review-one-line">{{review.one_line_advice}}</p>
            <div>
              <span class="course-review-tag">{{review.labels.recommendation}}</span>
              <span class="course-review-tag">{{review.labels.workload}}</span>
              <span class="course-review-tag">{{review.labels.difficulty}}</span>
              {{#each review.labels.assessment_methods as |method|}}
                <span class="course-review-tag">{{method}}</span>
              {{/each}}
            </div>
            {{#if review.detail_text}}<p>{{review.detail_text}}</p>{{/if}}
            {{#if review.topic_id}}
              <a href="/t/{{review.topic_id}}">进入论坛讨论</a>
            {{/if}}
          </article>
        {{/each}}
      </section>

      {{#if @controller.isAdmin}}
        <section class="course-review-admin-box">
          <h3>管理员工具</h3>
          {{#if @controller.mergeError}}
            <div class="alert alert-error">{{@controller.mergeError}}</div>
          {{/if}}
          <form class="course-review-merge-form" {{on "submit" @controller.mergeCourse}}>
            <label>合并到课程 ID
              <input value={{@controller.targetCourseId}} {{on "input" @controller.setTargetCourseId}} />
            </label>
            <button class="btn" type="submit">合并课程</button>
          </form>
        </section>
      {{/if}}
    {{/if}}
  </div>
</template>;
