import Component from "@glimmer/component";

export default class CourseReviewSummaryConnector extends Component {
  get review() {
    return this.args.outletArgs.topic.course_review;
  }

  <template>
    {{#if this.review}}
      <section class="course-review-topic-summary">
        <strong>课程评价</strong>
        <span>{{this.review.course_name}}</span>
        <span>{{this.review.teacher_name}}</span>
        <span>{{this.review.term}}</span>
        <span>{{this.review.labels.recommendation}}</span>
        <p>{{this.review.one_line_advice}}</p>
      </section>
    {{/if}}
  </template>
}
