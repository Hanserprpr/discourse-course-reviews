module ::CourseReviews::Labels
  MAP = {
    "recommend" => "推荐",
    "depends" => "看情况",
    "cautious" => "谨慎选",
    "general" => "通识课",
    "major" => "专业课",
    "required" => "公共课",
    "elective" => "选修课",
    "light" => "轻",
    "medium" => "中等",
    "heavy" => "重",
    "low" => "低",
    "high" => "高",
    "none" => "不点名",
    "occasional" => "偶尔",
    "frequent" => "经常",
    "exam" => "考试",
    "paper" => "论文",
    "presentation" => "展示",
    "homework" => "作业",
    "project" => "项目",
    "gpa" => "刷绩点",
    "learning" => "真想学",
    "easy_credit" => "混学分",
    "beginner" => "新手",
    "advanced" => "有基础",
    "pending" => "待审核",
    "published" => "已发布",
    "hidden" => "已隐藏"
  }.freeze

  def self.call(value)
    MAP[value].presence || value
  end

  def self.array(values)
    Array(values).map { |value| call(value) }
  end
end
