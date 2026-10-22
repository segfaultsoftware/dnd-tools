module Campaigns
  class Create
    DUPLICATE_NAME_ERROR = "You already DM a campaign with this name".freeze

    Result = Struct.new(:campaign, :membership, keyword_init: true) do
      def success?
        campaign.persisted? && membership&.persisted?
      end

      def errors
        campaign.errors
      end
    end

    class DuplicateNameError < StandardError; end

    def self.call(profile:, name:)
      new(profile:, name:).call
    end

    def initialize(profile:, name:)
      @profile = profile
      @name = name
    end

    def call
      campaign = Campaign.new(name: @name)
      return Result.new(campaign:) unless campaign.valid?

      membership = nil

      Campaign.transaction do
        profile = Profile.lock.find(@profile.id)

        if profile.dm_campaign_memberships.where(campaign_name_key: campaign.comparison_key).exists?
          add_duplicate_name_error(campaign)
          raise DuplicateNameError
        end

        campaign.save!
        membership = campaign.campaign_memberships.create!(profile:, is_dm: true)
      end

      Result.new(campaign:, membership:)
    rescue DuplicateNameError, ActiveRecord::RecordNotUnique
      add_duplicate_name_error(campaign)
      Result.new(campaign:)
    rescue ActiveRecord::RecordInvalid => error
      error.record.errors.each { |attribute, message| campaign.errors.add(attribute, message) } unless error.record == campaign
      Result.new(campaign:)
    end

    private

    def add_duplicate_name_error(campaign)
      campaign.errors.add(:name, DUPLICATE_NAME_ERROR) unless campaign.errors.added?(:name, DUPLICATE_NAME_ERROR)
    end
  end
end
