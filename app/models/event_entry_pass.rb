class EventEntryPass < ApplicationRecord
  belongs_to :event
  belongs_to :user
  belongs_to :created_by, class_name: 'User'

  has_many :fixed_email_entry_passes



  validates :event, uniqueness: { scope: :user }
  validates :unique_code, uniqueness: { scope: :event }


  def self.find_or_create(event, user, created_by, ots = false, uninvited = false, attendance = false)
    entry_pass = EventEntryPass.find_by(event: event, user: user)

    if(entry_pass.blank?)
      entry_pass = EventEntryPass.new(event: event, user: user, created_by: created_by)

    #   generate a code based on the number of seats available (one digit more)
      on_the_spot_registration = ots
      uninvited = uninvited
      attendance = attendance
      entry_pass.unique_code = EventEntryPass.generate_code(event)
      entry_pass.save
    end

    return entry_pass
  end



  def self.generate_code(event)
    unique_code = rand.to_s[5..10]

    while(!EventEntryPass.find_by(event: event, unique_code: unique_code).blank?)
      unique_code = rand.to_s[5..10]
    end

    return unique_code

  end


  def fixed_email_sent?(type)
    fixed_emails = self.fixed_emails
    if(fixed_emails.map(&:mail_type).include? type)
      return true, fixed_emails.length
    end


    return false, 0
  end


end