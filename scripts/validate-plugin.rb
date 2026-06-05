# frozen_string_literal: true

require "json"
require "open3"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path

def fail_check(message)
  warn "FAIL: #{message}"
  exit 1
end

def assert_file(path)
  full_path = ROOT.join(path)
  fail_check("missing #{path}") unless full_path.file?
  full_path
end

required_files = %w[
  plugin.rb
  about.json
  README.md
  PLAN_PROGRESS.md
  ADMIN_CHECKLIST.md
  config/settings.yml
  config/locales/server.en.yml
  config/locales/client.en.yml
  assets/javascripts/discourse/course-reviews-route-map.js
  assets/javascripts/discourse/initializers/course-reviews.js
  assets/javascripts/discourse/components/course-review-form.gjs
  assets/javascripts/discourse/connectors/composer-fields/course-review-composer.gjs
  assets/javascripts/discourse/connectors/topic-above-post-stream/course-review-summary.gjs
  assets/javascripts/discourse/routes/course-reviews-index.js
  assets/javascripts/discourse/routes/course-reviews-show.js
  assets/javascripts/discourse/routes/course-reviews-admin.js
  assets/javascripts/discourse/templates/course-reviews.gjs
  assets/javascripts/discourse/templates/course-reviews/index.gjs
  assets/javascripts/discourse/templates/course-reviews/show.gjs
  assets/javascripts/discourse/templates/course-reviews/admin.gjs
  assets/javascripts/discourse/templates/course-reviews/new.gjs
  app/controllers/course_reviews/frontend_controller.rb
  app/controllers/course_reviews/courses_controller.rb
  app/controllers/course_reviews/reviews_controller.rb
  app/models/course_review_review.rb
  app/serializers/course_review_review_serializer.rb
]

required_files.each { |path| assert_file(path) }

JSON.parse(assert_file("about.json").read)
YAML.safe_load(assert_file("config/settings.yml").read)
YAML.safe_load(assert_file("config/locales/server.en.yml").read)
YAML.safe_load(assert_file("config/locales/client.en.yml").read)

Dir[ROOT.join("**/*.rb")].each do |file|
  output, status = Open3.capture2e("ruby", "-c", file)
  fail_check("#{file} failed ruby -c:\n#{output}") unless status.success?
end

plugin_rb = assert_file("plugin.rb").read
%w[
  /course-reviews.json
  /course-reviews/courses/search.json
  /course-reviews/courses/:id.json
  /course-reviews/reviews/pending.json
  /course-reviews/reviews.json
  /course-reviews/courses/:id/merge.json
  /course-reviews
  /course-reviews/new
  /course-reviews/admin
  /course-reviews/courses/:id
].each do |route|
  fail_check("plugin.rb missing route #{route}") unless plugin_rb.include?(route)
end

form = assert_file("assets/javascripts/discourse/components/course-review-form.gjs").read
%w[
  course_name
  teacher_name
  term
  course_type
  recommendation
  workload
  difficulty
  attendance
  assessment_methods
  suitable_for
  one_line_advice
  detail_text
].each do |field|
  fail_check("course review form missing #{field}") unless form.include?(field)
end

review_model = assert_file("app/models/course_review_review.rb").read
%w[RECOMMENDATIONS WORKLOADS DIFFICULTIES ATTENDANCE ASSESSMENT_METHODS SUITABLE_FOR STATUSES].each do |constant|
  fail_check("review model missing #{constant}") unless review_model.include?(constant)
end

forbidden_patterns = [
  /t\.integer\s+:rating/,
  /t\.float\s+:rating/,
  /t\.decimal\s+:rating/,
  /teacher ranking/i,
  /老师排名/,
  /\?\./
]

implementation_files =
  Dir[ROOT.join("{app,assets,config,db}/**/*")].select { |path| File.file?(path) } +
    [ROOT.join("plugin.rb")]

implementation_files.each do |file|
  text = File.read(file, encoding: "UTF-8", invalid: :replace, undef: :replace)
  forbidden_patterns.each do |pattern|
    fail_check("#{file} contains forbidden pattern #{pattern.inspect}") if text.match?(pattern)
  end
end

deprecated_template_files = %w[
  assets/javascripts/discourse/templates/components/course-review-form.hbs
  assets/javascripts/discourse/components/course-review-form.js
  assets/javascripts/discourse/connectors/composer-fields/course-review-composer.hbs
  assets/javascripts/discourse/connectors/composer-fields/course-review-composer.js
  assets/javascripts/discourse/connectors/topic-above-post-stream/course-review-summary.hbs
  assets/javascripts/discourse/templates/course-reviews.hbs
  assets/javascripts/discourse/templates/course-reviews/index.hbs
  assets/javascripts/discourse/templates/course-reviews/show.hbs
  assets/javascripts/discourse/templates/course-reviews/admin.hbs
  assets/javascripts/discourse/templates/course-reviews/new.hbs
]

deprecated_template_files.each do |path|
  fail_check("#{path} should be migrated to .gjs") if ROOT.join(path).exist?
end

puts "course reviews plugin validation passed"
