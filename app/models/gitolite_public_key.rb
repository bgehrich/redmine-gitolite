class GitolitePublicKey < ActiveRecord::Base
  STATUS_ACTIVE = 1
  STATUS_LOCKED = 0

  belongs_to :user
  validates_uniqueness_of :title, :scope => :user_id
  validates_uniqueness_of :identifier, :score => :user_id
  validates_presence_of :title, :key, :identifier
  
  named_scope :active, {:conditions => {:active => GitolitePublicKey::STATUS_ACTIVE}}
  named_scope :inactive, {:conditions => {:active => GitolitePublicKey::STATUS_LOCKED}}
  
  validate :has_not_been_changed
  validate :validate_public_key
  
  before_validation :set_identifier
  
  def has_not_been_changed
    unless new_record?
      %w(identifier key user_id).each do |attribute|
        errors.add(attribute, 'may not be changed') unless changes[attribute].blank?
      end
    end
  end

  def validate_public_key
    @fields = key.split(" ")
	unless @fields[0].eql? "ssh-rsa" or @fields[0].eql? "ssh-dss"
	  errors.add(:key, 'field invalid. Key must begin with ssh-rsa or ssh-dss!')
	end
  end
  
  def set_identifier
    self.identifier ||= "#{self.user.login.underscore}@#{self.title.underscore}".gsub(/[^0-9a-zA-Z-_]/,'_')
  end
    
  def to_s ; title ; end
  
  def location
    self.title.underscore.gsub(/[^0-9a-zA-Z-_]/,'_')
  end
  
  def owner
    self.user.login.underscore.gsub(/[^0-9a-zA-Z-_]/,'_')
  end
end
