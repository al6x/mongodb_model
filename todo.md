# Article

  def comments
    Comment.query({item_id: _id}, {sort: [[created_at:, -1]]})
  end
  after_destroy{comments.each(&:destroy!)}

  # has_many :comments, order: 'created_at', dependent: :destroy, foreign_key: :item_id, class_name: 'Models::Item'
  # field :comments_count, type: Integer, default: 0


  # embeds_many :attachments, class_name: 'Models::Attachment'

  def attachments
    @attachments ||= []
  end


  attr_writer :token
  def token; @token ||= String.secure_token end

  field :token,      type: String, default: lambda{String.secure_token}


  # relations
  def spaces
    Models::Space.query account_id: _id
  end
  after_destroy{|m| m.spaces.each &:destroy!}
  has_many :spaces, dependent: :destroy, foreign_key: :account_id, class_name: 'Models::Space'