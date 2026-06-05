export default <template>
  <div>
    <form class="course-reviews-filters" method="get" action="/course-reviews">
      <input
        name="q"
        value={{@controller.q}}
        class="course-reviews-search"
        placeholder="搜索课程、老师或学院"
      />

      <select name="course_type" value={{@controller.course_type}}>
        <option value="">全部类型</option>
        <option value="general">通识课</option>
        <option value="major">专业课</option>
        <option value="required">公共课</option>
        <option value="elective">选修课</option>
      </select>

      <select name="recommendation" value={{@controller.recommendation}}>
        <option value="">全部建议</option>
        <option value="recommend">推荐</option>
        <option value="depends">看情况</option>
        <option value="cautious">谨慎选</option>
      </select>

      <select name="workload" value={{@controller.workload}}>
        <option value="">全部工作量</option>
        <option value="light">轻</option>
        <option value="medium">中等</option>
        <option value="heavy">重</option>
      </select>

      <button class="btn btn-primary" type="submit">筛选</button>
    </form>

    <table class="topic-list course-reviews-list">
      <thead>
        <tr>
          <th>课程</th>
          <th>老师</th>
          <th>标签摘要</th>
          <th>评价数</th>
        </tr>
      </thead>
      <tbody>
        {{#each @controller.model.courses as |course|}}
          <tr>
            <td>
              <a href="/course-reviews/courses/{{course.id}}" class="title">{{course.name}}</a>
              {{#if course.department}}<div class="course-review-muted">{{course.department}}</div>{{/if}}
            </td>
            <td>
              {{#each course.teachers as |teacher|}}
                <span class="course-review-pill">{{teacher.name}}</span>
              {{/each}}
            </td>
            <td>
              {{#if course.summary_labels.top_recommendation}}<span class="course-review-tag">{{course.summary_labels.top_recommendation}}</span>{{/if}}
              {{#if course.summary_labels.top_workload}}<span class="course-review-tag">{{course.summary_labels.top_workload}}</span>{{/if}}
              {{#each course.summary_labels.top_assessment_methods as |method|}}
                <span class="course-review-tag">{{method}}</span>
              {{/each}}
            </td>
            <td>{{course.review_count}}</td>
          </tr>
        {{/each}}
      </tbody>
    </table>
  </div>
</template>;
