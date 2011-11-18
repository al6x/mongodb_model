
# Done

- updated to latest MongoDB driver
- make id strings by default
- Handy scopes (limit, skip, paginate, ...)
- Modifiers ($set, $get, $push, ...)

# Article
  # Add article and sample about Fat Models vs. Composite


  def comments
    Comment.query({item_id: _id}, {sort: [[created_at:, -1]]})
  end
  after_delete{comments.each(&:delete!)}

  # has_many :comments, order: 'created_at', dependent: :delete, foreign_key: :item_id, class_name: 'Models::Item'
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
  after_delete{|m| m.spaces.each &:delete!}
  has_many :spaces, dependent: :delete, foreign_key: :account_id, class_name: 'Models::Space'



  Unit.skip(30).limit(10).sort([name: 1])



  @models = self.class.model_class.
    where(viewers: {_in: rad.user.major_roles}, dependent: false).
    sort([:created_at, -1]).
    paginate(@page, @per_page).
    all

  Security profiles