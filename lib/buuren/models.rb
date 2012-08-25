require 'mongoid_orderable'

class NowPlaying
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Orderable

  default_scope order_by(:position => :asc)

  belongs_to :track

  orderable
end

class Track
  include Mongoid::Document

  field :filename

  has_many :now_playings
end
