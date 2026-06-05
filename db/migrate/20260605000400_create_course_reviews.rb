class CreateCourseReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :course_reviews do |t|
      t.integer :topic_id
      t.integer :post_id
      t.integer :course_id, null: false
      t.integer :teacher_id, null: false
      t.integer :user_id, null: false
      t.string :term, null: false
      t.string :recommendation, null: false
      t.string :workload
      t.string :difficulty
      t.string :attendance
      t.jsonb :assessment_methods, null: false, default: []
      t.jsonb :suitable_for, null: false, default: []
      t.string :one_line_advice, null: false
      t.text :detail_text
      t.string :status, null: false, default: "published"
      t.timestamps
    end

    add_index :course_reviews, :topic_id
    add_index :course_reviews, :post_id
    add_index :course_reviews, :course_id
    add_index :course_reviews, :teacher_id
    add_index :course_reviews, :user_id
    add_index :course_reviews, :status
  end
end
