# frozen_string_literal: true

module ::CourseReviews::Access
  def self.can_access?(user)
    return false if !SiteSetting.course_reviews_enabled
    return false if user.blank?
    return true if user.admin?

    allowed_group_ids = SiteSetting.course_reviews_allowed_groups_map
    allowed_group_ids.present? && user.in_any_groups?(allowed_group_ids)
  end

  def self.ensure_can_access!(guardian)
    raise Discourse::InvalidAccess.new if !can_access?(guardian.user)
  end
end
