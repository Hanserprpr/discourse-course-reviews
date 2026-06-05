import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { eq } from "discourse/truth-helpers";

export default <template>
  <div>
    <div class="course-reviews-header">
      <h2>课程评价审核</h2>
      <a href="/course-reviews" class="btn">返回列表</a>
    </div>

    {{#if @controller.error}}
      <div class="alert alert-error">{{@controller.error}}</div>
    {{/if}}

    {{#if @controller.model.reviews.length}}
      {{#each @controller.model.reviews as |review|}}
        <article class="course-review-card">
          <div class="course-review-card-meta">
            <strong>{{review.course_name}}</strong>
            <span>{{review.teacher_name}}</span>
            <span>{{review.term}}</span>
            <span>{{review.username}}</span>
          </div>
          <div>
            <span class="course-review-tag">{{review.labels.recommendation}}</span>
            <span class="course-review-tag">{{review.labels.workload}}</span>
            <span class="course-review-tag">{{review.labels.difficulty}}</span>
            {{#each review.labels.assessment_methods as |method|}}
              <span class="course-review-tag">{{method}}</span>
            {{/each}}
          </div>
          <p class="course-review-one-line">{{review.one_line_advice}}</p>
          {{#if review.detail_text}}<p>{{review.detail_text}}</p>{{/if}}

          <div class="course-review-actions">
            <button class="btn btn-primary" type="button" disabled={{eq @controller.savingId review.id}} {{on "click" (fn @controller.setStatus review "published")}}>
              发布
            </button>
            <button class="btn btn-danger" type="button" disabled={{eq @controller.savingId review.id}} {{on "click" (fn @controller.setStatus review "hidden")}}>
              隐藏
            </button>
          </div>
        </article>
      {{/each}}
    {{else}}
      <div class="course-review-empty">暂无待审核评价。</div>
    {{/if}}
  </div>
</template>;
