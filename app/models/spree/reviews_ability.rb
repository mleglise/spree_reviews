class Spree::ReviewsAbility
  include CanCan::Ability

  def initialize user
    review_ability_class = self.class
    can :create, Spree::Review do |review|
      review_ability_class.allow_anonymous_reviews? || !user.email.blank?
    end
    can :create, Spree::FeedbackReview do |review|
      review_ability_class.allow_anonymous_reviews? || !user.email.blank?
    end
    if !user.new_record?
      can :update, Spree::Review do |review|
        # TODO: only allow admin or review owner to update
        review.approved == false
      end
    end
  end

  def self.allow_anonymous_reviews?
    !Spree::Reviews::Config[:require_login]
  end
end
