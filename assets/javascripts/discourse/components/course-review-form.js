/* eslint-disable discourse/no-unnecessary-tracked */
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";

const MULTI_FIELDS = ["assessment_methods", "suitable_for"];

export default class CourseReviewForm extends Component {
  @tracked course_name = "";
  @tracked course_id = null;
  @tracked teacher_name = "";
  @tracked teacher_id = null;
  @tracked department = "";
  @tracked term = "";
  @tracked course_type = "elective";
  @tracked recommendation = "depends";
  @tracked workload = "medium";
  @tracked difficulty = "medium";
  @tracked attendance = "occasional";
  @tracked assessment_methods = [];
  @tracked suitable_for = [];
  @tracked one_line_advice = "";
  @tracked detail_text = "";
  @tracked saving = false;
  @tracked error = null;
  @tracked courseOptions = [];
  @tracked teacherOptions = [];

  courseTypes = [
    { value: "general", label: "通识课" },
    { value: "major", label: "专业课" },
    { value: "required", label: "公共课" },
    { value: "elective", label: "选修课" },
  ];

  recommendations = [
    { value: "recommend", label: "推荐" },
    { value: "depends", label: "看情况" },
    { value: "cautious", label: "谨慎选" },
  ];

  levels = [
    { value: "light", label: "轻" },
    { value: "medium", label: "中等" },
    { value: "heavy", label: "重" },
  ];

  difficulties = [
    { value: "low", label: "低" },
    { value: "medium", label: "中等" },
    { value: "high", label: "高" },
  ];

  attendanceOptions = [
    { value: "none", label: "不点名" },
    { value: "occasional", label: "偶尔" },
    { value: "frequent", label: "经常" },
  ];

  assessmentOptions = [
    { value: "exam", label: "考试" },
    { value: "paper", label: "论文" },
    { value: "presentation", label: "展示" },
    { value: "homework", label: "作业" },
    { value: "project", label: "项目" },
  ];

  suitableOptions = [
    { value: "gpa", label: "刷绩点" },
    { value: "learning", label: "真想学" },
    { value: "easy_credit", label: "混学分" },
    { value: "beginner", label: "新手" },
    { value: "advanced", label: "有基础" },
  ];

  @action
  setValue(field, event) {
    this[field] = event.target.value;
  }

  @action
  async searchCourses(event) {
    this.course_name = event.target.value;
    this.course_id = null;

    if (this.course_name.length < 2) {
      this.courseOptions = [];
      return;
    }

    const response = await fetch(
      `/course-reviews/courses/search.json?q=${encodeURIComponent(this.course_name)}`,
      { credentials: "same-origin" }
    );
    const payload = await response.json();
    this.courseOptions = payload.courses || [];
    this.teacherOptions = payload.teachers || [];

    const exact = this.courseOptions.find((course) => course.name === this.course_name);
    if (exact) {
      this.selectCourseRecord(exact);
    }
  }

  @action
  selectCourse(event) {
    const course = this.courseOptions.find((item) => item.name === event.target.value);
    if (course) {
      this.selectCourseRecord(course);
    }
  }

  @action
  async searchTeachers(event) {
    this.teacher_name = event.target.value;
    this.teacher_id = null;

    if (this.teacher_name.length < 2) {
      return;
    }

    const response = await fetch(
      `/course-reviews/courses/search.json?q=${encodeURIComponent(this.teacher_name)}`,
      { credentials: "same-origin" }
    );
    const payload = await response.json();
    this.teacherOptions = payload.teachers || [];

    const exact = this.teacherOptions.find((teacher) => teacher.name === this.teacher_name);
    if (exact) {
      this.teacher_id = exact.id;
      this.department = this.department || exact.department || "";
    }
  }

  @action
  selectTeacher(event) {
    const teacher = this.teacherOptions.find((item) => item.name === event.target.value);
    if (teacher) {
      this.teacher_id = teacher.id;
      this.department = this.department || teacher.department || "";
    }
  }

  @action
  toggleMulti(field, value, event) {
    if (!MULTI_FIELDS.includes(field)) {
      return;
    }

    const current = this[field] || [];
    this[field] = event.target.checked
      ? [...current, value]
      : current.filter((item) => item !== value);
  }

  @action
  async submit(event) {
    if (event) {
      event.preventDefault();
    }
    this.saving = true;
    this.error = null;

    const response = await fetch("/course-reviews/reviews.json", {
      method: "POST",
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({
        course_name: this.course_name,
        course_id: this.course_id,
        teacher_name: this.teacher_name,
        teacher_id: this.teacher_id,
        department: this.department,
        term: this.term,
        course_type: this.course_type,
        recommendation: this.recommendation,
        workload: this.workload,
        difficulty: this.difficulty,
        attendance: this.attendance,
        assessment_methods: this.assessment_methods,
        suitable_for: this.suitable_for,
        one_line_advice: this.one_line_advice,
        detail_text: this.detail_text,
      }),
    });

    const payload = await response.json();
    this.saving = false;

    if (!response.ok) {
      this.error = this.errorMessage(payload, "提交失败，请检查表单。");
      return;
    }

    const topicId = payload.review && payload.review.topic_id;
    window.location.href = topicId
      ? `/t/${topicId}`
      : `/course-reviews/courses/${payload.review.course_id}`;
  }

  selectCourseRecord(course) {
    this.course_id = course.id;
    this.department = course.department || this.department;
    this.course_type = course.course_type || this.course_type;
    this.teacherOptions = course.teachers || this.teacherOptions;
  }

  get csrfToken() {
    const meta = document.querySelector("meta[name=csrf-token]");
    return meta && meta.content;
  }

  errorMessage(payload, fallback) {
    return payload && payload.errors ? payload.errors.join(", ") : fallback;
  }
}
