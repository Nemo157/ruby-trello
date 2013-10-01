module Trello
  class Notification < BasicData
    register_attributes :id, :unread, :type, :date, :data, :member_creator_id,
      :read_only => [ :id, :type, :date, :member_creator_id ]
    validates_presence_of :id, :type, :date, :member_creator_id

    class << self
      # Locate a notification by its id
      def find(id)
        client.find(:notification, id)
      end
    end

    def save
      return update! if id
      fail "Cannot save new instance."
    end

    def update!
      fail "Cannot save new instance." unless self.id

      @previously_changed = changes
      @changed_attributes.clear

      client.put("/notifications/#{self.id}", {
        :unread => attributes[:unread]
      }).json_into(self)
    end

    def update_fields(fields)
      attributes[:id]                = fields['id'] if fields.has_key?('id')
      attributes[:unread]            = fields['unread'] || false
      attributes[:type]              = fields['type'] if fields.has_key?('type')
      attributes[:date]              = fields['date'] if fields.has_key?('date')
      attributes[:data]              = fields['data'] if fields.has_key?('data')
      attributes[:member_creator_id] = fields['idMemberCreator'] if fields.has_key?('idMemberCreator')
      self
    end

    alias :unread? :unread

    one :member_creator, :path => :members, :via => Member, :using => :member_creator_id

    def board
      client.get("/notifications/#{id}/board").json_into(Board).tap do |board|
        board.client = client
      end
    end

    def list
      client.get("/notifications/#{id}/list").json_into(List).tap do |list|
        list.client = client
      end
    end

    def card
      client.get("/notifications/#{id}/card").json_into(Card).tap do |card|
        card.client = client
      end
    end

    def member
      client.get("/notifications/#{id}/member").json_into(Member).tap do |member|
        member.client = client
      end
    end

    def organization
      client.get("/notifications/#{id}/organization").json_into(Organization).tap do |org|
        org.client = client
      end
    end

    def read!
      client.put("/notifications/#{id}/unread", { value: false })
    end
  end
end
