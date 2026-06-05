class UnlistCourseReviewTopics < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL
      UPDATE topics
      SET visible = FALSE
      WHERE id IN (
        SELECT topic_id
        FROM course_reviews
        WHERE topic_id IS NOT NULL
      )
    SQL
  end

  def down
    execute <<~SQL
      UPDATE topics
      SET visible = TRUE
      WHERE id IN (
        SELECT topic_id
        FROM course_reviews
        WHERE topic_id IS NOT NULL
      )
    SQL
  end
end
